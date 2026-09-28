"""Comprobaciones del HTML final en Chrome (requiere websocket-client).
No ejecuta Flutter ni modifica la aplicación. Guarda un recibo y capturas.
"""
from pathlib import Path
import base64
import functools
import hashlib
import http.server
import json
import os
import shutil
import subprocess
import tempfile
import threading
import time
import urllib.request
import websocket

HERE=Path(__file__).resolve().parent
ARTIFACT=HERE/'arquitectura_contador_flutter.html'
EVIDENCE=HERE/'evidencia'
chrome=next(p for p in [Path('C:/Program Files/Google/Chrome/Application/chrome.exe'),Path('C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe')] if p.is_file())
profile=Path(tempfile.mkdtemp(prefix='archify-contador-check-')).resolve()
assert profile.parent==Path(tempfile.gettempdir()).resolve() and profile.name.startswith('archify-contador-check-')
process=subprocess.Popen([str(chrome),'--headless=new','--disable-gpu','--no-first-run','--no-default-browser-check','--remote-allow-origins=http://localhost','--remote-debugging-port=0','--user-data-dir='+str(profile),'about:blank'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,creationflags=subprocess.CREATE_NO_WINDOW)
sock=None
server=None
events=[]
sequence=0
report={'artifact':{'file':ARTIFACT.name,'sha256':hashlib.sha256(ARTIFACT.read_bytes()).hexdigest(),'bytes':ARTIFACT.stat().st_size},'browser':'Chrome sin ventana, DevTools Protocol','status':'running','viewports':[],'checks':[],'screenshots':[]}

def call(method,params=None):
    global sequence
    sequence+=1
    sock.send(json.dumps({'id':sequence,'method':method,'params':params or {}}))
    while True:
        response=json.loads(sock.recv())
        if response.get('id')==sequence:
            if 'error' in response: raise RuntimeError(response['error'])
            return response.get('result',{})
        events.append(response)

def js(expression):
    result=call('Runtime.evaluate',{'expression':expression,'returnByValue':True,'awaitPromise':True})
    if 'exceptionDetails' in result: raise RuntimeError(result['exceptionDetails'])
    return result.get('result',{}).get('value')

def settled(): js('new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(()=>resolve(true))))')
def check(name,condition,details=None):
    report['checks'].append({'name':name,'passed':bool(condition),'details':details})
    if not condition: raise AssertionError(f'{name}: {details}')
def key(name,shift=False):
    for type in ['keyDown','keyUp']: call('Input.dispatchKeyEvent',{'type':type,'key':name,'code':name,'modifiers':8 if shift else 0,'windowsVirtualKeyCode':{'Tab':9,'Enter':13,'Escape':27,' ':32,'ArrowRight':39}.get(name,0)})
def click(selector):
    pos=js(f'(()=>{{const r=document.querySelector({json.dumps(selector)}).getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
    for type in ['mousePressed','mouseReleased']:call('Input.dispatchMouseEvent',{'type':type,'x':pos['x'],'y':pos['y'],'button':'left','clickCount':1})
def capture(name):
    data=call('Page.captureScreenshot',{'format':'png','captureBeyondViewport':False})['data']
    (EVIDENCE/name).write_bytes(base64.b64decode(data));report['screenshots'].append(name)
def resize(w,h):
    call('Emulation.setDeviceMetricsOverride',{'width':w,'height':h,'deviceScaleFactor':1,'mobile':False});settled()

try:
    deadline=time.monotonic()+20
    while not (profile/'DevToolsActivePort').exists():
        if time.monotonic()>deadline: raise RuntimeError('Chrome no inició el puerto de depuración')
        time.sleep(.1)
    port=(profile/'DevToolsActivePort').read_text().splitlines()[0]
    pages=json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list'))
    sock=websocket.create_connection(next(p['webSocketDebuggerUrl'] for p in pages if p['type']=='page'),origin='http://localhost',timeout=20)
    call('Runtime.enable');call('Page.enable');call('Log.enable');call('Network.enable')
    call('Page.navigate',{'url':ARTIFACT.as_uri()})
    deadline=time.monotonic()+15
    while not js('document.readyState==="complete" && typeof DATA!=="undefined"'):
        if time.monotonic()>deadline: raise RuntimeError('El HTML no terminó de cargar')
        time.sleep(.1)
    for w,h in [(1440,900),(1600,1000),(1920,1080),(2048,1320),(390,844)]:
        resize(w,h)
        m=js('''(()=>{const d=document.documentElement,r=svg.getBoundingClientRect();const nodes=[...document.querySelectorAll('[data-node]')];return {width:innerWidth,height:innerHeight,scrollWidth:d.scrollWidth,scrollHeight:d.scrollHeight,allNodesVisible:nodes.every(n=>{const b=n.getBoundingClientRect();return b.left>=r.left-1&&b.right<=r.right+1&&b.top>=r.top-1&&b.bottom<=r.bottom+1}),nodeCount:nodes.length};})()''')
        report['viewports'].append(m)
        check(f'Encuadre {w}x{h}',m['scrollWidth']<=w and (m['scrollHeight']<=h or w<700) and m['allNodesVisible'],m)
        if w in [1440,2048,390]: capture(f'contador-{w}x{h}.png')
    resize(1440,900)
    text_issues=js('''(()=>{const issues=[];for(const node of document.querySelectorAll('[data-node]')){const r=node.querySelector('rect').getBBox();for(const t of node.querySelectorAll('text')){const b=t.getBBox();if(b.x<r.x||b.x+b.width>r.x+r.width||b.y<r.y||b.y+b.height>r.y+r.height)issues.push({node:node.dataset.node,text:t.textContent,box:{x:b.x,width:b.width},card:{x:r.x,width:r.width}});}}return issues;})()''')
    check('Textos contenidos en tarjetas',not text_issues,text_issues)
    collisions=js('''(()=>{const issues=[];const nodes=[...document.querySelectorAll('[data-node]')];for(const edge of document.querySelectorAll('path[data-edge]')){const e=DATA.edges.find(e=>e.id===edge.dataset.edge);const len=edge.getTotalLength();for(const n of nodes){if([e.from,e.to].includes(n.dataset.node))continue;const r=n.querySelector('rect').getBBox();for(let t=2;t<len-2;t+=2){const p=edge.getPointAtLength(t);if(p.x>r.x+1&&p.x<r.x+r.width-1&&p.y>r.y+1&&p.y<r.y+r.height-1){issues.push({edge:e.id,node:n.dataset.node});break;}}}}return issues;})()''')
    check('Conectores fuera de tarjetas ajenas',not collisions,collisions)
    labels=js('''(()=>{const out=[];for(const label of document.querySelectorAll('.edge-label')){const a=label.getBBox();for(const n of document.querySelectorAll('[data-node]')){const b=n.getBBox();if(a.x<b.x+b.width&&a.x+a.width>b.x&&a.y<b.y+b.height&&a.y+a.height>b.y)out.push({edge:label.dataset.edge,node:n.dataset.node});}}return out;})()''')
    check('Etiquetas fuera de tarjetas',not labels,labels)
    ids=js('Object.keys(DATA.nodes)')
    for id in ids:
        js('fit()');settled()
        selector=f'[data-node="{id}"]'
        js(f'document.querySelector({json.dumps(selector)}).focus()')
        click(selector)
        result=js('({open:dialog.open,title:$("detail-title").textContent,focused:document.activeElement.id,selected:document.querySelectorAll(".node.selected").length,links:[...dialog.querySelectorAll("a")].every(a=>a.target==="_blank"&&a.rel.includes("noopener")&&a.rel.includes("noreferrer")&&a.href.startsWith(CONFIG.repository+"/blob/"))})')
        check('Panel clic: '+id,result['open'] and result['focused']=='close' and result['selected']==1 and result['links'],result)
        key('Escape')
        check('Escape y retorno de foco: '+id,js(f'!dialog.open && document.activeElement.dataset.node==={json.dumps(id)}'))
        key('Enter')
        check('Panel teclado: '+id,js('dialog.open'))
        click('#close')
        check('Cierre visible: '+id,js('!dialog.open'))
    js('fit()');settled();click('[data-node="botones"]')
    key('Tab',shift=True)
    check('Foco contenido al retroceder',js('document.activeElement===dialog.querySelectorAll("a")[dialog.querySelectorAll("a").length-1]'))
    key('Tab');check('Foco contenido al avanzar',js('document.activeElement.id==="close"'))
    js('$("detail-body").scrollTop=9999')
    check('Desplazamiento interno',js('$("detail-body").scrollTop>0'))
    js('$("detail-body").scrollTop=0');capture('contador-panel.png');key('Escape')
    before=js('camera.w');click('#zoom-in');after=js('camera.w');check('Acercar',after<before)
    click('#zoom-out');check('Alejar',abs(js('camera.w')-before)<.001)
    js('$("viewport").focus()');before=js('camera.x');key('ArrowRight');check('Desplazar con teclado',js('camera.x')>before)
    click('#fit');check('Ajustar conserva selección',js('selected==="botones" && Math.abs(camera.w-fittedWidth)<.001'))
    before=js('camera.x')
    p=js('(()=>{const r=svg.getBoundingClientRect();return {x:r.x+25,y:r.y+25};})()')
    call('Input.dispatchMouseEvent',{'type':'mousePressed',**p,'button':'left','clickCount':1})
    call('Input.dispatchMouseEvent',{'type':'mouseMoved','x':p['x']+80,'y':p['y']+30,'button':'left','buttons':1})
    call('Input.dispatchMouseEvent',{'type':'mouseReleased','x':p['x']+80,'y':p['y']+30,'button':'left','clickCount':1})
    check('Arrastrar lienzo',abs(js('camera.x')-before)>1)
    before=js('camera.w');call('Input.dispatchMouseEvent',{'type':'mouseWheel',**p,'deltaY':-120,'deltaX':0});settled();check('Acercar con rueda',js('camera.w')<before)
    click('#reset');check('Restablecer vista',js('selected===null&&Math.abs(camera.w-fittedWidth)<.001'))
    click('#about');check('Panel de publicación y enlace de carpeta',js('dialog.open && dialog.querySelector("a").href.includes("/tree/")'));click('#close')
    link_check=js('Object.values(DATA.nodes).flatMap(n=>n.files).every(f=>DATA.files[f.path]?.local && DATA.files[f.path]?.remote && DATA.files[f.path]?.sameContent && (!f.start||(f.start>=1&&f.end>=f.start&&f.end<=DATA.files[f.path].lines)) && new URL(github(f)).pathname.includes("/"+CONFIG.appRoot+"/"))')
    check('Rutas, líneas, contenido remoto y construcción de enlaces',link_check)
    resize(390,844);js('document.querySelector("[data-node=botones]").focus()');key(' ')
    check('Panel móvil con espacio',js('dialog.open && dialog.getBoundingClientRect().right<=innerWidth && dialog.getBoundingClientRect().bottom<=innerHeight'))
    capture('contador-panel-movil.png');key('Escape')
    # Sirve solo el HTML en una ruta que reproduce la subcarpeta de GitHub Pages.
    served='/Practicas_DMI_230142/Practica02/hello_world_ap/arquitectura/arquitectura_contador_flutter.html'
    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path!=served:self.send_error(404);return
            self.send_response(200);self.send_header('Content-Type','text/html; charset=utf-8');self.end_headers();self.wfile.write(ARTIFACT.read_bytes())
        def log_message(self,*args): pass
    server=http.server.ThreadingHTTPServer(('127.0.0.1',0),Handler)
    threading.Thread(target=server.serve_forever,daemon=True).start()
    resize(1440,900)
    call('Page.navigate',{'url':f'http://127.0.0.1:{server.server_port}'+served})
    deadline=time.monotonic()+10
    while not js('document.readyState==="complete" && typeof DATA!=="undefined"'):
        if time.monotonic()>deadline:raise RuntimeError('No cargó el sitio estático')
        time.sleep(.1)
    settled();click('[data-node="app"]');check('Sitio estático en subcarpeta',js('dialog.open'));key('Escape')
    errors=[e for e in events if e.get('method')=='Runtime.exceptionThrown' or (e.get('method')=='Runtime.consoleAPICalled' and e['params']['type']=='error')]
    check('Sin errores de JavaScript',not errors,errors)
    resources=js('performance.getEntriesByType("resource").filter(r=>!r.name.endsWith("/favicon.ico")).map(r=>r.name)')
    check('Sin dependencias de red del visor',not resources,resources)
    report['status']='pass'
except Exception as error:
    report['status']='fail';report['error']=str(error)
    if sock:
        try:capture('contador-fallo.png')
        except Exception:pass
finally:
    if sock:
        try:call('Browser.close')
        except Exception:pass
        sock.close()
    if server:server.shutdown();server.server_close()
    try:process.wait(timeout=8)
    except subprocess.TimeoutExpired:process.terminate();process.wait(timeout=8)
    if profile.parent==Path(tempfile.gettempdir()).resolve() and profile.name.startswith('archify-contador-check-'):
        shutil.rmtree(profile,ignore_errors=True)
    (EVIDENCE/'navegador-final.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'status':report['status'],'checks':len(report['checks']),'error':report.get('error'),'sha256':report['artifact']['sha256']}))
raise SystemExit(0 if report['status']=='pass' else 1)
