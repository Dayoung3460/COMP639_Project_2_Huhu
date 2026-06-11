/* ════════════════════════════════════════════════════════════
   home-hero.js — "Live Trap Network" hero canvas
   Decorative canvas of glowing trap lines: traps breathe, pulses
   travel the lines, traps periodically ripple, and you can hover
   or tap a trap for a readout. The line names come from real
   (public) trap lines; the geometry and trap pings are ambient
   artwork. Real numbers (stats readouts, latest-catches ticker)
   are server-rendered — this script never invents catches.
   ════════════════════════════════════════════════════════════ */
(function () {
  "use strict";

  var panel = document.getElementById("heroPanel");
  var canvas = document.getElementById("trapCanvas");
  if (!panel || !canvas || !canvas.getContext) return;
  var ctx = canvas.getContext("2d");
  var tip = document.getElementById("trapTip");
  var reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ── Server data (real line names + real ticker events) ───── */
  var data = { lineNames: [], ticker: [] };
  try {
    var el = document.getElementById("homeData");
    if (el) data = Object.assign(data, JSON.parse(el.textContent));
  } catch (e) { /* decorative — fall through to defaults */ }

  /* ── Theme colours (re-read so theme changes restain the network) ── */
  function hexToRgb(h) {
    h = (h || "").trim().replace("#", "");
    if (h.length === 3) h = h.split("").map(function (c) { return c + c; }).join("");
    var n = parseInt(h, 16);
    return isNaN(n) ? [26, 58, 46] : [(n >> 16) & 255, (n >> 8) & 255, n & 255];
  }
  function mix(rgb, w) { return rgb.map(function (c) { return Math.round(c + (255 - c) * w); }); }
  function rgba(rgb, a) { return "rgba(" + rgb[0] + "," + rgb[1] + "," + rgb[2] + "," + a + ")"; }
  var C = {};
  function refreshColors() {
    var cs = getComputedStyle(document.documentElement);
    var p = hexToRgb(cs.getPropertyValue("--theme-primary") || "#1a3a2e");
    var s = hexToRgb(cs.getPropertyValue("--theme-secondary") || "#c65d3c");
    C = {
      line:    mix(p, 0.62),
      node:    mix(p, 0.72),
      nodeDim: mix(p, 0.45),
      comet:   mix(p, 0.8),
      fire:    s,
    };
  }
  refreshColors();

  /* ── Trap-line geometry (normalised, denser to the right where
        the text overlay leaves room) ───────────────────────────── */
  var GEOMETRY = [
    { p: [[0.50, 0.20], [0.64, 0.11], [0.77, 0.25], [0.92, 0.15]], n: 5 },
    { p: [[0.49, 0.34], [0.61, 0.27], [0.71, 0.41], [0.86, 0.33]], n: 5 },
    { p: [[0.56, 0.50], [0.69, 0.44], [0.81, 0.55], [0.96, 0.47]], n: 6 },
    { p: [[0.40, 0.58], [0.53, 0.66], [0.66, 0.57], [0.80, 0.65]], n: 4 },
    { p: [[0.47, 0.74], [0.61, 0.67], [0.75, 0.79], [0.91, 0.72]], n: 5 },
    { p: [[0.55, 0.88], [0.68, 0.82], [0.80, 0.91], [0.94, 0.85]], n: 4 },
  ];
  var FALLBACK_NAMES = ["Line one", "Line two", "Line three", "Line four", "Line five", "Line six"];

  function bez(p, t) {
    var u = 1 - t;
    var x = u * u * u * p[0][0] + 3 * u * u * t * p[1][0] + 3 * u * t * t * p[2][0] + t * t * t * p[3][0];
    var y = u * u * u * p[0][1] + 3 * u * u * t * p[1][1] + 3 * u * t * t * p[2][1] + t * t * t * p[3][1];
    return [x, y];
  }

  // Build lines (sampled polylines) + nodes
  var SAMPLES = 64;
  var lines = [], nodes = [];
  var trapNo = 1;
  GEOMETRY.forEach(function (def, li) {
    var name = data.lineNames[li] || FALLBACK_NAMES[li];
    var samp = [];
    for (var i = 0; i < SAMPLES; i++) samp.push(bez(def.p, i / (SAMPLES - 1)));
    lines.push({ name: name, samp: samp, offset: Math.random() });
    for (var k = 0; k < def.n; k++) {
      var t = def.n === 1 ? 0.5 : k / (def.n - 1);
      var pt = bez(def.p, t);
      nodes.push({
        nx: pt[0], ny: pt[1], lineName: name,
        phase: Math.random() * Math.PI * 2,
        id: "TR-" + String(trapNo++).padStart(3, "0"),
        fireStart: -1e9,
      });
    }
  });

  /* ── Sizing ───────────────────────────────────────────────── */
  var W = 0, H = 0, dpr = 1;
  function resize() {
    var r = panel.getBoundingClientRect();
    W = r.width; H = r.height;
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    canvas.width = Math.round(W * dpr);
    canvas.height = Math.round(H * dpr);
    canvas.style.width = W + "px";
    canvas.style.height = H + "px";
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    draw(performance.now()); // keep a frame painted even if loop is paused
  }
  function px(n) { return [n.nx * W, n.ny * H]; }

  /* ── Pointer state ────────────────────────────────────────── */
  var mx = -1e3, my = -1e3, hasMouse = false;
  var parX = 0, parY = 0, parTX = 0, parTY = 0;

  panel.addEventListener("mousemove", function (e) {
    var r = panel.getBoundingClientRect();
    mx = e.clientX - r.left; my = e.clientY - r.top; hasMouse = true;
    parTX = (mx / W - 0.5) * 16;
    parTY = (my / H - 0.5) * 12;
    updateTip();
  });
  panel.addEventListener("mouseleave", function () {
    hasMouse = false; mx = my = -1e3; parTX = parTY = 0;
    if (tip) tip.dataset.show = "false";
  });

  function nearestNode(x, y, max) {
    var best = null, bd = max * max;
    for (var i = 0; i < nodes.length; i++) {
      var a = px(nodes[i]);
      var d = (a[0] - x) * (a[0] - x) + (a[1] - y) * (a[1] - y);
      if (d < bd) { bd = d; best = nodes[i]; }
    }
    return best;
  }

  function updateTip() {
    if (!tip || !hasMouse) return;
    var n = nearestNode(mx, my, 24);
    if (!n) { tip.dataset.show = "false"; return; }
    var a = px(n);
    tip.innerHTML = "<b>" + n.id + " · " + n.lineName + "</b>";
    tip.style.left = a[0] + "px";
    tip.style.top = a[1] + "px";
    tip.dataset.show = "true";
  }

  // Tap / click a trap to "check" it — visual ripple only.
  panel.addEventListener("click", function (e) {
    if (e.target.closest(".btn, a, button")) return; // don't fire behind CTAs
    var r = panel.getBoundingClientRect();
    var n = nearestNode(e.clientX - r.left, e.clientY - r.top, 30);
    if (n) ping(n);
  });

  function ping(node) {
    node.fireStart = performance.now();
    if (reduce) {
      // No ambient loop under reduced motion — render this one
      // user-initiated ripple with a short rAF burst.
      var until = performance.now() + 1000;
      (function burst(now) {
        draw(now);
        if (now < until) requestAnimationFrame(burst);
      })(performance.now());
    }
  }

  /* ── Ticker ages — real events, just keep the labels fresh ── */
  function fmtAge(sec) {
    if (sec < 60) return "just now";
    var m = Math.floor(sec / 60);
    if (m < 60) return m + "m ago";
    var h = Math.floor(m / 60);
    if (h < 48) return h + "h ago";
    var d = Math.floor(h / 24);
    if (d < 14) return d + "d ago";
    return Math.floor(d / 7) + "w ago";
  }
  function refreshAges() {
    document.querySelectorAll("#tickerFeed .tick-item").forEach(function (it) {
      var at = Date.parse(it.dataset.at);
      if (isNaN(at)) return;
      var ageEl = it.querySelector(".age");
      if (ageEl) ageEl.textContent = "· " + fmtAge(Math.max(0, Math.round((Date.now() - at) / 1000)));
    });
  }
  refreshAges();
  setInterval(refreshAges, 60000);

  /* ── Drawing ──────────────────────────────────────────────── */
  function draw(now) {
    ctx.clearRect(0, 0, W, H);
    ctx.save();
    ctx.translate(parX, parY);

    // faint trap lines
    ctx.lineCap = "round"; ctx.lineJoin = "round";
    lines.forEach(function (ln) {
      ctx.beginPath();
      for (var i = 0; i < ln.samp.length; i++) {
        var x = ln.samp[i][0] * W, y = ln.samp[i][1] * H;
        if (i) ctx.lineTo(x, y); else ctx.moveTo(x, y);
      }
      ctx.strokeStyle = rgba(C.line, 0.13);
      ctx.lineWidth = 1.2;
      ctx.stroke();
    });

    // travelling pulse "comet" on each line
    if (!reduce) {
      lines.forEach(function (ln) {
        var head = ((now * 0.00006 + ln.offset) % 1);
        var hi = head * (SAMPLES - 1);
        for (var k = 0; k < 11; k++) {
          var idx = Math.floor(hi - k);
          if (idx < 1) break;
          var a = (1 - k / 11);
          var p0 = ln.samp[idx], p1 = ln.samp[idx - 1];
          ctx.beginPath();
          ctx.moveTo(p0[0] * W, p0[1] * H);
          ctx.lineTo(p1[0] * W, p1[1] * H);
          ctx.strokeStyle = rgba(C.comet, a * 0.5);
          ctx.lineWidth = 2.4 * a;
          ctx.stroke();
        }
      });
    }

    // nodes
    nodes.forEach(function (n) {
      var x = n.nx * W, y = n.ny * H;
      var breathe = reduce ? 0 : Math.sin(now * 0.002 + n.phase) * 0.6;
      var r = 3 + breathe;
      // proximity glow
      var prox = 0;
      if (hasMouse) {
        var d = Math.hypot((x + parX) - mx, (y + parY) - my);
        prox = Math.max(0, 1 - d / 110);
      }
      // check-ripple flash
      var ft = (now - n.fireStart) / 950;
      var firing = ft >= 0 && ft < 1;
      if (firing) {
        var rr = 5 + ft * 34;
        ctx.beginPath();
        ctx.arc(x, y, rr, 0, Math.PI * 2);
        ctx.strokeStyle = rgba(C.fire, (1 - ft) * 0.8);
        ctx.lineWidth = 2 * (1 - ft);
        ctx.stroke();
      }
      var col = firing && ft < 0.5 ? C.fire : (prox > 0 ? C.node : C.nodeDim);
      var glow = firing ? 16 : 6 + prox * 12;
      r += prox * 2.2 + (firing ? (1 - ft) * 3 : 0);
      ctx.save();
      ctx.shadowColor = rgba(firing ? C.fire : C.node, 0.9);
      ctx.shadowBlur = glow;
      ctx.beginPath();
      ctx.arc(x, y, r, 0, Math.PI * 2);
      ctx.fillStyle = rgba(col, 0.95);
      ctx.fill();
      ctx.restore();
    });
    ctx.restore();
  }

  /* ── Loop & ambient scheduler ─────────────────────────────── */
  function loop(now) {
    parX += (parTX - parX) * 0.06;
    parY += (parTY - parY) * 0.06;
    draw(now);
    requestAnimationFrame(loop);
  }

  function schedulePing() {
    var delay = 1600 + Math.random() * 2400;
    setTimeout(function () {
      if (!document.hidden) ping(nodes[(Math.random() * nodes.length) | 0]);
      schedulePing();
    }, delay);
  }

  // initial paint immediately (so a frame exists even if rAF is throttled)
  resize();
  window.addEventListener("load", resize);
  if (window.ResizeObserver) new ResizeObserver(resize).observe(panel);
  else window.addEventListener("resize", resize);

  if (!reduce) {
    requestAnimationFrame(loop);
    schedulePing();
    setInterval(refreshColors, 600); // restain if theme variables change
  }
})();
