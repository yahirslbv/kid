import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../logic/editor_provider.dart';
import '../../../l10n/app_localizations.dart';

class Graph3DWebView extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const Graph3DWebView({super.key, required this.isDark, required this.l10n});

  @override
  State<Graph3DWebView> createState() => _Graph3DWebViewState();
}

class _Graph3DWebViewState extends State<Graph3DWebView> {
  late WebViewController _webController;
  bool _isLoaded = false;
  String _lastEquation = '';

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoaded = true),
      ));
    _loadScene('sin(x) * cos(y)');
  }

  @override
  void didUpdateWidget(covariant Graph3DWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      final provider = context.read<EditorProvider>();
      setState(() => _isLoaded = false);
      _loadScene(provider.equation3D);
    }
  }

  void _loadScene(String equation) {
    _lastEquation = equation;
    _webController.loadHtmlString(_buildHtml(_escapeJs(equation), widget.isDark));
  }

  void _updateEquationInPage(String equation) {
    _webController.runJavaScript("updateEquation('${_escapeJs(equation)}')");
  }

  String _escapeJs(String eq) => eq
      .replaceAll('\\', '\\\\')
      .replaceAll("'", "\\'")
      .replaceAll('\n', '');

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    if (provider.equation3D != _lastEquation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isLoaded) {
          _updateEquationInPage(provider.equation3D);
        } else {
          _loadScene(provider.equation3D);
        }
        _lastEquation = provider.equation3D;
      });
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: WebViewWidget(controller: _webController),
        ),
        AnimatedOpacity(
          opacity: _isLoaded ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 400),
          child: IgnorePointer(
            ignoring: _isLoaded,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: widget.isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF0F7FF),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 38, height: 38,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: const Color(0xFF5B9BD5),
                          backgroundColor: widget.isDark
                              ? const Color(0xFF1C3350)
                              : const Color(0xFFD6E8F7),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Inicializando WebGL…',
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.isDark ? Colors.white38 : const Color(0xFFB0CDE8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _buildHtml(String equation, bool isDark) {
    final bg         = isDark ? '#0D1B2A'                : '#F0F7FF';
    final infoBg     = isDark ? 'rgba(21,40,64,0.85)'   : 'rgba(255,255,255,0.85)';
    final infoColor  = isDark ? 'rgba(255,255,255,0.38)': '#6B8CAE';
    final infoBorder = isDark ? '#234060'                : '#D6E8F7';
    final g1         = isDark ? '0x234060'               : '0xD6E8F7';
    final g2         = isDark ? '0x1C3350'               : '0xEBF4FC';
    final dl2c       = isDark ? '0x3A7FC1'               : '0x5B9BD5';
    final wireOp     = isDark ? '.07'                    : '.13';
    final wireClr    = isDark ? '0x1C3350'               : '0xffffff';
    final lblColor   = isDark ? "'#ffffff50'"            : "'#00000055'";

    return '''<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=no"/>
<style>
*{margin:0;padding:0;box-sizing:border-box;}
body{overflow:hidden;background:$bg;}
canvas{display:block;}
#info{position:absolute;bottom:12px;right:12px;background:$infoBg;color:$infoColor;
  font-family:-apple-system,sans-serif;font-size:11px;padding:5px 10px;
  border-radius:8px;border:1px solid $infoBorder;pointer-events:none;
  display:flex;align-items:center;gap:5px;}
#badge{position:absolute;top:12px;left:12px;background:rgba(91,155,213,.12);
  color:#5B9BD5;font-family:-apple-system,sans-serif;font-size:11px;font-weight:700;
  padding:4px 10px;border-radius:8px;border:1px solid rgba(91,155,213,.3);
  pointer-events:none;letter-spacing:.5px;}
#eq{position:absolute;top:12px;right:12px;background:$infoBg;color:#5B9BD5;
  font-family:monospace;font-size:12px;font-weight:600;padding:5px 12px;
  border-radius:8px;border:1px solid $infoBorder;pointer-events:none;
  max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
#err{display:none;position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);
  color:#E53935;font-family:-apple-system,sans-serif;font-size:14px;text-align:center;}
</style>
</head>
<body>
<div id="badge">3D</div>
<div id="eq">z = $equation</div>
<div id="info">
  <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
    <circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/>
  </svg>
  Arrastra · Pellizca para zoom
</div>
<div id="err">Función inválida.<br/>Usa variables x e y.</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<script>
const IS_DARK=${isDark?'true':'false'}, SEG=60;
const scene=new THREE.Scene();
const renderer=new THREE.WebGLRenderer({antialias:true,alpha:true});
renderer.setPixelRatio(Math.min(window.devicePixelRatio,2));
renderer.setSize(window.innerWidth,window.innerHeight);
document.body.appendChild(renderer.domElement);
const camera=new THREE.PerspectiveCamera(50,window.innerWidth/window.innerHeight,.1,1000);
camera.position.set(8,7,8);camera.lookAt(0,0,0);
scene.add(new THREE.AmbientLight(0xffffff,.55));
const dl1=new THREE.DirectionalLight(0xffffff,.9);dl1.position.set(5,10,5);scene.add(dl1);
const dl2=new THREE.DirectionalLight($dl2c,.45);dl2.position.set(-5,-5,-5);scene.add(dl2);
function axis(a,b,c){const g=new THREE.BufferGeometry().setFromPoints([new THREE.Vector3(...a),new THREE.Vector3(...b)]);scene.add(new THREE.Line(g,new THREE.LineBasicMaterial({color:c,linewidth:2})));}
axis([-6,0,0],[6,0,0],0xEF5350);axis([0,-6,0],[0,6,0],0x66BB6A);axis([0,0,-6],[0,0,6],0x42A5F5);
function lbl(t,p){const c=document.createElement('canvas');c.width=64;c.height=64;const x=c.getContext('2d');x.fillStyle=$lblColor;x.font='bold 40px Arial';x.textAlign='center';x.fillText(t,32,48);const s=new THREE.Sprite(new THREE.SpriteMaterial({map:new THREE.CanvasTexture(c),transparent:true}));s.position.set(...p);s.scale.set(.55,.55,.55);scene.add(s);}
lbl('X',[6.8,0,0]);lbl('Y',[0,6.8,0]);lbl('Z',[0,0,6.8]);
scene.add(new THREE.GridHelper(10,10,$g1,$g2));
function heat(t){t=Math.max(0,Math.min(1,t));let r,g,b;
  if(t<.25){const s=t/.25;r=.08*(1-s);g=.39*(1-s)+.67*s;b=.75*(1-s)+.76*s;}
  else if(t<.5){const s=(t-.25)/.25;r=.26*s;g=.67*(1-s)+.63*s;b=.76*(1-s)+.03*s;}
  else if(t<.75){const s=(t-.5)/.25;r=.26*(1-s)+.99*s;g=.63*(1-s)+.85*s;b=.03*(1-s)+.21*s;}
  else{const s=(t-.75)/.25;r=.99*(1-s)+.9*s;g=.85*(1-s)+.22*s;b=.21*(1-s)+.21*s;}
  return new THREE.Color(r,g,b);}
function evalF(eq,x,y){try{const sin=Math.sin,cos=Math.cos,tan=Math.tan,sqrt=Math.sqrt,abs=Math.abs,exp=Math.exp,log=Math.log,pow=Math.pow,PI=Math.PI,E=Math.E,sinh=Math.sinh,cosh=Math.cosh,tanh=Math.tanh,asin=Math.asin,acos=Math.acos,atan=Math.atan,atan2=Math.atan2,ceil=Math.ceil,floor=Math.floor,round=Math.round,sign=Math.sign;return eval(eq);}catch(e){return 0;}}
let mesh,wire;
function build(eq){
  if(mesh){scene.remove(mesh);mesh.geometry.dispose();mesh.material.dispose();}
  if(wire){scene.remove(wire);wire.geometry.dispose();wire.material.dispose();}
  const geo=new THREE.PlaneGeometry(8,8,SEG,SEG);geo.rotateX(-Math.PI/2);
  const pos=geo.attributes.position,clr=new Float32Array(pos.count*3);
  let mn=Infinity,mx=-Infinity;const zv=[];
  for(let i=0;i<pos.count;i++){const x=pos.getX(i),z=pos.getZ(i);let y=evalF(eq,x,z);const s=isFinite(y)&&!isNaN(y)?Math.max(-8,Math.min(8,y)):0;zv.push(s);if(s<mn)mn=s;if(s>mx)mx=s;}
  const rz=mx-mn<.001?1:mx-mn;
  for(let i=0;i<pos.count;i++){pos.setY(i,zv[i]);const c=heat((zv[i]-mn)/rz);clr[i*3]=c.r;clr[i*3+1]=c.g;clr[i*3+2]=c.b;}
  geo.setAttribute('color',new THREE.BufferAttribute(clr,3));geo.computeVertexNormals();
  mesh=new THREE.Mesh(geo,new THREE.MeshPhongMaterial({vertexColors:true,side:THREE.DoubleSide,shininess:70,transparent:true,opacity:.93,specular:new THREE.Color(.08,.08,.08)}));scene.add(mesh);
  wire=new THREE.Mesh(geo,new THREE.MeshBasicMaterial({color:$wireClr,wireframe:true,transparent:true,opacity:$wireOp}));scene.add(wire);}
try{evalF('$equation',0,0);build('$equation');}catch(e){document.getElementById('err').style.display='block';}
let drag=false,pv={x:0,y:0},sp={t:Math.PI/4,p:Math.PI/3.5,r:14},ppd=null;
function upCam(){camera.position.set(sp.r*Math.sin(sp.p)*Math.sin(sp.t),sp.r*Math.cos(sp.p),sp.r*Math.sin(sp.p)*Math.cos(sp.t));camera.lookAt(0,0,0);}upCam();
const el=renderer.domElement;
el.addEventListener('touchstart',e=>{if(e.touches.length===1){drag=true;pv={x:e.touches[0].clientX,y:e.touches[0].clientY};}if(e.touches.length===2){const dx=e.touches[0].clientX-e.touches[1].clientX,dy=e.touches[0].clientY-e.touches[1].clientY;ppd=Math.sqrt(dx*dx+dy*dy);}},{passive:true});
el.addEventListener('touchmove',e=>{e.preventDefault();if(e.touches.length===1&&drag){const dx=e.touches[0].clientX-pv.x,dy=e.touches[0].clientY-pv.y;sp.t-=dx*.008;sp.p=Math.max(.08,Math.min(Math.PI-.08,sp.p+dy*.008));pv={x:e.touches[0].clientX,y:e.touches[0].clientY};upCam();}if(e.touches.length===2&&ppd){const dx=e.touches[0].clientX-e.touches[1].clientX,dy=e.touches[0].clientY-e.touches[1].clientY;const d=Math.sqrt(dx*dx+dy*dy);sp.r=Math.max(3,Math.min(30,sp.r*ppd/d));ppd=d;upCam();}},{passive:false});
el.addEventListener('touchend',()=>{drag=false;ppd=null;});
el.addEventListener('mousedown',e=>{drag=true;pv={x:e.clientX,y:e.clientY};});
el.addEventListener('mousemove',e=>{if(!drag)return;sp.t-=(e.clientX-pv.x)*.008;sp.p=Math.max(.08,Math.min(Math.PI-.08,sp.p+(e.clientY-pv.y)*.008));pv={x:e.clientX,y:e.clientY};upCam();});
el.addEventListener('mouseup',()=>drag=false);
el.addEventListener('wheel',e=>{sp.r=Math.max(3,Math.min(30,sp.r+e.deltaY*.02));upCam();});
window.addEventListener('resize',()=>{camera.aspect=window.innerWidth/window.innerHeight;camera.updateProjectionMatrix();renderer.setSize(window.innerWidth,window.innerHeight);});
function updateEquation(eq){try{evalF(eq,1,1);document.getElementById('eq').textContent='z = '+eq;build(eq);document.getElementById('err').style.display='none';}catch(e){document.getElementById('err').style.display='block';}}
function loop(){requestAnimationFrame(loop);renderer.render(scene,camera);}loop();
</script>
</body>
</html>''';
  }
}