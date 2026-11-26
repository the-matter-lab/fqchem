"use strict";

// Only paint the moving points here. At rest the SVG owns the complete,
// selectable diagram, with its original arrowheads, source links and styles.
function createProofFlight(canvas, network, nodes, mainSet, owner, edges) {
  const ctx = canvas.getContext("2d");
  const supports = nodes.filter(n => !mainSet.has(n));
  const movingEdges = edges.filter(e => !e.from.main || !e.to.main);
  const emitters = new Set();
  const clamp = t => Math.max(0, Math.min(1, t));
  let palette = {}, theme = null;

  function prepare(width) {
    const chapterMains = new Map();
    for (const n of mainSet) {
      if (!chapterMains.has(n.chapter)) chapterMains.set(n.chapter, []);
      chapterMains.get(n.chapter).push(n);
      n.wave = .20 * clamp(n.x / width) + .05 * ((n.id * .618034) % 1);
    }
    emitters.clear();
    for (const n of supports) {
      // A nearby point can stage an otherwise disconnected result. Only the
      // extracted edges below carry mathematical meaning.
      let anchor = owner.get(n);
      if (!anchor) {
        let best = Infinity;
        for (const candidate of chapterMains.get(n.chapter) || mainSet) {
          const distance = Math.hypot(candidate.x-n.x, candidate.y-n.y);
          if (distance < best) { best = distance; anchor = candidate; }
        }
      }
      n.launch = anchor || n;
      emitters.add(n.launch);
      const seed = (n.id * .61803398875) % 1;
      n.delay = (n.launch.wave || 0) + .12 * seed;
      n.angle = 2 * Math.PI * seed;
    }
  }

  function draw(progress, camera) {
    if (!ctx) return;
    const width = network.clientWidth, height = network.clientHeight;
    const dpr = Math.min(2, window.devicePixelRatio || 1);
    const pw = Math.round(width*dpr), ph = Math.round(height*dpr);
    if (canvas.width !== pw || canvas.height !== ph) {
      canvas.width = pw; canvas.height = ph;
    }
    if (theme !== document.documentElement.dataset.theme) {
      theme = document.documentElement.dataset.theme;
      const css = getComputedStyle(network);
      for (const key of ["general","classical","quantum","pending","edge","focus-ink"])
        palette[key] = css.getPropertyValue("--"+key).trim();
    }
    ctx.resetTransform();
    ctx.clearRect(0,0,pw,ph);
    const {W,H,zoom,tx,ty} = camera;
    const fit = Math.min(width/W,height/H), scale = fit*dpr;
    ctx.setTransform(scale*zoom,0,0,scale*zoom,((width-W*fit)/2+fit*tx)*dpr,((height-H*fit)/2+fit*ty)*dpr);
    for (const n of mainSet) { n.fx=n.x; n.fy=n.y; n.travel=1; }
    for (const n of supports) {
      const t = clamp((progress-n.delay)/.62);
      const a = n.launch, dx = n.x-a.x, dy = n.y-a.y;
      // Underdamped displacement gives the siblings one distinct overshoot.
      // Limit the throw of a dependency that spans the width of the atlas.
      const response = t===1 ? 1 : 1-Math.exp(-5.7*t)*(Math.cos(9.8*t)+.582*Math.sin(9.8*t));
      const k = Math.min(response, 1+19/Math.max(1,Math.hypot(dx,dy)));
      const fan = 17*Math.sin(Math.PI*t)*(1-t)*(1-t);
      n.fx = a.x + k*dx + fan*Math.cos(n.angle);
      n.fy = a.y + k*dy + fan*Math.sin(n.angle);
      n.travel = t;
    }

    // Delay the long crossing arrows until the local branches are readable.
    // Each line follows the moving endpoints of a real dependency.
    const inkOpacity=1-clamp((progress-.84)/.16);
    ctx.lineWidth=.78;
    ctx.strokeStyle=palette.edge;
    for (const local of [true,false]) {
      ctx.globalAlpha = inkOpacity * (local ? .40 : .32*clamp((progress-.57)/.35));
      if (!ctx.globalAlpha) continue;
      ctx.beginPath();
      for (const e of movingEdges) {
        const a=e.from,b=e.to;
        const sameOrigin=a.chapter===b.chapter && (a.launch || a)===(b.launch || b);
        if (sameOrigin!==local) continue;
        if (a.travel<.10 || b.travel<.10 || e.dim) continue;
        ctx.moveTo(a.fx,a.fy); ctx.lineTo(b.fx,b.fy);
      }
      ctx.stroke();
    }
    // Brief expanding rings mark the launch sites in their method color.
    ctx.lineWidth=1.2;
    for (const a of emitters) {
      const t=clamp((progress-(a.wave || 0))/.32);
      if (!t || t===1 || a.dim) continue;
      ctx.globalAlpha=.72*Math.sin(Math.PI*t)*(1-.5*t);
      ctx.strokeStyle=palette[a.kind];
      ctx.beginPath(); ctx.arc(a.x,a.y,a.r+2+10*t,0,2*Math.PI); ctx.stroke();
    }
    // Points gain their readable radius at takeoff, independently of travel.
    for (const n of supports) {
      const t=n.travel;
      if (!t) continue;
      const r=n.r*Math.min(1,t*16)*(1+.40*Math.sin(Math.PI*t)*(1-t));
      ctx.globalAlpha=n.dim ? .18 : 1;
      ctx.fillStyle=palette[n.kind];
      ctx.beginPath(); ctx.arc(n.fx,n.fy,r,0,Math.PI*2); ctx.fill();
      ctx.globalAlpha*=.70;
      ctx.fillStyle="#fff";
      ctx.beginPath(); ctx.arc(n.fx-r*.27,n.fy-r*.32,r*.27,0,Math.PI*2); ctx.fill();
    }
    ctx.globalAlpha=1;
  }
  return {prepare,draw,available:!!ctx};
}
