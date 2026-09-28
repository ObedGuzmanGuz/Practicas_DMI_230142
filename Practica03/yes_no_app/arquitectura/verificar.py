"""Comprobaciones del HTML final en Chrome (requiere websocket-client).
No ejecuta Flutter ni modifica la aplicación. Guarda un recibo y capturas.
"""
from pathlib import Path
import base64
import hashlib
import http.server
import json
import os
import re
import shutil
import subprocess
import tempfile
import threading
import time
import urllib.request
import websocket

HERE=Path(__file__).resolve().parent
ARTIFACT=HERE/'arquitectura_yes_no_app.html'
EVIDENCE=HERE/'evidencia'
browser_candidates=[os.environ.get('CHROME_PATH'),shutil.which('google-chrome'),shutil.which('chromium'),shutil.which('msedge'),
    'C:/Program Files/Google/Chrome/Application/chrome.exe','C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome']
chrome=next((Path(p) for p in browser_candidates if p and Path(p).is_file()),None)
if chrome is None:raise SystemExit('No se encontró Chrome/Edge. Define CHROME_PATH para ejecutar la revisión del navegador.')
profile=Path(tempfile.mkdtemp(prefix='archify-yes-no-check-')).resolve()
assert profile.parent==Path(tempfile.gettempdir()).resolve() and profile.name.startswith('archify-yes-no-check-')
process=subprocess.Popen([str(chrome),'--headless=new','--disable-gpu','--no-first-run','--no-default-browser-check','--remote-allow-origins=http://localhost','--remote-debugging-port=0','--user-data-dir='+str(profile),'about:blank'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
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
    repo=Path(subprocess.check_output(['git','rev-parse','--show-toplevel'],cwd=HERE,text=True).strip())
    html=ARTIFACT.read_text('utf-8')
    data=json.loads(re.search(r'const DATA = (.*);\nconst \$',html).group(1))
    config=json.loads((HERE/'configuracion.json').read_text('utf-8'))
    embedded=json.loads(re.search(r'const CONFIG = Object.freeze\((.*)\);',html).group(1))
    check('Configuración única coherente con el HTML',config==embedded)
    source_issues=[]
    for path,evidence in data['files'].items():
        local=repo/path
        parent=repo
        for part in Path(path).parts:
            if part not in {p.name for p in parent.iterdir()}:
                source_issues.append({'path':path,'error':'No existe con estas mayúsculas'});break
            parent=parent/part
        if not local.is_file() or hashlib.sha256(local.read_bytes()).hexdigest()!=evidence['sha256']:
            source_issues.append({'path':path,'error':'Contenido modificado desde la generación'})
    for id,node in data['nodes'].items():
        for f in node['files']:
            if f['start']:
                line_count=len((repo/f['path']).read_text('utf-8').splitlines())
                if not 1<=f['start']<=f['end']<=line_count:source_issues.append({'node':id,'error':'Rango inválido'})
        if node.get('snippetSource'):
            f=node['snippetSource']
            actual='\n'.join((repo/f['path']).read_text('utf-8').splitlines()[f['start']-1:f['end']])
            if actual!=node['snippet']:source_issues.append({'node':id,'error':'Fragmento no coincide'})
    check('Rutas con mayúsculas, hashes, rangos y fragmentos fieles',not source_issues,source_issues)
    dart_files={p.relative_to(repo).as_posix() for p in (HERE.parent/'lib').rglob('*.dart')}
    check('Los diez archivos Dart están documentados',len(dart_files)==10 and dart_files.issubset(data['files']),sorted(dart_files))
    check('Seis plataformas con panel y archivos reales',all(data['nodes'].get(p,{}).get('files') for p in ['android','ios','web','windows','linux','macos']))
    initial=json.loads((EVIDENCE/'estado-inicial.json').read_text('utf-8'))
    changed=[p for p,h in initial['files'].items() if not (repo/p).is_file() or hashlib.sha256((repo/p).read_bytes()).hexdigest()!=h]
    unexpected=[p for p in changed if p!=config['appPath']+'/README.md']
    check('Aplicación, cambios previos y arquitectura anterior preservados',not unexpected,{'filesCompared':len(initial['files']),'changed':changed,'unexpected':unexpected})
    report['remoteComparison']={'ref':data['reviewedRef'],'tree':data['remoteCommit'],'matchingFiles':sum(f['sameContent'] for f in data['files'].values()),'differentFiles':[p for p,f in data['files'].items() if not f['sameContent']]}
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
        if w in [1440,2048,390]: capture(f'yes-no-{w}x{h}.png')
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
        result=js('({open:dialog.open,title:$("detail-title").textContent,focused:document.activeElement.id,selected:document.querySelectorAll(".node.selected").length,links:[...dialog.querySelectorAll("a")].every(a=>a.target==="_blank"&&a.rel.includes("noopener")&&a.rel.includes("noreferrer"))})')
        check('Panel clic: '+id,result['open'] and result['title']==data['nodes'][id]['title'] and result['focused']=='close' and result['selected']==1 and result['links'],result)
        key('Escape')
        check('Escape y retorno de foco: '+id,js(f'!dialog.open && document.activeElement.dataset.node==={json.dumps(id)}'))
        key('Enter')
        check('Panel teclado: '+id,js('dialog.open'))
        click('#close')
        check('Cierre visible: '+id,js('!dialog.open'))
    js('fit()');settled();click('[data-node="estado"]')
    key('Tab',shift=True)
    check('Foco contenido al retroceder',js('document.activeElement===dialog.querySelectorAll("a")[dialog.querySelectorAll("a").length-1]'))
    key('Tab');check('Foco contenido al avanzar',js('document.activeElement.id==="close"'))
    js('$("detail-body").scrollTop=9999')
    check('Desplazamiento interno',js('$("detail-body").scrollTop>0'))
    js('$("detail-body").scrollTop=0');capture('yes-no-panel.png');key('Escape')
    before=js('camera.w');click('#zoom-in');after=js('camera.w');check('Acercar',after<before)
    click('#zoom-out');check('Alejar',abs(js('camera.w')-before)<.001)
    js('$("viewport").focus()');before=js('camera.x');key('ArrowRight');check('Desplazar con teclado',js('camera.x')>before)
    click('#fit');check('Ajustar conserva selección',js('selected==="estado" && Math.abs(camera.w-fittedWidth)<.001'))
    before=js('camera.x')
    p=js('(()=>{const r=svg.getBoundingClientRect();return {x:r.x+25,y:r.y+25};})()')
    call('Input.dispatchMouseEvent',{'type':'mousePressed',**p,'button':'left','clickCount':1})
    call('Input.dispatchMouseEvent',{'type':'mouseMoved','x':p['x']+80,'y':p['y']+30,'button':'left','buttons':1})
    call('Input.dispatchMouseEvent',{'type':'mouseReleased','x':p['x']+80,'y':p['y']+30,'button':'left','clickCount':1})
    check('Arrastrar lienzo',abs(js('camera.x')-before)>1)
    before=js('camera.w');call('Input.dispatchMouseEvent',{'type':'mouseWheel',**p,'deltaY':-120,'deltaX':0});settled();check('Acercar con rueda',js('camera.w')<before)
    click('#reset');check('Restablecer vista',js('selected===null&&Math.abs(camera.w-fittedWidth)<.001'))
    click('#about');check('Panel de publicación y enlace de carpeta',js('dialog.open && [...dialog.querySelectorAll("a")].some(a=>a.href.includes("/tree/"))'));click('#close')
    link_check=js('Object.values(DATA.nodes).flatMap(n=>n.files).every(f=>DATA.files[f.path]?.local && (!f.start||(f.start>=1&&f.end>=f.start&&f.end<=DATA.files[f.path].lines)) && new URL(github(f)).pathname.includes("/"+CONFIG.appPath+"/"))')
    check('Rutas locales, rangos y enlaces',link_check)
    resize(390,844);js('document.querySelector("[data-node=estado]").focus()');key(' ')
    check('Panel móvil con espacio',js('dialog.open && dialog.getBoundingClientRect().right<=innerWidth && dialog.getBoundingClientRect().bottom<=innerHeight'))
    capture('yes-no-panel-movil.png');key('Escape')
    js('$("node-picker").value="android";$("node-picker").dispatchEvent(new Event("change"))')
    check('Selector de bloques en pantalla estrecha',js('dialog.open && selected==="android"'));key('Escape')
    js('fit();zoom(4)')
    reachable=js('Object.keys(DATA.nodes).every(id=>{document.querySelector(`[data-node="${id}"]`).focus();const n=DATA.nodes[id].geometry;return n[0]>=camera.x&&n[1]>=camera.y&&n[0]+n[2]<=camera.x+camera.w&&n[1]+n[3]<=camera.y+camera.h;})')
    check('Todos los bloques alcanzables mediante foco al ampliar',reachable)
    js('fit()')
    # Sirve solo el HTML en una ruta que reproduce la subcarpeta de GitHub Pages.
    served='/Practicas_DMI_230142/Practica03/yes_no_app/arquitectura/arquitectura_yes_no_app.html'
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
    settled();click('[data-node="inicio"]');check('Sitio estático en subcarpeta',js('dialog.open'));key('Escape')
    errors=[e for e in events if e.get('method')=='Runtime.exceptionThrown' or (e.get('method')=='Runtime.consoleAPICalled' and e['params']['type']=='error')]
    check('Sin errores de JavaScript',not errors,errors)
    resources=js('performance.getEntriesByType("resource").filter(r=>!r.name.endsWith("/favicon.ico")).map(r=>r.name)')
    check('Sin dependencias de red del visor',not resources,resources)
    external=[e['params']['request']['url'] for e in events if e.get('method')=='Network.requestWillBeSent' and e['params']['request']['url'].startswith(('http:','https:')) and not e['params']['request']['url'].startswith('http://127.0.0.1:')]
    check('Ningún panel descarga código ni consulta servicios externos',not external,external)
    failed_capture=EVIDENCE/'yes-no-fallo.png'
    if failed_capture.is_file():failed_capture.unlink()
    report['status']='pass'
except Exception as error:
    report['status']='fail';report['error']=str(error)
    if sock:
        try:capture('yes-no-fallo.png')
        except Exception:pass
finally:
    if sock:
        try:call('Browser.close')
        except Exception:pass
        sock.close()
    if server:server.shutdown();server.server_close()
    try:process.wait(timeout=8)
    except subprocess.TimeoutExpired:process.terminate();process.wait(timeout=8)
    if profile.parent==Path(tempfile.gettempdir()).resolve() and profile.name.startswith('archify-yes-no-check-'):
        shutil.rmtree(profile,ignore_errors=True)
    (EVIDENCE/'navegador-final.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'status':report['status'],'checks':len(report['checks']),'error':report.get('error'),'sha256':report['artifact']['sha256']}))
raise SystemExit(0 if report['status']=='pass' else 1)
