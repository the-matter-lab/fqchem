"use strict";

const $ = id => document.getElementById(id);
const NS = "http://www.w3.org/2000/svg";
const chapters = new Map(Object.entries({
  StatePrep: "State preparation", Dynamics: "Dynamics", Properties: "Properties",
  Multiscale: "Multiscale", Complexity: "Complexity", Upstream: "Upstream results",
}));
const types = {
  classical: {name: "Classical computing", color: "#b45a29"},
  quantum: {name: "Quantum computing", color: "#306ba0"},
  general: {name: "General theory", color: "#647e60"},
};

// These are method families. Shared analytic identities stay in general theory.
const classicalModules = new Set((
  "AFQMC AmplifierCost ClassicalEnvironments ClusterExpansions Compiler ConfigurationInteraction " +
  "CoupledCluster DMRG DiffusionMonteCarlo DyadicCoefficients FCIQMC Fragments GaussianAuxiliaryField " +
  "HubbardProjection KrylovPropagation LearnedEnvironments LearnedSurrogates MatrixProductStates " +
  "Multireference PathSampling RingPolymer SignProblem SpectralReconstruction SplitOperator " +
  "TimeDependentCI VariationalMonteCarlo"
).split(" "));
const quantumModules = new Set((
  "AaronsonAmbainis AaronsonAmbainisOrbitals AaronsonAmbainisQuery Amplify AmplitudeAmplification " +
  "BoundedErrorReduction ControlledRotations ElectronicStructure ElectronicStructureOperators " +
  "ElectronicStructurePauli GroundStateSearch HHL HistoryHamiltonian LinearCombinationOfUnitaries " +
  "Majority OrbitalSimulation PhaseEstimation PhaseEstimationFilter Qubitization RydbergBlockade " +
  "SlaterDeterminants UniformCircuits VQE VQEMeasurement Wiring"
).split(" "));
const mixedResults = new Map(Object.entries({
  classicalKrylov: "classical", quantumKrylov: "quantum", quantumDeflation: "quantum",
  sampledDiagonalization: "quantum", sampledTangentMetric: "classical",
  neuralAntisymmetry: "classical", transducer_time: "classical",
}));
function methodType(n) {
  if (mixedResults.has(n.short)) return mixedResults.get(n.short);
  if (n.module.startsWith("Qatlib.")) {
    if (n.module.includes(".Foundations.PureStateMath.") || n.module.includes(".BornMetrics.")) return "general";
    return "quantum";
  }
  if (classicalModules.has(n.topic)) return "classical";
  return quantumModules.has(n.topic) ? "quantum" : "general";
}
const aliases = {VariationalMonteCarlo: "VMC", DiffusionMonteCarlo: "DMC", AFQMC: "auxiliary field quantum Monte Carlo",
  HubbardProjection: "AFQMC", GaussianAuxiliaryField: "AFQMC", FCIQMC: "full configuration interaction quantum Monte Carlo",
  MatrixProductStates: "MPS matrix product states", LinearCombinationOfUnitaries: "LCU", PhaseEstimation: "QPE",
  DensityFunctionals: "DFT density functional theory", RayleighRitz: "variational principle", Kitaev: "BQP QMA history Hamiltonian",
  VQE: "variational quantum eigensolver", AaronsonAmbainis: "Aaronson Ambainis"};
const norm = s => s.toLowerCase().replace(/[^a-z0-9]/g, "");
const nodes = [], edges = [], byName = new Map(), byDeclaration = new Map();
for (const entries of graphParts) {
  const mapped = entries.map(n => {
    const identity = n.module + "/" + n.name;
    const existing = byDeclaration.get(identity);
    if (existing) return existing;
    const node = {...n, id: nodes.length, short: n.name.split(".").at(-1), topic: n.module.split(".").at(-1),
      chapter: n.external ? "Upstream" : n.module.startsWith("FQChemKitaev") ? "Complexity" : n.module.split(".")[1],
      before: [], after: []};
    node.kind = methodType(node);
    const terms = Object.entries(aliases).filter(([key]) => node.module.includes(key)).map(([,v]) => v);
    node.match = norm([node.name, node.module, chapters.get(node.chapter), types[node.kind].name, ...terms].join(" "));
    byDeclaration.set(identity,node);
    if (!byName.has(node.name)) byName.set(node.name,node);
    nodes.push(node);
    return node;
  });
  entries.forEach((raw,i) => {
    if (raw.shared) return;
    raw.deps.forEach(([j,kind]) => {
      const from = mapped[j], to = mapped[i];
      edges.push({from,to,kind}); from.after.push(to); to.before.push(from);
    });
  });
}
const groups = new Map([...chapters.keys()].map(key => [key,nodes.filter(n => n.chapter === key)]));
const chapterNeighbors = new Map([...groups].map(([key,members]) =>
  [key,new Set(members.flatMap(n => [n,...n.before,...n.after]))]));
const ordered = [...nodes].sort((a,b) => a.short.localeCompare(b.short) || a.name.localeCompare(b.name));
$("total-nodes").textContent = nodes.length.toLocaleString();
$("total-edges").textContent = edges.length.toLocaleString();

function svg(tag, attrs) {
  const el = document.createElementNS(NS,tag);
  for (const [key,val] of Object.entries(attrs)) el.setAttribute(key,val);
  return el;
}
function html(tag, cls, text) {
  const el = document.createElement(tag);
  if (cls) el.className = cls;
  if (text !== undefined) el.textContent = text;
  return el;
}
function icon(name) {
  const el = svg("svg",{class:"icon","aria-hidden":"true"});
  el.append(svg("use",{href:"#i-"+name}));
  return el;
}

// A deterministic spring layout within each chapter. Only recorded dependencies
// become springs or visible arrows. An orbit of module seeds separates unrelated proofs.
function layoutChapter(members) {
  const topics = [...new Set(members.map(n => n.module))];
  const localEdges = edges.filter(e => e.from.chapter === members[0].chapter && e.to.chapter === e.from.chapter);
  const golden = Math.PI * (3-Math.sqrt(5));
  const size = Math.sqrt(members.length)*14;
  for (const [i,n] of members.entries()) {
    const k = topics.indexOf(n.module), phase = k*golden;
    const spread = size*.74*Math.sqrt((k+.5)/topics.length);
    n.ax = Math.cos(phase)*spread; n.ay = Math.sin(phase)*spread;
    n.lx = n.ax+Math.cos(i*golden)*15; n.ly = n.ay+Math.sin(i*golden)*15;
    n.vx=0; n.vy=0;
  }
  for (let step=0;step<170;step++) {
    for (let i=0;i<members.length;i++) {
      const a=members[i];
      for (let j=i+1;j<members.length;j++) {
        const b=members[j], dx=a.lx-b.lx, dy=a.ly-b.ly;
        const r2=dx*dx+dy*dy+5;
        const force=70/(r2*Math.sqrt(r2));
        a.vx+=dx*force; a.vy+=dy*force; b.vx-=dx*force; b.vy-=dy*force;
      }
    }
    for (const {from:a,to:b} of localEdges) {
      const dx=b.lx-a.lx, dy=b.ly-a.ly;
      const f=.028*(1-14/Math.max(1,Math.hypot(dx,dy)));
      a.vx+=dx*f; a.vy+=dy*f; b.vx-=dx*f; b.vy-=dy*f;
    }
    for (const n of members) {
      n.vx=(n.vx+(n.ax-n.lx)*.014)*.70; n.vy=(n.vy+(n.ay-n.ly)*.014)*.70;
      n.lx+=n.vx; n.ly+=n.vy;
    }
  }
  const xs=members.map(n=>n.lx), ys=members.map(n=>n.ly);
  const x0=Math.min(...xs), y0=Math.min(...ys), w=Math.max(...xs)-x0, h=Math.max(...ys)-y0;
  for (const n of members) {
    n.u=2*(n.lx-x0)/(w||1)-1; n.v=2*(n.ly-y0)/(h||1)-1;
  }
}
for (const members of groups.values()) if (members.length) layoutChapter(members);

const layouts = {
  wide: {StatePrep:[236,154,186,94], Complexity:[657,333,234,114], Dynamics:[151,374,102,61],
    Properties:[500,95,48,28], Multiscale:[366,399,45,27], Upstream:[784,97,91,44]},
  narrow: {StatePrep:[151,145,113,75], Complexity:[353,343,151,104], Dynamics:[102,350,63,46],
    Properties:[308,82,34,24], Multiscale:[108,474,40,22], Upstream:[451,141,62,45]},
};
let W=960,H=500,narrow=false,boxes=layouts.wide;
let active=null, chapter=null, query="", browsing=false, limit=45;
let zoom=1, tx=0, ty=0;
let selectedEdges=new Set(), neighbors=new Set();
const labels=new Map();
for (const e of edges) {
  e.el=svg("path",{"marker-end":"url(#ink-arrow)"});
  $("links").append(e.el);
}
for (const n of nodes) {
  n.r=2.35+Math.min(3.5,Math.sqrt(n.after.length)*.75);
  n.el=svg("circle",{class:"dot",fill:types[n.kind].color,r:n.r,"data-id":n.id});
  $("dots").append(n.el);
}
for (const [key,title] of chapters) {
  const label=svg("text",{class:"map-label","text-anchor":"middle","data-chapter":key});
  label.textContent=title; labels.set(key,label); $("map-labels").append(label);
}
function geometry() {
  narrow=$("plot").clientWidth<570; W=narrow?560:960; H=narrow?540:500;
  boxes=narrow?layouts.narrow:layouts.wide;
  $("network").setAttribute("viewBox",`0 0 ${W} ${H}`);
  for(const [key,members] of groups) {
    const [cx,cy,rx,ry]=boxes[key];
    const label=labels.get(key); label.setAttribute("x",cx); label.setAttribute("y",cy-ry-12);
    for(const n of members) {
      n.x=cx+n.u*rx; n.y=cy+n.v*ry; n.el.setAttribute("cx",n.x); n.el.setAttribute("cy",n.y);
    }
  }
  for (const [i,e] of edges.entries()) {
    const a=e.from,b=e.to,dx=b.x-a.x,dy=b.y-a.y,length=Math.hypot(dx,dy)||1;
    const bx=b.x-dx*(b.r+1.1)/length, by=b.y-dy*(b.r+1.1)/length;
    const bend=a.chapter===b.chapter?0:((i%5)-2)*.028;
    e.el.setAttribute("d",`M${a.x} ${a.y} Q${(a.x+bx)/2-dy*bend} ${(a.y+by)/2+dx*bend} ${bx} ${by}`);
  }
  updateFocusLabel();
}
function drawCamera() {
  $("world").setAttribute("transform",`translate(${tx} ${ty}) scale(${zoom})`);
  $("scale").textContent=Math.round(zoom*100)+"%";
  $("zoom-in").disabled=zoom>=10; $("zoom-out").disabled=zoom<=.65;
  scheduleLabels();
}
function camera(cx,cy,k) { zoom=k; tx=W/2-cx*k; ty=H/2-cy*k; drawCamera(); }
function fit() {
  if (chapter) {
    const [cx,cy,rx,ry]=boxes[chapter];
    const visible=[...chapterNeighbors.get(chapter)];
    const xs=visible.map(n=>n.x), ys=visible.map(n=>n.y);
    const left=Math.min(cx-rx,...xs), right=Math.max(cx+rx,...xs);
    const top=Math.min(cy-ry-12,...ys), bottom=Math.max(cy+ry,...ys);
    camera((left+right)/2,(top+bottom)/2,Math.min(7,W/(right-left+64),H/(bottom-top+56)));
  } else camera(W/2,H/2,1);
}
function transformAt(k,p) {
  const next=Math.max(.65,Math.min(10,k)), ratio=next/zoom;
  tx=p.x-(p.x-tx)*ratio; ty=p.y-(p.y-ty)*ratio; zoom=next; drawCamera();
}
function svgPoint(x,y) {
  return new DOMPoint(x,y).matrixTransform($("network").getScreenCTM().inverse());
}
function zoomCenter(ratio) { transformAt(zoom*ratio,{x:W/2,y:H/2}); }
function updateFocusLabel() {
  const group=$("focus-label"); group.replaceChildren();
  if(!active) return;
  const right=active.x<W*.70;
  const label=svg("text",{x:active.x+(right?8:-8),y:active.y-7,class:"focus-text","text-anchor":right?"start":"end"});
  label.textContent=active.short;
  const ring=svg("circle",{cx:active.x,cy:active.y,r:active.r+2.7,fill:"none",stroke:"#26362d","stroke-width":.9});
  group.append(ring,label);
}
// Reveal names as space becomes available. Bounding boxes in viewBox units
// keep adjacent labels apart, including after a pan or a pinch gesture.
const ranked = [...nodes].sort((a,b)=>(b.before.length+b.after.length)-(a.before.length+a.after.length));
let labelsFrame=0;
function scheduleLabels() {
  if (labelsFrame) return;
  labelsFrame=requestAnimationFrame(()=>{
    labelsFrame=0;
    const layer=$("zoom-labels"); layer.replaceChildren();
    if(zoom<1.5) return;
    const occupied=[];
    const unit=1/Math.max(.2,network.getScreenCTM().a);
    for(const n of ranked) {
      if(n===active || !visibleNode(n)) continue;
      const x=tx+n.x*zoom+(n.r*zoom+3*unit),y=ty+n.y*zoom;
      const width=n.short.length*5.9*unit,height=13*unit;
      if(x<5||y<height||x+width>W-5||y>H-5) continue;
      if(occupied.some(r=>x<r.x+r.w && x+width>r.x && y-height<r.y+height && y+height>r.y-height)) continue;
      occupied.push({x,y,w:width+8*unit});
      const label=svg("text",{x:(x-tx)/zoom,y:(y-ty)/zoom,class:"zoom-text",
        "font-size":10.5*unit/zoom,"stroke-width":3.3*unit/zoom});
      label.textContent=n.short; layer.append(label);
      if(occupied.length>=24) break;
    }
  });
}
function matches(n) { return (!chapter || n.chapter===chapter) && (!query || n.match.includes(query)); }
function visibleNode(n) {
  if(active) return neighbors.has(n);
  return chapter && !query ? chapterNeighbors.get(chapter).has(n) : matches(n);
}
function highlight() {
  neighbors=new Set(active?[active,...active.before,...active.after]:[]);
  selectedEdges=new Set(active?edges.filter(e=>e.from===active||e.to===active):[]);
  for(const n of nodes) {
    const dim=!visibleNode(n);
    n.el.setAttribute("class","dot"+(dim?" dim":"")+(active===n?" selected":active&&neighbors.has(n)?" neighbor":""));
  }
  for(const e of edges) {
    const focus=selectedEdges.has(e);
    const dim=active ? !focus : query ? !matches(e.from)||!matches(e.to) :
      chapter && e.from.chapter!==chapter && e.to.chapter!==chapter;
    e.el.setAttribute("class","edge "+e.kind+(e.from.chapter!==e.to.chapter?" cross":"")+(dim?" dim":"")+(focus?" active":""));
    e.el.setAttribute("marker-end",focus?"url(#focus-arrow)":"url(#ink-arrow)");
    if(focus) $("links").append(e.el);
  }
  for(const [key,label] of labels) label.setAttribute("class","map-label"+(chapter&&key!==chapter?" dim":""));
  $("view-name").textContent=active?active.short:chapter?chapters.get(chapter):query?"Search matches":"Library overview";
  $("details-jump").hidden=!active;
  updateFocusLabel(); scheduleLabels();
}
function row(label,action,options={}) {
  const el=html("button","row"); el.type="button";
  if(options.kind) el.append(html("i","swatch "+options.kind));
  const text=html("span","label",label);
  if(options.subtitle) text.append(html("small","",options.subtitle));
  el.append(text);
  if(options.count!==undefined) el.append(html("span","count",options.count));
  el.append(icon("next")); el.addEventListener("click",action); return el;
}
function sub(label,items) {
  const section=html("section","subsection"); section.append(html("h3","section-title",label),...items); return section;
}
function theoremRow(n,subtitle) {
  const el=row(n.short,()=>select(n),{kind:n.kind,subtitle:subtitle?n.topic:""});
  el.title=n.name; return el;
}
function back() {
  const el=html("button","back"); el.append(icon("back"),"All chapters"); el.onclick=overview; return el;
}
function showPanel(resetScroll=true) {
  const panel=$("panel"); panel.replaceChildren();
  if(active) {
    panel.append(back(),html("h3","detail-title",active.short));
    const key=html("span","key "+active.kind); key.append(html("i"),types[active.kind].name);
    const source=html("a","source-link","Open Lean declaration"); source.href=active.url; source.append(icon("ext"));
    panel.append(key,html("p","detail-module",active.name),source);
    for(const [name,list] of [["Prerequisites",active.before],["Used by",active.after]]) {
      panel.append(sub(name+" · "+list.length,list.length?list.map(n=>theoremRow(n,true)):
        [html("p","empty",active.external&&name==="Prerequisites"?"Upstream proof boundary":"None in this graph.")]));
    }
  } else if(chapter || query || browsing) {
    const list=ordered.filter(matches);
    panel.append(back(),html("h3","section-title",(chapter?chapters.get(chapter):query?"Search results":"All declarations")+" · "+list.length));
    panel.append(...list.slice(0,limit).map(n=>theoremRow(n,true)));
    if(!list.length) panel.append(html("p","empty","No matching theorems. Try a method such as VMC or a Lean name."));
    if(list.length>limit) panel.append(row("Show more",()=>{limit+=45;showPanel(false);},{count:list.length-limit}));
  } else {
    panel.append(html("h3","section-title","Chapters"));
    for(const [key,title] of chapters) {
      panel.append(row(title,()=>selectChapter(key),{count:groups.get(key).length}));
    }
    const examples=[
      ["VMC variational bound","FQChem.StatePrep.VariationalOptimization.VariationalMonteCarlo.variationalBound"],
      ["Circuit-to-energy reduction","FQChem.Complexity.Kitaev.BoundedErrorReduction.transducer_correct"],
    ].flatMap(([title,name])=>{
      const n=byName.get(name);
      return n?[row(title,()=>select(n),{kind:n.kind})]:[];
    });
    panel.append(sub("Trace a proof",examples));
    panel.append(row("Browse all declarations",()=>{browsing=true;showPanel();},{count:nodes.length}));
  }
  if(resetScroll) panel.scrollTop=0;
}
function clearQuery() { query=""; $("search").value=""; limit=45; }
function setHash(value) {
  const target=location.pathname+location.search+(value?"#"+encodeURIComponent(value):"");
  if(target!==location.pathname+location.search+location.hash) history.pushState(null,"",target);
}
function overview(record=true) {
  active=null; chapter=null; browsing=false; clearQuery(); if(record) setHash("");
  fit(); highlight(); showPanel();
}
function selectChapter(key) {
  active=null; chapter=key; browsing=false; clearQuery(); setHash(""); fit(); highlight(); showPanel();
}
function select(n,record=true) {
  active=n; chapter=null; browsing=false; clearQuery();
  if(record) setHash(byName.get(n.name)===n?n.name:n.module+"/"+n.name);
  // Keep the full proof map in context when possible. Bring an off-screen
  // result into view when a search or a dependency link jumps across chapters.
  const sx=tx+n.x*zoom,sy=ty+n.y*zoom;
  if(sx<30||sy<25||sx>W-35||sy>H-30) camera(n.x,n.y,Math.min(zoom,3));
  highlight(); showPanel(); $("tip").hidden=true;
  $("notice").textContent=n.short+". "+n.before.length+" prerequisites. "+n.after.length+" dependent results.";
}
function fromHash() {
  let id=""; try { id=decodeURIComponent(location.hash.slice(1)); } catch {}
  const n=byName.get(id)||byDeclaration.get(id);
  if(n) select(n,false); else overview(false);
}
$("search").addEventListener("input",()=>{
  if(!query&&!chapter) fit();
  query=norm($("search").value.trim()); active=null; browsing=!!query; limit=45;
  setHash(""); highlight(); showPanel();
});
$("search").addEventListener("keydown",e=>{
  if(e.key==="Enter" && query) { const first=ordered.find(matches); if(first) select(first); }
});
document.addEventListener("keydown",e=>{
  if(e.key==="/" && document.activeElement!==$("search") && !e.metaKey && !e.ctrlKey) {e.preventDefault();$("search").focus();}
  if(e.key==="Escape") { overview(); $("tip").hidden=true; }
});
window.addEventListener("hashchange",fromHash);
window.addEventListener("popstate",fromHash);
$("fit").onclick=fit; $("zoom-in").onclick=()=>zoomCenter(1.4); $("zoom-out").onclick=()=>zoomCenter(1/1.4);
$("details-jump").onclick=e=>{e.preventDefault();$("panel").focus();$("panel").scrollIntoView({block:"nearest"});};
const network=$("network");
network.addEventListener("keydown",e=>{
  if(e.key==="+"||e.key==="=") zoomCenter(1.4);
  else if(e.key==="-") zoomCenter(1/1.4);
  else if(e.key==="Home") fit();
  else if(e.key.startsWith("Arrow")) {
    tx+=({ArrowLeft:35,ArrowRight:-35}[e.key]||0); ty+=({ArrowUp:35,ArrowDown:-35}[e.key]||0); drawCamera();
  } else return;
  e.preventDefault();
});
network.addEventListener("wheel",e=>{
  e.preventDefault(); $("tip").hidden=true;
  transformAt(zoom*Math.exp(-Math.sign(e.deltaY)*Math.min(.32,Math.abs(e.deltaY)*.002)),svgPoint(e.clientX,e.clientY));
},{passive:false});
const pointers=new Map(); let pressed=null, dragged=false;
function near(x,y) {
  const p=svgPoint(x,y), lx=(p.x-tx)/zoom, ly=(p.y-ty)/zoom;
  let closest=null, best=Infinity;
  const tolerance=5/(network.getScreenCTM().a*zoom);
  for(const n of nodes) {
    const dist=Math.hypot(n.x-lx,n.y-ly);
    if(dist<=n.r+tolerance && dist<best){closest=n;best=dist;}
  }
  return closest;
}
network.addEventListener("pointerdown",e=>{
  if(e.button!==0) return;
  if(!pointers.size){ pressed={x:e.clientX,y:e.clientY,chapter:e.target.dataset.chapter}; dragged=false; }
  else dragged=true;
  pointers.set(e.pointerId,svgPoint(e.clientX,e.clientY)); network.setPointerCapture(e.pointerId); $("tip").hidden=true;
});
network.addEventListener("pointermove",e=>{
  if(pointers.has(e.pointerId)) {
    const old=pointers.get(e.pointerId), now=svgPoint(e.clientX,e.clientY);
    if(pressed&&Math.hypot(e.clientX-pressed.x,e.clientY-pressed.y)>3) dragged=true;
    const other=[...pointers].find(([id])=>id!==e.pointerId)?.[1];
    if(other) {
      const before=Math.hypot(old.x-other.x,old.y-other.y), after=Math.hypot(now.x-other.x,now.y-other.y);
      if(before>1) transformAt(zoom*after/before,other);
    } else if(dragged) { tx+=now.x-old.x; ty+=now.y-old.y; drawCamera(); }
    pointers.set(e.pointerId,now);
  } else if(e.pointerType!=="touch") {
    const n=e.target.dataset.chapter?null:near(e.clientX,e.clientY),tip=$("tip");
    tip.hidden=!n;
    if(n) {
      const rect=$("plot").getBoundingClientRect(); tip.textContent=n.short+" · "+types[n.kind].name;
      tip.style.left=Math.max(4,Math.min(rect.width-tip.offsetWidth-4,e.clientX-rect.left+12))+"px";
      tip.style.top=Math.max(4,Math.min(rect.height-tip.offsetHeight-4,e.clientY-rect.top+12))+"px";
    }
  }
});
network.addEventListener("pointerup",e=>{
  if(!pointers.delete(e.pointerId)) return;
  if(!dragged&&pressed) {
    if(pressed.chapter) selectChapter(pressed.chapter);
    else {const n=near(e.clientX,e.clientY); if(n)select(n); else if(active)overview();}
  }
  if(!pointers.size) pressed=null;
});
network.addEventListener("pointercancel",e=>{pointers.delete(e.pointerId);dragged=true;});
network.addEventListener("pointerleave",()=>{$("tip").hidden=true;});
new ResizeObserver(()=>{if(($("plot").clientWidth<570)!==narrow){geometry();fit();}}).observe($("plot"));
geometry(); fromHash();
if(location.protocol==="https:") {
  fetch("https://api.github.com/repos/the-matter-lab/fqchem",{credentials:"omit"})
    .then(r=>r.ok?r.json():null).then(repo=>{
      if(Number.isSafeInteger(repo?.stargazers_count)&&repo.stargazers_count>=0)
        $("star-count").textContent=repo.stargazers_count.toLocaleString();
    }).catch(()=>{ /* The export includes the star count at publication. */ });
}
