"""Genera el visor desde código local y la geometría base aceptada por Archify.
Python estándar y Git. No ejecuta Flutter ni realiza peticiones de red.
Configuración única editable: configuracion.json.
"""
from pathlib import Path
import base64
import hashlib
import html
import json
import re
import subprocess

HERE = Path(__file__).resolve().parent
APP = HERE.parent
REPO = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], cwd=APP, text=True).strip())
CONFIG = json.loads((HERE/'configuracion.json').read_text('utf-8'))
assert APP.relative_to(REPO).as_posix() == CONFIG['appPath']
OUT = HERE/'arquitectura_yes_no_app.html'
spec = json.loads((HERE/'yes_no_app.archify.json').read_text('utf-8'))
base = (HERE/'evidencia/archify_base.html').read_text('utf-8')
remote_path = HERE/'evidencia/remoto.json'
remote = json.loads(remote_path.read_text('utf-8-sig')) if remote_path.exists() else {}
assert not remote.get('truncated'), 'Árbol remoto incompleto'
tree = {f['path']: f for f in remote.get('tree', [])}
files, nodes, edges = {}, {}, []

def source(path, start=None, end=None):
    p = APP/path
    assert p.is_file(), path
    binary = p.suffix == '.png'
    lines = [] if binary else p.read_text('utf-8').splitlines()
    if not binary:
        start = start or 1
        end = end or len(lines)
        assert 1 <= start <= end <= len(lines), (path, start, end)
    full = CONFIG['appPath']+'/'+path
    blob = subprocess.check_output(['git','hash-object','--path='+full,str(p)], cwd=REPO, text=True).strip()
    files[full] = dict(local=True, remote=full in tree, sameContent=tree.get(full,{}).get('sha') == blob,
                       lines=None if binary else len(lines), blob=blob, sha256=hashlib.sha256(p.read_bytes()).hexdigest())
    return dict(path=full, start=start, end=end)

def node(id, title, kind, description, symbols=(), refs=(), extra='', snippet=None, subs=(), geometry=None, icon='code', links=()):
    n = dict(title=title,kind=kind,description=description,symbols=list(symbols),files=list(refs),extra=extra,subs=list(subs),icon=icon,links=list(links))
    if geometry: n['geometry']=geometry
    if snippet:
        p,a,b=snippet
        n['snippet']='\n'.join((APP/p).read_text('utf-8').splitlines()[a-1:b])
        n['snippetCaption']=f"{CONFIG['appPath']}/{p} · líneas {a}–{b}"
        n['snippetSource']=dict(path=CONFIG['appPath']+'/'+p,start=a,end=b)
        source(p,a,b)
    nodes[id]=n

main='lib/main.dart'
screen='lib/presentation/Screens/chat/chat_screen.dart'
field='lib/presentation/widgets/shared/message_field_box.dart'
provider='lib/presentation/providers/chat_provider.dart'
helper='lib/config/helpers/get_yes_no_answer.dart'
model='lib/infraestructure/models/yes_no_model.dart'
entity='lib/domain/entities/message.dart'
mine='lib/presentation/widgets/chat/my_message_bubble.dart'
hers='lib/presentation/widgets/chat/her_message_bubble.dart'
theme='lib/config/theme/app_theme.dart'

node('inicio','Flutter · MyApp','Componente · arranque y composición',
     'La base Dart compartida usa Flutter. main() llama runApp(const MyApp()). MyApp registra ChatProvider mediante MultiProvider y ChangeNotifierProvider(create: ...). Dentro configura MaterialApp: título Yes No App, AppTheme(selectedColor: 0).theme() y home: const ChatScreen().',
     ['main()','runApp()','MyApp','MultiProvider','ChangeNotifierProvider','MaterialApp'],
     [source(main,8,25),source('pubspec.yaml',21,37)],
     'Las carpetas agrupan presentación, dominio, infraestructure y configuración. Las dependencias reales atraviesan esas agrupaciones; no hay repositorios, casos de uso separados ni una implementación completa de Clean Architecture.',
     (main,15,24),['main() → runApp(MyApp())','Provider → MaterialApp'],icon='flutter')
node('pantalla','ChatScreen','Componente · presentación',
     'ChatScreen construye Scaffold y AppBar con título Milky chance y avatar NetworkImage. _ChatView observa ChatProvider con context.watch<ChatProvider>(). ListView.builder lee messageList, usa chatScrollController y selecciona HerMessageBubble o MyMessageBubble según message.fromWho. MessageFieldBox.onValue se conecta con chatProvider.sendMessage.',
     ['ChatScreen','_ChatView','context.watch<ChatProvider>()','ListView.builder','message.fromWho'],
     [source(screen,10,28),source(screen,33,59)],
     'La S de Screens es mayúscula en la ruta real. Milky chance y el avatar son elementos visuales: no prueban la existencia de otra persona conectada.',
     (screen,44,58),['_ChatView · observa estado','ListView.builder · onValue'],icon='screen')
node('entrada','MessageFieldBox','Componente · entrada del usuario',
     'El usuario escribe y envía con el botón o el teclado. _sendMessage() aplica trim(), descarta texto vacío, limpia el campo, devuelve el foco y llama widget.onValue(text). El provider vuelve a limpiar y validar el texto.',
     ['MessageFieldBox','_MessageFieldBoxState','_sendMessage()','TextEditingController','FocusNode'],
     [source(field,3,34),source(field,43,56),source(screen,56,59)],
     'dispose() libera TextEditingController y FocusNode. El callback es local; este widget no llama a la API.',
     (field,19,27),['Usuario · botón o teclado','trim() → onValue(text)'],icon='send')
node('estado','ChatProvider','Estado en memoria · ChangeNotifier',
     'sendMessage() crea un Message de FromWho.me, lo agrega a messageList, llama notifyListeners() y solicita mover el scroll. La lista comienza con dos mensajes locales de FromWho.me ya marcados read. herReply() espera getAnswer(), agrega la respuesta y vuelve a notificar. context.watch reconstruye la vista y la burbuja correspondiente.',
     ['ChatProvider','messageList','sendMessage()','herReply()','notifyListeners()','moveScrollToBottom()','ScrollController'],
     [source(provider,5,36),source(provider,63,95)],
     'Los mensajes permanecen en memoria durante la ejecución; no se observa persistencia de conversaciones. moveScrollToBottom espera 100 ms y anima durante 300 ms si hay clientes. dispose() marca _disposed, libera GetYesNoAnswer (Dio) y ScrollController; las guardas evitan actualizaciones posteriores.',
     (provider,63,73),['messageList · notifyListeners()','ScrollController · sin persistencia'],icon='state')
node('palomitas','Estados y palomitas','Estado / datos · simulación local',
     'Message comienza en sent. sendMessage espera 400 ms, cambia a delivered y notifica; espera otros 700 ms, cambia a read y notifica. Después evalúa cleanText.endsWith(\'?\'): solo entonces llama herReply(). Sin ? final, el mensaje se muestra y cambia de estado, pero el flujo termina sin respuesta automática ni consulta a la API.',
     ['MessageStatus.sent','MessageStatus.delivered','MessageStatus.read','Icons.done','Icons.done_all','endsWith(\'?\')'],
     [source(provider,38,60),source(mine,15,16),source(mine,45,58),source(entity,12,18)],
     'Son esperas simuladas en el dispositivo, no confirmaciones de entrega o lectura de un servidor u otra persona. MyMessageBubble usa done para sent y done_all para delivered/read; read se pinta azul claro (0xFF64D8FF).',
     (provider,38,60),['sent → 400 ms → delivered','+700 ms → read · luego evalúa ?','Sin ? → termina sin consulta'],icon='ticks')
node('respuesta','Probabilidades','Componente · GetYesNoAnswer',
     'GetYesNoAnswer.getAnswer() usa una instancia Random y _random.nextInt(100). Elige yes para 0–39, no para 40–79 y maybe para 80–99: 40 % Sí, 40 % No y 20 % Tal vez. Después Dio consulta una imagen compatible con esa elección mediante force.',
     ['GetYesNoAnswer','getAnswer()','Random','nextInt(100)','Dio','DioException'],
     [source(helper,7,29),source(helper,31,60)],
     'Son probabilidades por elección, no cuotas exactas en una secuencia corta. No hay IA ni análisis de la pregunta. data debe ser no nulo, answer debe coincidir con la elección e image debe ser String. Ante DioException o datos no válidos conserva el texto elegido sin GIF. connectTimeout y receiveTimeout son de 10 segundos cada uno, no un límite global de 10 segundos. dispose() cierra Dio con force: true.',
     (helper,17,29),['GetYesNoAnswer · elección local','Sí 40 % · No 40 % · Tal vez 20 %'],icon='dice')
node('api','yesno.wtf/api','Servicio externo · JSON por HTTP',
     'Dio realiza GET https://yesno.wtf/api con queryParameters: {\'force\': answer}. La respuesta JSON puede aportar una URL de imagen; la aplicación valida los datos antes de usarla. La elección ya ocurrió en Dart.',
     ['_dio.get<Map<String, dynamic>>()','queryParameters','force','response.data'],
     [source(helper,10,15),source(helper,33,48)],
     'El código no envía el texto de la pregunta: envía solo force con yes, no o maybe. No es una API propia ni un sistema de mensajería entre dos usuarios. Consultar este diagrama no realiza esta petición.',
     (helper,33,45),['GET · solo force=respuesta','Devuelve JSON con URL de imagen'],icon='globe',links=[['Abrir endpoint del servicio','https://yesno.wtf/api']])
node('conversion','Conversión de respuesta','Modelo · infraestructure',
     'El helper construye YesNoModel directamente con answer, forced: true e image, y llama toMessageEntity(). El modelo traduce yes/no/maybe a Sí/No/Tal vez y crea Message con FromWho.hers. Si image está vacío, imageUrl será null. El Message retorna a herReply().',
     ['YesNoModel','answer','forced','image','toMessageEntity()','FromWho.hers'],
     [source(model,3,24),source(model,26,39),source(helper,50,54)],
     'fromJsonMap() y toJson() existen, pero no se ejecutan en este flujo. Se conserva el nombre real de la carpeta infraestructure. La hora y el estado por defecto los establece el constructor de Message.',
     (model,26,38),['YesNoModel → Message','Sí / No / Tal vez · imageUrl?'],icon='convert')
node('entidad','Message','Entidad · datos compartidos',
     'Message contiene text, imageUrl opcional, fromWho, createdAt y status. FromWho distingue me y hers. MessageStatus define sent, delivered y read. El constructor usa DateTime.now() si no recibe createdAt y sent como estado inicial. formattedTime convierte a hora local y presenta HH:mm.',
     ['Message','FromWho','MessageStatus','createdAt','formattedTime'],
     [source(entity,1,27)],
     'Es una entidad en memoria, no una tabla ni una base de datos. ChatProvider la crea para el usuario; YesNoModel la crea para la respuesta. Las burbujas consumen sus propiedades.',
     (entity,12,25),['text · imageUrl? · fromWho','createdAt · status · HH:mm'],icon='data')
node('burbujas','Burbujas del chat','Componentes · representación visual',
     'MyMessageBubble muestra texto, hora y palomitas del usuario. HerMessageBubble muestra texto y hora de la respuesta; solo agrega _ImageBubble cuando hay una URL no vacía. _ImageBubble usa Image.network, con un texto de carga y un errorBuilder.',
     ['MyMessageBubble','HerMessageBubble','_ImageBubble','Image.network','loadingBuilder','errorBuilder'],
     [source(mine,13,58),source(hers,35,53),source(hers,60,100)],
     'Si la descarga del GIF falla después de obtener la URL, errorBuilder muestra «No se pudo cargar el GIF». Es un fallo distinto al GET JSON de Dio. Las burbujas no eligen respuestas ni contactan a otra persona.',
     (hers,92,99),['MyMessageBubble','HerMessageBubble · GIF opcional'],icon='chat')
node('imagenes','Imágenes remotas','Recursos externos · Internet',
     'Image.network descarga el GIF desde la URL incluida en Message.imageUrl, separadamente del GET JSON de Dio. ChatScreen también usa NetworkImage para el avatar alojado en tse3.mm.bing.net. Ambos recursos cruzan el límite de la aplicación.',
     ['Image.network','NetworkImage','message.imageUrl'],
     [source(hers,71,99),source(screen,17,25)],
     'El avatar es un recurso visual, no autenticación ni identidad real. El visor no descarga el avatar ni los GIF. La URL concreta del GIF depende de la respuesta del servicio.',
     (screen,19,25),['Image.network → GIF','NetworkImage → avatar Bing'],icon='image',links=[['Abrir sitio del recurso del avatar','https://tse3.mm.bing.net']])

platforms=[
 ('android','Android','FlutterActivity · Kotlin',['android/app/src/main/kotlin/com/example/yes_no_app/MainActivity.kt','android/app/src/main/AndroidManifest.xml','android/app/build.gradle.kts'],['MainActivity','FlutterActivity'],'La actividad principal extiende FlutterActivity. Gradle configura la aplicación y el manifiesto registra la actividad. El manifiesto principal SÍ declara android.permission.INTERNET.'),
 ('ios','iOS','FlutterAppDelegate · Swift',['ios/Runner/AppDelegate.swift','ios/Runner/Info.plist','ios/Runner/SceneDelegate.swift'],['AppDelegate','FlutterImplicitEngineDelegate','SceneDelegate'],'AppDelegate integra Flutter y registra plugins al inicializar el motor implícito; SceneDelegate extiende FlutterSceneDelegate. Info.plist configura la aplicación.'),
 ('web','Web','HTML · manifiesto',['web/index.html','web/manifest.json'],['flutter_bootstrap.js','manifest.json'],'index.html aloja el arranque Flutter y contiene recursos de splash. manifest.json declara la aplicación y sus iconos. Este HTML de Flutter es independiente de la documentación de arquitectura.'),
 ('windows','Windows','Ventana nativa · C++',['windows/runner/main.cpp','windows/runner/flutter_window.cpp','windows/CMakeLists.txt'],['wWinMain','DartProject','FlutterWindow','FlutterViewController'],'El ejecutable crea DartProject y FlutterWindow; FlutterViewController aloja la vista. CMake configura la construcción del anfitrión.'),
 ('linux','Linux','GTK · C++',['linux/runner/main.cc','linux/runner/my_application.cc','linux/CMakeLists.txt'],['main','MyApplication','FlDartProject','FlView'],'El punto de entrada inicia MyApplication; GTK aloja la vista creada desde FlDartProject. CMake integra Flutter y el runner.'),
 ('macos','macOS (Mac)','FlutterMacOS · Swift',['macos/Runner/AppDelegate.swift','macos/Runner/MainFlutterWindow.swift','macos/Runner/DebugProfile.entitlements','macos/Runner/Release.entitlements'],['AppDelegate','MainFlutterWindow','FlutterViewController'],'La ventana crea FlutterViewController y registra plugins. Los entitlements habilitan sandbox, pero no contienen com.apple.security.network.client. Revisar esa configuración al validar conectividad en macOS.')]
for i,(id,title,sub,paths,symbols,desc) in enumerate(platforms):
    available=[source(p) for p in paths if (APP/p).is_file()]
    missing=[p for p in paths if not (APP/p).is_file()]
    node(id,title,'Plataforma del proyecto',desc,symbols,available,
         'Integración presente/configurada. No se compiló ni se probó funcionamiento o red en este destino.'+(' Archivos ausentes: '+', '.join(missing) if missing else ''),
         subs=[sub],geometry=[25,130+i*101,200,76],icon=id)

yaml=(APP/'pubspec.yaml').read_text('utf-8')
lock=(APP/'pubspec.lock').read_text('utf-8')
deps=[]
for package in ['provider','dio','cupertino_icons','flutter_launcher_icons','flutter_native_splash','flutter_lints']:
    constraint=re.search(r'^  '+package+r': ([^\n]+)',yaml,re.M).group(1)
    resolved=re.search(r'^  '+package+r':\n(?:(?!^  \w).|\n)*?    version: "([^"]+)"',lock,re.M).group(1)
    deps.append(f'{package}: restricción {constraint}; resuelta {resolved}')
node('configuracion','Dependencias y recursos','Archivos · configuración y generación',
     'pubspec.yaml declara el paquete yes_no_app, versión 1.0.0+1 y SDK Dart ^3.13.4. Flutter, provider, dio y cupertino_icons son dependencias de ejecución. flutter_launcher_icons, flutter_native_splash, flutter_test y flutter_lints son herramientas de desarrollo, pruebas o generación. '+'. '.join(deps)+'. flutter_test procede del SDK; el 0.0.0 del lock no es una versión independiente del SDK Flutter.',
     ['dependencies','dev_dependencies','flutter_launcher_icons','flutter_native_splash'],
     [source('pubspec.yaml',21,50),source('pubspec.yaml',94,122),source('pubspec.lock'),source('web/icons/alien_ogf.png')],
     'Iconos: Android y Web habilitados, iOS false. Splash: Android y Web true, iOS false. El estado actual usa web/icons/alien_ogf.png en image y image_dark, también en android_12; ese archivo existe. La discrepancia assets/icons/alien_ogf.png descrita en el ZIP ya no aparece en la copia actual. La configuración no acredita que la generación del splash sea correcta.',
     ('pubspec.yaml',107,122),['pubspec.yaml / pubspec.lock','Icono alien · herramientas de generación'],[300,835,330,95],icon='config')
node('tema','AppTheme','Componente · tema Material 3',
     'AppTheme selecciona una paleta de siete colores. main.dart usa selectedColor: 0: Color.fromARGB(255, 202, 18, 18), rojo. theme() devuelve ThemeData con useMaterial3: true y colorSchemeSeed.',
     ['AppTheme','selectedColor','ThemeData','useMaterial3','colorSchemeSeed'],
     [source(theme,3,27),source(main,19,23)],
     'Brightness.dark está comentado. El fondo oscuro del diagrama es una decisión de documentación y no indica que la app Flutter tenga un tema oscuro activo. No se reutilizan fuentes ni recursos del contador.',
     (theme,22,27),['Material 3 · índice 0 · rojo','El tema oscuro pertenece al diagrama'],[690,835,330,95],icon='palette')
node('pruebas','Pruebas y observaciones','Archivos · revisión estática pendiente',
     'test/widget_test.dart sigue siendo la prueba predeterminada del contador: monta MyApp, busca 0/1 y pulsa Icons.add. No está adaptada al chat. ios/RunnerTests/RunnerTests.swift y macos/RunnerTests/RunnerTests.swift contienen testExample() sin verificaciones funcionales.',
     ['testWidgets','Icons.add','testExample()','com.apple.security.network.client'],
     [source('test/widget_test.dart',13,29),source('ios/RunnerTests/RunnerTests.swift',5,10),source('macos/RunnerTests/RunnerTests.swift',5,10),source('macos/Runner/DebugProfile.entitlements'),source('macos/Runner/Release.entitlements'),source('android/app/src/main/AndroidManifest.xml',1,2)],
     'No se ejecutaron pruebas Flutter ni compilaciones. Android declara INTERNET. Revisar el permiso de cliente de red de macOS al validar esa plataforma. Las pruebas nativas vacías no proporcionan cobertura de la conversación. Se preservaron los cambios previos en recursos y configuración.',
     ('test/widget_test.dart',16,28),['Test de contador aún sin adaptar','Red macOS pendiente de validar'],[1080,835,330,95],icon='test')
node('git','Git','Desarrollo y documentación · concepto',
     'Git versiona los archivos del repositorio. La rama local revisada es Practica03. Rama y carpeta son conceptos distintos, aunque ambas se llamen Practica03. Se respetaron los cambios existentes y no se realizaron commits, push, merges ni cambios de rama.',
     ['Practica03','main'],extra='No participa en el procesamiento de mensajes. No existe un archivo Git que implemente este concepto.',subs=['Versiona los archivos'],geometry=[25,1010,225,72],icon='git')
node('github','GitHub','Desarrollo y documentación · alojamiento',
     'GitHub aloja ObedGuzmanGuz/Practicas_DMI_230142. Los enlaces de cada panel usan rutas desde la raíz, referencia codeRef y líneas verificadas localmente. Se compara el contenido mediante el árbol Git remoto cuando está disponible.',
     refs=[],extra='Un cambio local sin subir puede diferir del contenido del enlace. El panel indica si coincide con la instantánea remota de Practica03. GitHub no procesa los mensajes del chat.',subs=['Aloja el repositorio'],geometry=[385,1010,225,72],icon='github',links=[['Abrir repositorio',CONFIG['repoUrl']]])
node('pages','GitHub Pages','Desarrollo y documentación · publicación prevista',
     'GitHub Pages puede publicar este HTML estático desde la rama que contenga los archivos y la carpeta /(root). Si la fuente pasa a main, primero deben estar fusionados allí. La rama de publicación y codeRef son configuraciones independientes.',
     ['/(root)','codeRef','appPath'],extra='URL prevista; publicación no verificada. El usuario realizará push, fusión y publicación. Publicar la app Flutter Web es una tarea distinta.',subs=['Publica el HTML · previsto'],geometry=[750,1010,260,72],icon='globe',links=[['Abrir URL prevista de documentación',CONFIG['pagesUrl']]])
node('archify','Archify','Desarrollo y documentación · herramienta utilizada',
     'Se utilizó la habilidad Archify 2.17 y su CLI: especificación architecture, validate y deliver con perfil showcase. La salida original queda intacta en evidencia/archify_base.html. El visor final integra sus rutas principales y amplía la documentación con plataformas y paneles en español.',
     ['architecture','validate','deliver','showcase'],extra='El recibo de Archify acredita la base, no las ampliaciones del visor final. El visor final tiene comprobaciones de navegador y hash propios. La interfaz nativa de la base y su lang usan inglés por la limitación de idiomas de Archify; esta entrega principal usa español.',subs=['Genera esta documentación'],geometry=[1160,1010,250,72],icon='diagram')

copies={
 'inicio':(300,130,230,95),'pantalla':(650,130,230,95),'burbujas':(1000,130,230,95),'imagenes':(1370,130,230,95),
 'entrada':(300,380,230,95),'estado':(650,380,230,95),'respuesta':(1000,380,230,95),'api':(1370,380,230,95),
 'entidad':(300,640,230,95),'palomitas':(650,640,230,112),'conversion':(1000,640,230,95)}
for id,g in copies.items(): nodes[id]['geometry']=g

def edge(id,a,b,label,description,kind='evento',path=None,labelAt=None):
    edges.append(dict(id=id,**{'from':a,'to':b},label=label,description=description,kind=kind,path=path,labelAt=labelAt))

explanations={
 'inicia':'main → runApp(MyApp) → registro de ChatProvider → MaterialApp con AppTheme → ChatScreen.',
 'muestra':'_ChatView selecciona la burbuja mediante message.fromWho y pasa el Message de la lista.',
 'descarga':'_ImageBubble solicita el GIF con Image.network; la imagen cruza el límite de Internet en una descarga independiente del JSON.',
 'envia':'onValue está enlazado a sendMessage; crea Message, lo agrega a messageList, notifica y solicita scroll.',
 'notifica':'notifyListeners provoca reconstrucción mediante context.watch; ListView.builder usa el ScrollController del provider.',
 'simula':'sendMessage cambia sent → delivered (400 ms) → read (otros 700 ms), con notifyListeners en cada cambio.',
 'pregunta':'Solo después de los estados simulados y si cleanText termina en ? se llama herReply() → getAnswer(). Sin ?, no hay consulta.',
 'consulta':'Dio envía GET con force igual a la respuesta elegida; no incluye el texto de la pregunta.',
 'convierte':'Tras validar JSON o capturar DioException, construye YesNoModel directamente y llama toMessageEntity().',
 'crea':'ChatProvider crea Message de FromWho.me e incorpora el objeto a messageList.'}
label_pos={'inicia':(590,177),'muestra':(940,177),'descarga':(1300,177),'envia':(570,415),'notifica':(765,288),'simula':(765,552),'pregunta':(940,427),'consulta':(1300,427),'convierte':(1115,555),'crea':(590,558)}
# Conserva las rutas de Archify con una traslación uniforme de 260 unidades en X.
for e in spec['connections']:
    match=re.search(r'<path\b[^>]*data-edge-id="'+e['id']+r'"[^>]*/>',base)
    assert match,e['id']
    d=re.search(r' d="([^"]+)"',match.group()).group(1)
    # Los renderizadores de esta entrega producen comandos absolutos M/L/Q.
    tokens=re.findall(r'[A-Za-z]|-?\d+(?:\.\d+)?',d)
    cursor=0
    for i,t in enumerate(tokens):
        if t.isalpha():
            assert t in ['M','L','Q'],d
            cursor=0
        else:
            if cursor%2==0:tokens[i]=str(float(t)+260)
            cursor+=1
    edge(e['id'],e['from'],e['to'],'tras read + ?' if e['id']=='pregunta' else e['label'],explanations[e['id']],
         'evento' if e.get('variant')=='emphasis' else 'estructura',' '.join(tokens),label_pos[e['id']])
edge('registra','inicio','estado','registra','ChangeNotifierProvider(create: (_) => ChatProvider()) registra el estado en el árbol.', 'estructura','M530 207 L590 207 L590 257 Q603 266 590 275 L590 333 L690 333 L690 380',(590,315))
edge('contiene','pantalla','entrada','contiene','_ChatView incluye MessageFieldBox y conecta el callback onValue.', 'estructura','M670 225 L670 266 L415 266 L415 380',(500,266))
edge('json','api','respuesta','devuelve JSON','El JSON cruza de Internet al helper. Se comprueba data != null, answer coincidente e image de tipo String.',path='M1410 475 L1410 520 L1190 520 L1190 475',labelAt=(1330,520))
edge('retorno','conversion','estado','retorna a herReply','toMessageEntity() devuelve un Message al helper y herReply() lo agrega a messageList; notifyListeners actualiza la vista.',path='M1000 682 L947 682 L947 500 L850 500 L850 475',labelAt=(947,610))
edge('convierte-entidad','conversion','entidad','convierte a Message','YesNoModel crea Message con texto traducido, FromWho.hers e imageUrl opcional.',path='M1115 735 L1115 785 L415 785 L415 735',labelAt=(760,785))
edge('avatar','pantalla','imagenes','solicita avatar','ChatScreen solicita el recurso visual de tse3.mm.bing.net mediante NetworkImage; no es autenticación.',path='M820 130 L820 55 L1485 55 L1485 130',labelAt=(1160,55))
edge('tema-configura','tema','inicio','configura tema','MyApp usa AppTheme(selectedColor: 0).theme() para configurar MaterialApp.', 'estructura',None,None)
edge('git-github','git','github','versiona','Git versiona los archivos que el usuario puede subir al repositorio GitHub.', 'documentacion','M250 1046 L385 1046',(317,1046))
edge('github-pages','github','pages','publica','Pages publicará los archivos de la rama elegida y /(root), cuando el usuario configure y publique la documentación.', 'documentacion','M610 1046 L750 1046',(680,1046))
edge('archify-pages','archify','pages','genera HTML','Archify genera la documentación base y el visor final la integra para su publicación estática posterior.', 'documentacion','M1160 1046 L1010 1046',(1085,1046))
for i,(id,*_) in enumerate(platforms):
    y=168+i*101
    # Distribución en abanico, rutas separadas: integración, nunca llamadas entre plataformas.
    target_y=143+i*13
    lane=240+i*8
    edge('plataforma-'+id,id,'inicio','integra','El anfitrión integra Flutter y la misma base Dart. La presencia de estos archivos no acredita compilación o funcionamiento.', 'estructura',f'M225 {y} L{lane} {y} L{lane} {target_y} L300 {target_y}',None)

esc=html.escape
def text(x,y,value,cls='sub',anchor='start'):
    return f'<text x="{x}" y="{y}" class="{cls}" text-anchor="{anchor}">{esc(value)}</text>'
icons={
 'code':'<path d="m8 5-7 7 7 7m10-14 7 7-7 7M15 2l-5 20"/>',
 'flutter':'<path d="M22 2 3 20l5 5L27 7M14 15l9 9"/>',
 'screen':'<rect x="3" y="2" width="22" height="21" rx="3"/><path d="M3 8h22M8 13h12M8 18h8"/>',
 'chat':'<path d="M2 2h22v16H10l-8 6zM7 7h12M7 12h8"/>',
 'send':'<path d="m2 3 23 10-23 10 4-10zM6 13h19"/>',
 'state':'<path d="M23 8a11 11 0 1 0 0 10M23 2v6h-6M13 6v8l4 3"/>',
 'ticks':'<path d="m1 14 6 6L22 4M11 20 26 4"/>',
 'dice':'<rect x="2" y="2" width="22" height="22" rx="4"/><circle cx="8" cy="8" r="1"/><circle cx="18" cy="8" r="1"/><circle cx="13" cy="13" r="1"/><circle cx="8" cy="18" r="1"/><circle cx="18" cy="18" r="1"/>',
 'convert':'<path d="M2 7h22l-5-5M24 19H2l5 5M24 7l-5 5M2 19l5-5"/>',
 'data':'<rect x="4" y="1" width="18" height="24" rx="3"/><path d="M8 7h10M8 13h10M8 19h6"/>',
 'globe':'<circle cx="13" cy="13" r="11"/><ellipse cx="13" cy="13" rx="5" ry="11"/><path d="M2 13h22M5 6h16M5 20h16"/>',
 'image':'<rect x="1" y="3" width="24" height="20" rx="3"/><path d="m2 20 7-8 5 5 4-4 7 7"/><circle cx="17" cy="8" r="2"/>',
 'android':'<path d="M3 10h20v11H3zM5 10a7 7 0 0 1 14 0M5 2l3 4m13-4-3 4M8 22v3m10-3v3"/>',
 'windows':'<path d="M2 3h9v9H2zM14 3h9v9h-9zM2 15h9v9H2zM14 15h9v9h-9z"/>',
 'linux':'<path d="M7 12V7a6 6 0 0 1 12 0v5l4 11H3zM9 12l4 3 4-3"/><circle cx="10" cy="8" r="1"/><circle cx="16" cy="8" r="1"/>',
 'macos':'<rect x="1" y="2" width="24" height="17" rx="2"/><path d="M8 24h10m-5-5v5"/>',
 'ios':'<rect x="6" y="1" width="14" height="24" rx="3"/><path d="M10 4h6m-5 18h4"/>',
 'config':'<path d="M2 6h22M2 13h22M2 20h22"/><circle cx="8" cy="6" r="3"/><circle cx="18" cy="13" r="3"/><circle cx="8" cy="20" r="3"/>',
 'palette':'<circle cx="13" cy="13" r="11"/><circle cx="8" cy="8" r="2"/><circle cx="17" cy="8" r="2"/><circle cx="8" cy="17" r="2"/>',
 'test':'<path d="M8 2h10M10 2v8L3 22h20L16 10V2M7 16h12"/>',
 'git':'<path d="m13 1 12 12-12 12L1 13zM8 7l10 10M13 12v7"/><circle cx="8" cy="7" r="2"/><circle cx="18" cy="17" r="2"/>',
 'github':'<path d="M5 22v-4C-1 14 1 4 5 4L7 1l5 3h3l5-3 2 5c4 7 1 12-4 13v5M9 19v5"/>',
 'diagram':'<rect x="8" y="1" width="10" height="7" rx="1"/><path d="M13 8v6M5 14h16M5 14v4M21 14v4"/><rect x="1" y="18" width="8" height="7"/><rect x="17" y="18" width="8" height="7"/>'}
icons['web']=icons['globe']
svg=['<svg id="diagram" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1650 1120" aria-label="Arquitectura de Yes No App: plataformas, chat local, datos y servicios externos"><defs>']
for kind,color in [('estructura','#50d9ec'),('evento','#67e8aa'),('documentacion','#b7a1fa')]:
    svg.append(f'<marker id="{kind}" markerWidth="9" markerHeight="9" refX="8" refY="4.5" orient="auto" markerUnits="userSpaceOnUse"><path d="M0 0L9 4.5L0 9Z" fill="{color}"/></marker>')
svg.append('</defs><g id="world">')
for x,y,w,h,title in [(12,96,225,675,'Plataformas del proyecto'),(288,96,954,710,'Aplicación Flutter / dispositivo'),(1358,96,254,675,'Servicios externos / Internet'),(288,814,1134,132,'Configuración, recursos y observaciones'),(12,982,1410,113,'Desarrollo y documentación')]:
    svg.append(f'<rect class="boundary" x="{x}" y="{y}" width="{w}" height="{h}" rx="15"/>')
    svg.append(text(x+10,y-10,title,'group-label'))
for e in edges:
    if e['path']:svg.append(f'<path class="edge {e["kind"]}" data-edge="{e["id"]}" d="{e["path"]}" marker-end="url(#{e["kind"]})"/>')
for id,n in nodes.items():
    x,y,w,h=n['geometry']
    category='external' if id in ['api','imagenes'] else 'state-node' if id in ['estado','entidad','palomitas'] else 'platform' if id in [p[0] for p in platforms] else 'file-node' if id in ['configuracion','pruebas'] else 'component'
    n['category']=category
    svg.append(f'<g class="node {category}" data-node="{id}" role="button" tabindex="0" aria-label="Ver detalles: {esc(n["title"])}" aria-haspopup="dialog" aria-pressed="false"><rect x="{x}" y="{y}" width="{w}" height="{h}" rx="12"/>')
    svg.append(f'<g class="icon" aria-hidden="true" transform="translate({x+13} {y+14}) scale(.7)">{icons[n["icon"]]}</g>')
    title=n['title']
    svg.append(text(x+38,y+28,title,'node-title'))
    for i,line in enumerate(n['subs']):svg.append(text(x+13,y+53+i*21,line))
    svg.append('</g>')
for e in edges:
    if not e['labelAt']:continue
    x,y=e['labelAt'];w=len(e['label'])*7+14
    svg.append(f'<g class="edge-label" data-edge="{e["id"]}"><rect x="{x-w/2}" y="{y-14}" width="{w}" height="22" rx="5"/>{text(x,y+2,e["label"],"edge-text","middle")}</g>')
svg.append(text(141,754,'6 destinos · misma base Dart','note','middle'))
svg.append(text(1485,588,'JSON ≠ descarga del GIF','note','middle'))
svg.append(text(1485,624,'La pregunta no se transmite.','sub','middle'))
svg.append(text(1485,651,'La elección sucede en Dart.','sub','middle'))
svg.append(text(1485,710,'Sin API propia ni base de datos.','sub','middle'))
svg.append('</g></svg>')
payload=dict(nodes=nodes,edges=edges,files=files,reviewedRef='Practica03',remoteCommit=remote.get('sha','No comprobado'),
             localCommit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=REPO,text=True).strip(),
             alien='data:image/png;base64,'+base64.b64encode((APP/'web/icons/alien_ogf.png').read_bytes()).decode())
template=(HERE/'visor.template.html').read_text('utf-8')
output=template.replace('@@SVG@@',''.join(svg)).replace('@@DATA@@',json.dumps(payload,ensure_ascii=False).replace('</','<\\/')).replace('@@CONFIG@@',json.dumps(CONFIG,ensure_ascii=False))
assert '@@' not in output
OUT.write_text(output,encoding='utf-8')
receipt=dict(appPath=CONFIG['appPath'],codeRef=CONFIG['codeRef'],files=files,localCommit=payload['localCommit'],remoteCommit=payload['remoteCommit'],
             specificationSha256=hashlib.sha256((HERE/'yes_no_app.archify.json').read_bytes()).hexdigest(),
             archifyBaseSha256=hashlib.sha256((HERE/'evidencia/archify_base.html').read_bytes()).hexdigest(),
             htmlSha256=hashlib.sha256(OUT.read_bytes()).hexdigest(),bytes=OUT.stat().st_size,nodes=len(nodes),edges=len(edges))
(HERE/'evidencia/fuentes.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'Generado: {OUT.name}; {len(nodes)} bloques; {len(files)} archivos con rutas verificadas.')
