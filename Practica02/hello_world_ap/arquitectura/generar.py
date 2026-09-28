"""Integra la geometría entregada por Archify en un visor autónomo en español.
Ejecutar desde APP_ROOT: python arquitectura/generar.py
La referencia editable se conserva desde el HTML existente al regenerar.
"""
from pathlib import Path
import hashlib
import html
import json
import re
import subprocess

HERE = Path(__file__).resolve().parent
APP = HERE.parent
REPO = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], cwd=APP, text=True).strip())
APP_ROOT = APP.relative_to(REPO).as_posix()
OUT = HERE / 'arquitectura_contador_flutter.html'
base = (HERE / 'evidencia/archify_base.html').read_text('utf-8')
spec = json.loads((HERE / 'contador.archify.json').read_text('utf-8'))
remote = json.loads((HERE / 'evidencia/remoto.json').read_text('utf-8-sig'))
tree = {f['path']: f for f in remote['tree']}
assert not remote.get('truncated'), 'La consulta remota está incompleta'
ref = subprocess.check_output(['git', 'branch', '--show-current'], cwd=APP, text=True).strip()
if OUT.exists():
    old = re.search(r'codeRef: "([^"]+)"', OUT.read_text('utf-8'))
    if old: ref = old[1]
files = {}

def source(path, start=None, end=None):
    full = APP_ROOT + '/' + path
    local = APP / path
    assert local.is_file(), full
    binary = path.endswith('.ttf')
    lines = [] if binary else local.read_text('utf-8').splitlines()
    if start is not None:
        assert 1 <= start <= end <= len(lines), (path, start, end)
    sha = subprocess.check_output(['git','hash-object','--path='+full,str(local)],cwd=REPO,text=True).strip()
    files[full] = {'local': True, 'remote': full in tree, 'sameContent': tree.get(full,{}).get('sha') == sha,
                   'lines': len(lines) if not binary else None, 'blob': sha}
    return {'path':full,'start':start,'end':end}

main='lib/main.dart'
active='lib/presentation/screens/counter/counter_functions_screen.dart'
alt='lib/presentation/screens/counter/counter_screen.dart'
nodes={}
def node(id,kind,description,symbols,refs,extra='',snippet=None):
    nodes[id]={'kind':kind,'description':description,'symbols':symbols,'files':refs,'extra':extra}
    if snippet:
        path,a,b=snippet
        nodes[id]['snippet']='\n'.join((APP/path).read_text('utf-8').splitlines()[a-1:b])
        nodes[id]['snippetCaption']=f'{APP_ROOT}/{path} · líneas {a}–{b}'

node('persona','Actor conceptual','Abre la aplicación en una plataforma y pulsa los controles para incrementar, disminuir o reiniciar el contador.',[],[source(active,19,28),source(active,81,103)],'Los archivos citados implementan los controles que usa la persona; no existe un archivo Usuario.')
node('plataformas','Configuración de plataformas','El proyecto contiene seis destinos que integran el mismo código Dart con Flutter. No son servicios que se llamen entre sí.',[],[], 'Se comprobaron los archivos de configuración locales. Su presencia no demuestra compilación ni pruebas en esas plataformas.')
node('flutter','Framework y lenguaje','Flutter construye la interfaz con widgets Material escritos en Dart. Los anfitriones de cada plataforma integran esa aplicación compartida.',['Flutter','Dart','Widget','MaterialApp'],[source(main,1,6),source('pubspec.yaml',21,47)],'Las referencias son evidencia de uso y configuración de Flutter; el framework no está implementado en este repositorio.')
node('entrada','Punto de entrada','main() llama a runApp(MyApp()) para montar el widget raíz.',['main()','runApp(MyApp())'],[source(main,1,10)],snippet=(main,4,8))
node('app','Widget raíz y tema','MyApp es un StatelessWidget que devuelve MaterialApp. Configura ThemeData con colorSchemeSeed verde, fontFamily Architext y CounterFunctionsScreen como home.',['MyApp','MaterialApp','ThemeData','build()'],[source(main,9,24)],snippet=(main,16,23))
node('pantalla','Pantalla activa con estado','CounterFunctionsScreen crea _CounterFunctionsScreenState. Su build() construye Scaffold y los controles del contador.',['CounterFunctionsScreen','_CounterFunctionsScreenState','createState()','build()'],[source(active,3,18),source(main,18,22)],'Es la pantalla inicial. El estado permanece en memoria durante la vida de este State.',(active,3,8))
node('botones','Widgets y eventos','CustomButton está definido en el mismo archivo de la pantalla y construye un FloatingActionButton que recibe icon y onPressed. Hay tres botones flotantes: reiniciar, disminuir e incrementar. El AppBar contiene otro reinicio mediante IconButton.',['CustomButton','IconButton','FloatingActionButton','onPressed','VoidCallback'],[source(active,19,28),source(active,81,103),source(active,111,132)],'Los callbacks flotantes cambian clickCounter antes de llamar setState(() {}). El reinicio del AppBar lo cambia dentro del callback de setState().',(active,99,103))
node('estado','Estado local y reconstrucción','clickCounter comienza en 0 dentro de _CounterFunctionsScreenState. Los callbacks lo incrementan, disminuyen o reinician; setState() solicita reconstruir la interfaz.',['_CounterFunctionsScreenState','clickCounter','setState()'],[source(active,13,17),source(active,81,103),source(active,22,26)],'El contador se conserva en memoria del widget. No hay persistencia del valor. Flujo: botón → onPressed → cambio de clickCounter → setState() → build() → Text actualizado.',(active,91,103))
node('vista','Árbol de widgets y salida visual','Scaffold contiene AppBar, Center → Column → Text y una Column de botones flotantes. El primer Text muestra el contador y calcula su color; el segundo presenta la etiqueta.',['Scaffold','AppBar','Center','Column','Text','TextStyle'],[source(active,18,59)],'Positivo: verde. Negativo: rojo. Cero: azul. La etiqueta es Click solo cuando clickCounter == 1; en todos los demás casos es Clicks.',(active,39,54))
node('configuracion','Configuración de la aplicación','pubspec.yaml declara Flutter, cupertino_icons, flutter_test y flutter_lints. Habilita Material Icons y registra la fuente personalizada.',['dependencies','dev_dependencies','uses-material-design','fonts'],[source('pubspec.yaml',21,63)],'La familia registrada es Architext y el recurso se llama exactamente assets/fonts/Architex.ttf.',('pubspec.yaml',58,63))
node('tipografia','Recurso tipográfico','La familia Architext se registra en pubspec.yaml con assets/fonts/Architex.ttf y se selecciona en ThemeData.fontFamily.',['Architext','Architex.ttf','fontFamily'],[source('pubspec.yaml',60,63),source('assets/fonts/Architex.ttf'),source(main,18,21)],'Architext es el nombre de familia; Architex.ttf es el nombre real del archivo. El recurso binario no tiene rangos de líneas.')
node('prueba','Prueba existente · observación pendiente','widget_test.dart importa main.dart y monta const MyApp() mediante pumpWidget. Después busca Icons.add y espera que el contador avance a 1.',['testWidgets','WidgetTester','pumpWidget','Icons.add','Icons.plus_one'],[source('test/widget_test.dart',8,28),source(active,99,103)],'Pendiente: el test busca Icons.add, pero la pantalla activa usa Icons.plus_one. No se ejecutó ni modificó esta prueba; no se declara que pase.',('test/widget_test.dart',16,24))
node('alternativa','Pantalla alternativa no activa','CounterScreen y _CounterScreenState existen en el repositorio. Su import está comentado en main.dart y MaterialApp.home apunta a CounterFunctionsScreen.',['CounterScreen','_CounterScreenState'],[source(alt,3,17),source(alt,42,49),source(main,1,3),source(main,22,22)],'No participa en el arranque actual y no tiene una conexión de importación activa en el diagrama.')

platforms=[
 ('android','Android','android/app/src/main/kotlin/com/example/hello_world_ap/MainActivity.kt','android/app/src/main/AndroidManifest.xml',['MainActivity','FlutterActivity'],'La actividad Android extiende FlutterActivity y el manifiesto registra .MainActivity.'),
 ('windows','Windows','windows/runner/main.cpp','windows/runner/flutter_window.cpp',['wWinMain','FlutterWindow','FlutterViewController'],'El ejecutable crea DartProject y FlutterWindow; FlutterViewController aloja la vista.'),
 ('linux','Linux','linux/runner/main.cc','linux/runner/my_application.cc',['main','MyApplication','FlDartProject','FlView'],'El ejecutable inicia MyApplication; GTK aloja una FlView construida desde FlDartProject.'),
 ('macos','macOS','macos/Runner/AppDelegate.swift','macos/Runner/MainFlutterWindow.swift',['AppDelegate','MainFlutterWindow','FlutterViewController'],'La ventana de macOS crea FlutterViewController y registra los plugins.'),
 ('ios','iOS','ios/Runner/AppDelegate.swift','ios/Runner/Info.plist',['AppDelegate','FlutterAppDelegate','FlutterImplicitEngineDelegate'],'AppDelegate integra Flutter y registra plugins; Info.plist configura la aplicación.'),
 ('web','Web','web/index.html','web/manifest.json',['flutter_bootstrap.js','manifest.json'],'index.html referencia el arranque web generado por Flutter; manifest.json describe la aplicación web.')]
for id,title,a,b,symbols,desc in platforms:
    refs=[]
    missing=[]
    for p in [a,b]:
        if (APP/p).is_file(): refs.append(source(p,1,len((APP/p).read_text('utf-8').splitlines())))
        else: missing.append(APP_ROOT+'/'+p)
    node(id,'Plataforma del proyecto',desc,symbols,refs,
         ('Archivos ausentes: '+', '.join(missing)) if missing else 'Configuración comprobada localmente. No se compiló ni probó la aplicación en esta plataforma durante esta tarea.')
    nodes[id]['title']=title

edges=spec['connections']+[{'id':'fuente','from':'configuracion','to':'tipografia','label':'configura'}]
explanations={
 'abrir':'La persona inicia la aplicación en uno de los destinos configurados.',
 'integrar':'Los anfitriones de plataforma configuran la integración con Flutter y su código Dart compartido.',
 'arrancar':'El entorno Flutter inicia el punto de entrada Dart de la aplicación.',
 'montar':'main() ejecuta runApp(MyApp()) y monta MyApp.',
 'home':'MaterialApp muestra CounterFunctionsScreen mediante home.',
 'arbol':'build() contiene el árbol Scaffold, AppBar, Center, Column y Text.',
 'acciones':'La pantalla contiene los botones y define sus callbacks.',
 'mutacion':'onPressed actualiza clickCounter: ++, -- o asignación de 0; después se solicita la reconstrucción con setState().',
 'rebuild':'setState() solicita ejecutar build() de nuevo: la interfaz calcula el número, el color y Click/Clicks.',
 'dependencias':'pubspec.yaml configura dependencias Flutter, Material Icons y recursos.',
 'test':'La prueba importa main.dart y monta MyApp; la búsqueda de icono sigue pendiente de revisión.',
 'fuente':'pubspec.yaml registra Architext con el recurso assets/fonts/Architex.ttf.'}
for e in edges: e['description']=explanations[e['id']]
for id,*_ in platforms:
    edges.append({'id':'plataforma-'+id,'from':id,'to':'flutter','label':'configura','description':'Integra el código Dart compartido mediante la configuración de esta plataforma. Se representa con el conector común del grupo.'})

esc=html.escape
def text(x,y,copy,cls='sub',anchor='start'):
    return f'<text x="{x}" y="{y}" class="{cls}" text-anchor="{anchor}">{esc(copy)}</text>'

icons={
 'persona':'<circle cx="12" cy="6" r="4"/><path d="M4 23v-5a8 8 0 0 1 16 0v5"/>',
 'flutter':'<path d="M20 2 4 18l5 5L25 7M14 15l9 9M9 20l5-5"/>',
 'entrada':'<path d="m8 5-7 7 7 7m10-14 7 7-7 7M15 2l-5 20"/>',
 'app':'<rect x="2" y="2" width="22" height="21" rx="3"/><path d="M2 8h22M8 8v15"/>',
 'pantalla':'<rect x="5" y="1" width="15" height="24" rx="3"/><path d="M10 21h5"/>',
 'vista':'<rect x="1" y="3" width="24" height="18" rx="3"/><path d="M1 9h24M7 15h12"/>',
 'botones':'<circle cx="12" cy="12" r="10"/><path d="M6 12h12m-6-6v12"/>',
 'estado':'<path d="M21 8a10 10 0 1 0 0 9M21 2v6h-6"/><path d="M12 6v7l4 3"/>',
 'configuracion':'<path d="M2 6h22M2 13h22M2 20h22"/><circle cx="8" cy="6" r="3"/><circle cx="18" cy="13" r="3"/><circle cx="8" cy="20" r="3"/>',
 'tipografia':'<path d="m2 23 8-21 8 21M5 16h10M19 11h7m-4-4v16"/>',
 'prueba':'<path d="M8 2h10M10 2v8L3 22h20L16 10V2M7 16h12"/>',
 'alternativa':'<rect x="2" y="3" width="22" height="19" rx="3"/><path d="m10 8 7 5-7 5z"/>',
 'android':'<path d="M3 10h20v11H3zM5 10a7 7 0 0 1 14 0M5 2l3 4m13-4-3 4"/><path d="M8 22v3m10-3v3"/>',
 'windows':'<path d="M2 3h9v9H2zM14 3h9v9h-9zM2 15h9v9H2zM14 15h9v9h-9z"/>',
 'linux':'<path d="M7 12V7a6 6 0 0 1 12 0v5l4 11H3z"/><path d="m9 12 4 3 4-3M7 23l-4 2m16-2 4 2"/><circle cx="10" cy="8" r="1"/><circle cx="16" cy="8" r="1"/>',
 'macos':'<rect x="1" y="2" width="24" height="17" rx="2"/><path d="M8 24h10m-5-5v5"/>',
 'ios':'<rect x="6" y="1" width="14" height="24" rx="3"/><path d="M10 4h6m-5 18h4"/>',
 'web':'<circle cx="13" cy="13" r="11"/><ellipse cx="13" cy="13" rx="5" ry="11"/><path d="M2 13h22M5 6h16M5 20h16"/>'}

svg=['<svg id="diagram" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1350 830" aria-label="Arquitectura interactiva de hello_world_ap"><defs>']
for name,color in [('estructura','#50d9ec'),('evento','#67e8aa')]:
    svg.append(f'<marker id="{name}" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto" markerUnits="userSpaceOnUse"><path d="M0 0L8 4L0 8Z" fill="{color}"/></marker>')
svg.append('</defs><g id="world">')
for x,y,w,h,title in [(25,54,262,421,'Acceso y plataformas'),(321,54,582,125,'Configuración y recursos'),(321,477,582,288,'Arranque y estado en memoria'),(969,288,309,477,'Pantalla y widgets')]:
    svg.append(f'<rect class="boundary" x="{x}" y="{y}" width="{w}" height="{h}" rx="16"/>')
    svg.append(text(500 if y==477 else x+12,y-9,title,'group-label'))

# Conserva exactamente las rutas de conexiones producidas y verificadas por Archify.
for edge in spec['connections']:
    match=re.search(r'<path\b[^>]*data-edge-id="'+edge['id']+r'"[^>]*/>',base)
    assert match,edge['id']
    d=re.search(r' d="([^"]+)"',match.group()).group(1)
    kind='evento' if edge.get('variant')=='emphasis' else 'estructura'
    svg.append(f'<path class="edge {kind}" data-edge="{edge["id"]}" d="{d}" marker-end="url(#{kind})"/>')
svg.append('<path class="edge estructura" data-edge="fuente" d="M561 117L663 117" marker-end="url(#estructura)"/>')

copies={
 'persona':('Usuario',['Abre y utiliza la aplicación']),
 'flutter':('Flutter / Dart',['Widgets Material','Código compartido']),
 'entrada':('main()',['inicia → runApp(MyApp())','lib/main.dart']),
 'app':('MyApp / MaterialApp',['ThemeData · verde · Architext','home: pantalla activa']),
 'pantalla':('CounterFunctionsScreen',['StatefulWidget','createState() → estado local']),
 'botones':('Botones y callbacks',['CustomButton · +1 / −1 / reinicio','AppBar · segundo reinicio']),
 'estado':('clickCounter',['_CounterFunctionsScreenState','Cambiar valor → setState()']),
 'vista':('Scaffold y contenido',['AppBar · Center · Column · Text','+ verde · − rojo · 0 azul']),
 'configuracion':('pubspec.yaml',['Dependencias · Material Icons','Registro de Architext']),
 'tipografia':('Architext',['assets/fonts/Architex.ttf','Familia aplicada en ThemeData']),
 'prueba':('Prueba de widgets',['Monta MyApp · importa main.dart','Icono pendiente de revisión']),
 'alternativa':('CounterScreen',['Alternativa existente','Import comentado · sin flujo inicial'])}

def card(id,x,y,w,h,title,subs,mini=False):
    nodes[id]['title']=title
    nodes[id]['geometry']=[x,y,w,h]
    cls='node'+(' alternative' if id=='alternativa' else '')+(' event-node' if id in ['botones','estado'] else '')
    svg.append(f'<g class="{cls}" data-node="{id}" role="button" tabindex="0" aria-label="Ver detalles: {esc(title)}" aria-haspopup="dialog" aria-pressed="false">')
    svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="11"/>')
    scale=.55 if mini else .68
    svg.append(f'<g class="icon" aria-hidden="true" transform="translate({x+12} {y+12}) scale({scale})">{icons.get(id,icons["app"])}</g>')
    svg.append(text(x+(34 if mini else 38),y+(24 if mini else 25),title,'mini-title' if mini else 'node-title'))
    for i,line in enumerate(subs): svg.append(text(x+13,y+46+i*16,line,'code-small' if line.startswith('_') else 'sub'))
    svg.append('</g>')

for c in spec['components']:
    id=c['id']; x,y=c['pos']; w,h=c['size']
    if id=='plataformas':
        nodes[id]['title']='Plataformas del proyecto'; nodes[id]['geometry']=[x,y,w,h]
        svg.append(f'<rect class="platform-frame" x="{x}" y="{y}" width="{w}" height="{h}" rx="12"/>')
        svg.append(f'<g class="node platform-heading" data-node="{id}" role="button" tabindex="0" aria-haspopup="dialog" aria-label="Ver detalles: Plataformas del proyecto" aria-pressed="false"><rect x="{x+4}" y="{y+3}" width="{w-8}" height="32" rx="8"/>{text(x+12,y+24,"Plataformas del proyecto","node-title")}</g>')
        for i,(pid,title,*_) in enumerate(platforms): card(pid,x+10+(i%2)*103,y+43+(i//2)*48,95,39,title,[],True)
    else:
        title,subs=copies[id]; card(id,x,y,w,h,title,subs)
card('tipografia',663,78,218,78,*copies['tipografia'])

# Etiquetas centradas en espacios revisados, con máscara independiente de las tarjetas.
label_positions={'abrir':(156,202),'integrar':(304,338),'arrancar':(452,444),'montar':(612,526),'home':(936,517),'arbol':(1123,447),'acciones':(1123,620),'mutacion':(936,735),'rebuild':(936,612),'dependencias':(452,239),'test':(772,444),'fuente':(612,106)}
for e in edges:
    if e['id'] not in label_positions: continue
    x,y=label_positions[e['id']]; w=len(e['label'])*6.5+12
    svg.append(f'<g class="edge-label" data-edge="{e["id"]}"><rect x="{x-w/2}" y="{y-13}" width="{w}" height="18" rx="5"/>{text(x,y,e["label"],"edge-text","middle")}</g>')
svg.append(text(47,540,'UN MISMO CÓDIGO DART','annotation'))
svg.append(text(47,563,'6 configuraciones presentes','sub'))
svg.append(text(47,583,'Compilaciones no verificadas','sub'))
svg.append(text(47,690,'INTERACCIÓN','annotation-green'))
svg.append(text(47,715,'Botón → callback → clickCounter','sub'))
svg.append(text(47,738,'setState() → build() → número y color','sub'))
svg.append(text(47,760,'Click solo para 1; Clicks para el resto','sub'))
svg.append('</g></svg>')
payload={'appRoot':APP_ROOT,'nodes':nodes,'edges':edges,'files':files,'reviewedRef':subprocess.check_output(['git','branch','--show-current'],cwd=APP,text=True).strip(),'remoteCommit':remote['sha'],'localCommit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=APP,text=True).strip()}
template=(HERE/'visor.template.html').read_text('utf-8')
output=template.replace('@@SVG@@',''.join(svg)).replace('@@DATA@@',json.dumps(payload,ensure_ascii=False).replace('</','<\\/')).replace('@@REF@@',ref).replace('@@APP_ROOT@@',APP_ROOT)
OUT.write_text(output,encoding='utf-8')
receipt={'appRoot':APP_ROOT,'specificationSha256':hashlib.sha256((HERE/'contador.archify.json').read_bytes()).hexdigest(),'archifyBaseSha256':hashlib.sha256((HERE/'evidencia/archify_base.html').read_bytes()).hexdigest(),'htmlSha256':hashlib.sha256(OUT.read_bytes()).hexdigest(),'bytes':OUT.stat().st_size,'localCommit':payload['localCommit'],'remoteCommit':remote['sha'],'files':files}
(HERE/'evidencia/fuentes.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'HTML generado: {OUT.name}; {len(nodes)} bloques; {len(files)} archivos comprobados.')
