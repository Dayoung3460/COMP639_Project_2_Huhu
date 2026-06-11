/*
 * static/js/map3d.js
 * Innovation Epic: 3D Terrain Map (Three.js r128)
 * Tiaki -- COMP639 Group Project 2, Team Huhu
 *
 * Sets up a Three.js scene with a real-terrain heightmap fetched from
 * Open-Elevation (free, open data), real aerial imagery draped over the
 * terrain as the surface texture (Esri World Imagery XYZ tiles -- free, no
 * API key), and asset markers positioned at
 * their true latitude/longitude.
 */
(function () {
  if (typeof THREE === 'undefined') {
    console.error('Three.js failed to load');
    return;
  }

  const CFG  = window.M3D_CONFIG || {};
  const stage = document.getElementById('m3d-stage');
  if (!stage) return;

  // Super Admins have no session group, so their data requests must carry the
  // selected group id; normal roles fall back to their session group server-side.
  function withGroup(url) {
    if (!CFG.groupId) return url;
    return url + (url.indexOf('?') >= 0 ? '&' : '?') +
      'group_id=' + encodeURIComponent(CFG.groupId);
  }
  const empty = document.getElementById('m3d-empty');
  const popup = document.getElementById('m3d-popup');
  const popupBody = document.getElementById('m3d-popup-body');
  const popupClose = document.getElementById('m3d-popup-close');
  const legendList = document.getElementById('m3d-legend-list');
  const terrainSrcEl = document.getElementById('m3d-terrain-src');
  const terrainRetryBtn = document.getElementById('m3d-terrain-retry');
  const imagerySrcEl = document.getElementById('m3d-imagery-src');
  const imageryReloadBtn = document.getElementById('m3d-imagery-reload');
  const lineSelect = document.getElementById('m3d-line');
  const typeSelect = document.getElementById('m3d-type');
  const daysInput  = document.getElementById('m3d-days');
  const detailSelect = document.getElementById('m3d-detail');
  const elevationSelect = document.getElementById('m3d-elevation');
  const imagerySelect = document.getElementById('m3d-imagery');
  const fullscreenBtn = document.getElementById('m3d-fullscreen');
  const flyBtn = document.getElementById('m3d-flybtn');

  // ---- Scene setup ----
  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0xa8c4e6);
  // Fog distances are set from the terrain extent in buildTerrainMesh so the
  // haze sits well beyond the map rather than washing the whole scene out.
  scene.fog = new THREE.Fog(0xa8c4e6, 8000, 20000);

  const camera = new THREE.PerspectiveCamera(
    55, stage.clientWidth / Math.max(stage.clientHeight, 1), 0.1, 5000
  );
  camera.position.set(0, 220, 320);

  // logarithmicDepthBuffer fixes z-fighting between overlapping markers (and any
  // near-coplanar geometry) when zoomed far out, where standard depth precision
  // collapses across the huge near->far range.
  const renderer = new THREE.WebGLRenderer({ antialias: true, logarithmicDepthBuffer: true });
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(stage.clientWidth, stage.clientHeight);
  stage.appendChild(renderer.domElement);
  const MAX_ANISO = renderer.capabilities.getMaxAnisotropy
    ? renderer.capabilities.getMaxAnisotropy() : 1;
  // Anisotropic + linear filtering kills the moiré "stripes" you get when the
  // aerial photo is viewed at a grazing angle from far out.
  function applyTexFilter(tex) {
    tex.anisotropy = MAX_ANISO;
    tex.minFilter = THREE.LinearFilter;
    tex.magFilter = THREE.LinearFilter;
    tex.generateMipmaps = false;
  }

  // Lights
  const sun  = new THREE.DirectionalLight(0xffffff, 0.9);
  sun.position.set(200, 400, 250);
  scene.add(sun);
  scene.add(new THREE.AmbientLight(0xffffff, 0.5));

  // Resize handler
  window.addEventListener('resize', () => {
    renderer.setSize(stage.clientWidth, stage.clientHeight);
    camera.aspect = stage.clientWidth / Math.max(stage.clientHeight, 1);
    camera.updateProjectionMatrix();
  });

  // Size the stage directly to fill viewport-minus-everything-above. Setting
  // `style.height` with !important bypasses any CSS height (including
  // Bootstrap's container constraints) -- no flex container, no guessing the
  // nav height.
  function fitStageHeight() {
    if (!stage) return;
    const top = stage.getBoundingClientRect().top + window.scrollY;
    const h = Math.max(400, window.innerHeight - top - 4);   // 4px breathing room
    stage.style.setProperty('height', h + 'px', 'important');
    renderer.setSize(stage.clientWidth, stage.clientHeight);
    camera.aspect = stage.clientWidth / Math.max(stage.clientHeight, 1);
    camera.updateProjectionMatrix();
  }
  window.addEventListener('resize', fitStageHeight);
  window.addEventListener('load', fitStageHeight);
  requestAnimationFrame(fitStageHeight);   // run once after first layout

  // ---- Minimal orbit controls (we avoid the extra cdn for OrbitControls
  //      since the artifacts spec warns it isn't on the same CDN, and a
  //      minimal pointer-driven controller is enough for a demo).
  let azim = -0.6, elev = 0.9, dist = 420;
  let maxDist = 2000;       // raised to fit the terrain extent once it's known
  let terrainMaxY = 0;      // highest terrain point, used as a camera floor
  let sceneExtent = 1000;   // terrain size in metres (set when terrain builds)
  let didAutoFrame = false; // first terrain build auto-frames the camera; retries don't
  let elevationQuality = 32; // user-picked elevation grid density (also bound to the dropdown)
  let baseImageryTarget = 1280; // user-picked base aerial photo width in px (bound to dropdown)
  let baseMinH = 0;         // min elevation of the main bbox; used as Y baseline for both meshes
  let detailElevation = null; // close-up elevation grid: {heights, qgrid, centerX, centerZ, widthM, heightM}
  let baseTerrainArgs = null; // { lo, hi, qSize } from the last successful base elevation fetch -- restored to the legend when the detail patch clears
  let baseImageryArgs = null; // { target } from the last successful base imagery load
  // *** ADJUST HERE *** distance-from-ground (metres) below which the sharper
  // detail imagery kicks in: the patch shows once `dist < detailMaxDistM`.
  // Independent of the group's area size. Also bound to the on-page "Sharpen"
  // dropdown. 0 disables the high-res patch entirely.
  let detailMaxDistM = 400;
  // Declared here (not in the terrain section further down) because updateCam()
  // -> surfaceHeightXZ() reads terrainMesh, and updateCam runs once before that
  // section executes; a `let` there would be in its temporal dead zone.
  let terrainMesh = null;
  let terrainHeights = null;   // 2D array [grid][grid] of metres
  const target = new THREE.Vector3(0, 0, 0);
  let isDown = false, panning = false, moved = false;
  let lastX = 0, lastY = 0, downX = 0, downY = 0;
  let suppressCtx = false;
  // Right-drag pans; the context menu would otherwise pop up on release --
  // even off the canvas, because of pointer capture -- so swallow the next one.
  window.addEventListener('contextmenu', (e) => {
    if (suppressCtx) { e.preventDefault(); suppressCtx = false; }
  });
  stage.addEventListener('pointerdown', (e) => {
    // Only engage orbit/pan when the pointer is on the canvas itself. Without
    // this, clicks on overlay UI (the retry button, popup close, legend) get
    // swallowed by pointer-capture and never reach those elements.
    if (e.target !== renderer.domElement) return;
    if (flybyActive) { stopFlyby(); return; }   // interrupt a flyby; one more click drags
    isDown = true; moved = false;
    lastX = downX = e.clientX; lastY = downY = e.clientY;
    panning = (e.button === 2 || e.shiftKey);   // right-drag or Shift-drag pans
    if (e.button === 2) suppressCtx = true;
    stage.setPointerCapture(e.pointerId);
  });
  stage.addEventListener('pointerup',   (e) => {
    isDown = false; stage.releasePointerCapture(e.pointerId);
    if (moved) scheduleDetail();   // refresh the high-detail patch after a drag
  });
  stage.addEventListener('pointermove', (e) => {
    if (!isDown) return;
    const dx = e.clientX - lastX, dy = e.clientY - lastY;
    if (Math.abs(e.clientX - downX) > 4 || Math.abs(e.clientY - downY) > 4) moved = true;
    if (panning) {
      // Grab-to-pan: the point under the cursor stays under the cursor, so
      // dragging the map left moves your viewpoint right.
      const panScale = dist * 0.0011;
      const right    = new THREE.Vector3(Math.cos(azim), 0, -Math.sin(azim));  // screen-right on ground
      const screenUp = new THREE.Vector3(-Math.sin(azim), 0, -Math.cos(azim)); // screen-up on ground
      target.addScaledVector(right,    -dx * panScale);
      target.addScaledVector(screenUp,  dy * panScale);
    } else {
      // Damp the orbit when zoomed in so a small drag doesn't whip the view.
      const rot = 0.004 * Math.max(0.2, Math.min(1, dist / (sceneExtent * 0.5 + 1)));
      azim -= dx * rot;
      // Low minimum tilt so you can drop to a near-ground, look-across view;
      // the camera floor in updateCam() still stops you entering the terrain.
      elev = Math.min(1.45, Math.max(0.04, elev + dy * rot));
    }
    lastX = e.clientX; lastY = e.clientY;
    updateCam();
  });
  stage.addEventListener('wheel', (e) => {
    e.preventDefault();
    if (flybyActive) {
      // During a flyby, the wheel adjusts altitude (FLYBY_HEIGHT_M is the max
      // ceiling, FLYBY_MIN_HEIGHT_M is the floor). Don't touch orbit state.
      flybyAltitude = Math.max(FLYBY_MIN_HEIGHT_M, Math.min(FLYBY_HEIGHT_M,
        flybyAltitude * (1 + Math.sign(e.deltaY) * 0.16)));
      return;
    }
    dist = Math.min(maxDist, Math.max(5, dist * (1 + Math.sign(e.deltaY) * 0.16)));
    updateCam();
    scheduleDetail();
    scheduleTracks();   // track width scales with zoom
  }, { passive: false });
  // Keyboard: arrows pan the target (click the map first to give it focus).
  stage.addEventListener('keydown', (e) => {
    const step = Math.max(25, dist * 0.04);
    if (e.key === 'ArrowLeft')  { target.x -= step; updateCam(); }
    if (e.key === 'ArrowRight') { target.x += step; updateCam(); }
    if (e.key === 'ArrowUp')    { target.z -= step; updateCam(); }
    if (e.key === 'ArrowDown')  { target.z += step; updateCam(); }
  });
  const _look = new THREE.Vector3();
  function updateCam() {
    camera.position.x = target.x + dist * Math.cos(elev) * Math.sin(azim);
    camera.position.z = target.z + dist * Math.cos(elev) * Math.cos(azim);
    // Floor the eye just above the terrain DIRECTLY BELOW it (local, not the
    // whole-map maximum), then lift the look point by the same amount so the
    // view direction is preserved. Using the local height means flat ground no
    // longer "blocks" the zoom the way a global floor did on hilly maps.
    const ground = surfaceHeightXZ(camera.position.x, camera.position.z, terrainMaxY);
    const camY = target.y + dist * Math.sin(elev);
    const lift = Math.max(0, (ground + 2) - camY);
    camera.position.y = camY + lift;
    _look.set(target.x, target.y + lift, target.z);
    camera.lookAt(_look);
  }
  updateCam();

  // ---- World scaling ----
  // We map a small bounding box of lat/lon to local meters: 1 unit ~= 1 meter.
  // bbox is filled once we have data.
  let bbox = null;        // {minLat, maxLat, minLon, maxLon}
  let metersPerLat = 111320;
  let metersPerLon = 111320 * Math.cos((-43.62 * Math.PI) / 180); // lincoln-ish fallback
  // *** ADJUST HERE *** minimum bbox side length in metres so the user always
  // gets some surrounding context (roads, coastline, neighbouring hills)
  // around tightly-grouped assets. Tweak if 5 km feels too big or too small.
  const MIN_BBOX_M = 5000;

  function setBboxFromAssets(assets) {
    const lats = assets.map(a => a.latitude).filter(v => typeof v === 'number');
    const lons = assets.map(a => a.longitude).filter(v => typeof v === 'number');
    if (!lats.length) return false;
    // Inflate by a small margin so the terrain extends beyond the markers
    const padLat = (Math.max(...lats) - Math.min(...lats)) * 0.4 || 0.003;
    const padLon = (Math.max(...lons) - Math.min(...lons)) * 0.4 || 0.003;
    bbox = {
      minLat: Math.min(...lats) - padLat, maxLat: Math.max(...lats) + padLat,
      minLon: Math.min(...lons) - padLon, maxLon: Math.max(...lons) + padLon,
    };
    // Enforce a minimum bbox side -- a tight cluster of assets shouldn't render
    // as a postage-stamp area with no surrounding context. Expand symmetrically
    // around the cluster centre if either side is smaller than MIN_BBOX_M.
    const centerLat = (bbox.minLat + bbox.maxLat) / 2;
    const centerLon = (bbox.minLon + bbox.maxLon) / 2;
    const minHalfLat = (MIN_BBOX_M / 2) / 111320;
    const minHalfLon = (MIN_BBOX_M / 2) / (111320 * Math.cos(centerLat * Math.PI / 180));
    if ((bbox.maxLat - bbox.minLat) < 2 * minHalfLat) {
      bbox.minLat = centerLat - minHalfLat;
      bbox.maxLat = centerLat + minHalfLat;
    }
    if ((bbox.maxLon - bbox.minLon) < 2 * minHalfLon) {
      bbox.minLon = centerLon - minHalfLon;
      bbox.maxLon = centerLon + minHalfLon;
    }
    metersPerLon = 111320 * Math.cos((bbox.minLat + bbox.maxLat) * 0.5 * Math.PI / 180);
    return true;
  }
  function llToScene(lat, lon, height) {
    if (!bbox) return new THREE.Vector3(0, 0, 0);
    const cx = (bbox.minLon + bbox.maxLon) * 0.5;
    const cy = (bbox.minLat + bbox.maxLat) * 0.5;
    return new THREE.Vector3(
      (lon - cx) * metersPerLon,
      height,
      -(lat - cy) * metersPerLat
    );
  }

  // ---- Terrain mesh ----
  const TERRAIN_GRID = 48;   // terrainMesh / terrainHeights are declared up top
  // *** ADJUST HERE *** vertical exaggeration for the terrain; bumps subtle
  // valleys + troughs into visible relief (Lincoln-area is genuinely very flat).
  const VERT_EXAGGERATION = 4.0;

  // Show where the terrain heights came from. The "Retry elevation" button
  // stays visible in every state so you can re-fetch even when a "live" result
  // came back at a smaller density; it's just disabled while a fetch is in
  // flight. Arg meanings: 'loading' -> arg1 = QGRID being tried.
  // 'live' -> arg1 = lo, arg2 = hi, arg3 = QGRID that succeeded.
  let terrainStatusState = 'loading';
  function setTerrainStatus(source, arg1, arg2, arg3) {
    terrainStatusState = source;
    if (terrainSrcEl) {
      if (source === 'loading') {
        terrainSrcEl.textContent = arg1
          ? `Elevation: loading… (trying ${arg1}×${arg1})`
          : 'Elevation: loading…';
        terrainSrcEl.className = 'small mt-1 text-muted';
      } else if (source === 'live') {
        terrainSrcEl.textContent = arg3
          ? `Elevation: live (${arg3}×${arg3}) · ${arg1}–${arg2} m`
          : `Elevation: live · ${arg1}–${arg2} m`;
        terrainSrcEl.className = 'small mt-1 text-success';
      } else {
        terrainSrcEl.textContent = 'Elevation: flat fallback (API unavailable)';
        terrainSrcEl.className = 'small mt-1 text-warning';
      }
    }
    if (terrainRetryBtn) {
      terrainRetryBtn.hidden = false;                          // always shown
      terrainRetryBtn.disabled = (source === 'loading');       // grey while busy
      terrainRetryBtn.textContent = (source === 'loading') ? 'Loading…' : 'Retry';
    }
  }

  // Single attempt at a given density over an arbitrary bbox (defaults to the
  // main `bbox`). Returns the heights array or null.
  async function fetchHeightsAtGrid(qgrid, timeoutMs, bb) {
    const src = bb || bbox;
    const locations = [];
    for (let i = 0; i < qgrid; i++) {
      for (let j = 0; j < qgrid; j++) {
        locations.push({
          latitude:  src.minLat + (i / (qgrid - 1)) * (src.maxLat - src.minLat),
          longitude: src.minLon + (j / (qgrid - 1)) * (src.maxLon - src.minLon),
        });
      }
    }
    try {
      const ctrl = new AbortController();
      const timer = setTimeout(() => ctrl.abort(), timeoutMs);
      let resp;
      try {
        resp = await fetch('https://api.open-elevation.com/api/v1/lookup', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          signal: ctrl.signal,
          body: JSON.stringify({ locations }),
        });
      } finally { clearTimeout(timer); }
      if (resp && resp.ok) {
        const data = await resp.json();
        if (data && Array.isArray(data.results) && data.results.length === qgrid * qgrid) {
          const heights = data.results.map(r => r.elevation);
          // Reject if any point came back null / non-finite -- Open-Elevation
          // returns null for points outside its dataset, which would corrupt
          // the upsample (NaN propagation).
          if (heights.every(h => Number.isFinite(h))) return heights;
          console.warn(`[map3d] ${qgrid}x${qgrid} returned ${heights.filter(h => !Number.isFinite(h)).length} null elevations -- treating as failure.`);
        }
      }
    } catch (e) { /* timeout / network -> null */ }
    return null;
  }

  let isFetchingTerrain = false;
  async function fetchTerrain() {
    if (!bbox || isFetchingTerrain) return;
    isFetchingTerrain = true;
    const grid = TERRAIN_GRID;
    // Progressive density attempts, starting from the user-selected quality
    // and falling back to smaller grids if the API rejects the bigger ones.
    // The mesh is then bilinearly upsampled to the full TERRAIN_GRID.
    const ladder = [64, 48, 32, 16, 8];
    const tries = ladder.filter(n => n <= elevationQuality);
    let q = null, qSize = 0;
    for (const qgrid of tries) {
      setTerrainStatus('loading', qgrid);     // status shows which density is in flight
      console.info(`[map3d] Fetching elevation at ${qgrid}x${qgrid} (${qgrid * qgrid} points)...`);
      q = await fetchHeightsAtGrid(qgrid, 10000);
      if (q) { qSize = qgrid; break; }
      console.warn(`[map3d] Open-Elevation failed at ${qgrid}x${qgrid}, trying smaller...`);
    }
    isFetchingTerrain = false;

    let heights;
    if (!q) {
      heights = new Array(grid * grid).fill(0);
      console.warn('[map3d] Open-Elevation unavailable at all densities -- using flat fallback terrain.');
      setTerrainStatus('fallback');
    } else {
      heights = new Array(grid * grid);
      for (let i = 0; i < grid; i++) {
        for (let j = 0; j < grid; j++) {
          const fi = (i / (grid - 1)) * (qSize - 1), fj = (j / (grid - 1)) * (qSize - 1);
          const i0 = Math.floor(fi), j0 = Math.floor(fj);
          const i1 = Math.min(qSize - 1, i0 + 1), j1 = Math.min(qSize - 1, j0 + 1);
          const di = fi - i0, dj = fj - j0;
          const h00 = q[i0 * qSize + j0], h01 = q[i0 * qSize + j1];
          const h10 = q[i1 * qSize + j0], h11 = q[i1 * qSize + j1];
          heights[i * grid + j] =
            (h00 * (1 - dj) + h01 * dj) * (1 - di) + (h10 * (1 - dj) + h11 * dj) * di;
        }
      }
      const lo = Math.min(...q), hi = Math.max(...q);
      console.info(`[map3d] Terrain from Open-Elevation at ${qSize}x${qSize}: ${lo}-${hi} m elevation.`);
      baseTerrainArgs = { lo, hi, qSize };
      setTerrainStatus('live', lo, hi, qSize);
    }
    terrainHeights = [];
    for (let i = 0; i < grid; i++) {
      terrainHeights.push(heights.slice(i * grid, (i + 1) * grid));
    }
    buildTerrainMesh();
    placeAssets();
    scheduleDetail();   // if we're zoomed in, refresh the close-up patch + elevation
  }

  // Try again when the user takes an action that says "I want detail":
  // changing line / detail setting / clicking the Retry button.
  function maybeRetryTerrain() {
    if (terrainStatusState === 'fallback' && !isFetchingTerrain) fetchTerrain();
  }

  // ---- Aerial imagery drape ----
  // Stitch Esri World Imagery XYZ tiles covering the bbox into a single canvas
  // and use it as the terrain's surface texture, so the ground shows the real
  // aerial photo of the group's area instead of a flat green fill. Free, no
  // API key, and CORS-enabled so the canvas stays untainted.
  const IMAGERY_TPL =
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  const TILE_PX = 256;

  function lon2px(lon, z) { return ((lon + 180) / 360) * TILE_PX * Math.pow(2, z); }
  function lat2px(lat, z) {
    const s = Math.sin((lat * Math.PI) / 180);
    const y = 0.5 - Math.log((1 + s) / (1 - s)) / (4 * Math.PI);
    return y * TILE_PX * Math.pow(2, z);
  }
  function loadImage(url) {
    return new Promise((resolve) => {
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.onload = () => resolve(img);
      img.onerror = () => resolve(null);
      img.src = url;
    });
  }
  async function stitchTiles(bb, targetPx, capPx) {
    // Stitch Esri tiles covering bb into a canvas. Zoom is chosen for a
    // ~targetPx-wide texture, then stepped down so neither side exceeds capPx
    // (which caps the tile count + memory).
    let z = Math.round(Math.log2((targetPx * 360) /
      (Math.max(1e-6, bb.maxLon - bb.minLon) * TILE_PX)));
    z = Math.max(2, Math.min(19, z));
    let px0, px1, py0, py1, w, h;
    for (;;) {
      px0 = lon2px(bb.minLon, z); px1 = lon2px(bb.maxLon, z);
      py0 = lat2px(bb.maxLat, z); py1 = lat2px(bb.minLat, z); // top, bottom
      w = Math.max(1, Math.round(px1 - px0));
      h = Math.max(1, Math.round(py1 - py0));
      if ((w <= capPx && h <= capPx) || z <= 2) break;
      z--;
    }
    const n = Math.pow(2, z);
    const canvas = document.createElement('canvas');
    canvas.width = w; canvas.height = h;
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#6b8e5a';
    ctx.fillRect(0, 0, w, h);
    const tx0 = Math.floor(px0 / TILE_PX), tx1 = Math.floor((px1 - 1e-6) / TILE_PX);
    const ty0 = Math.floor(py0 / TILE_PX), ty1 = Math.floor((py1 - 1e-6) / TILE_PX);
    const jobs = [];
    for (let tx = tx0; tx <= tx1; tx++) {
      for (let ty = ty0; ty <= ty1; ty++) {
        if (ty < 0 || ty >= n) continue;        // clamp latitude tiles
        const wx = ((tx % n) + n) % n;          // wrap longitude tiles
        const url = IMAGERY_TPL
          .replace('{z}', z).replace('{x}', wx).replace('{y}', ty);
        const dx = tx * TILE_PX - px0;
        const dy = ty * TILE_PX - py0;
        jobs.push(loadImage(url).then((img) => { if (img) ctx.drawImage(img, dx, dy); }));
      }
    }
    await Promise.all(jobs);
    return canvas;
  }

  // Mirrors the elevation status pattern: shows current state in the legend
  // and disables the reload button while a load is in flight.
  function setImageryStatus(source, target) {
    if (imagerySrcEl) {
      if (source === 'loading') {
        imagerySrcEl.textContent = target
          ? `Imagery: loading… (${target}px)`
          : 'Imagery: loading…';
        imagerySrcEl.className = 'small mt-1 text-muted';
      } else {
        imagerySrcEl.textContent = `Imagery: live (${target}px)`;
        imagerySrcEl.className = 'small mt-1 text-success';
      }
    }
    if (imageryReloadBtn) {
      imageryReloadBtn.hidden = false;
      imageryReloadBtn.disabled = (source === 'loading');
      imageryReloadBtn.textContent = (source === 'loading') ? 'Loading…' : 'Reload';
    }
  }

  let isLoadingImagery = false;
  async function loadImagery() {
    if (!bbox || !terrainMesh || isLoadingImagery) return;
    isLoadingImagery = true;
    setImageryStatus('loading', baseImageryTarget);
    const mesh = terrainMesh;                          // capture: terrain may rebuild mid-load
    // Cap must exceed the target by ~1.5x so the natural integer zoom level
    // chosen for the target is actually reached (not capped back down to the
    // previous level). Absolute max 6144 keeps the canvas under ~150 MB.
    const cap = Math.min(6144, Math.max(2048, Math.round(baseImageryTarget * 1.5)));
    const canvas = await stitchTiles(bbox, baseImageryTarget, cap);
    isLoadingImagery = false;
    if (terrainMesh !== mesh) return;                  // rebuilt during load; drop
    const tex = new THREE.CanvasTexture(canvas);
    applyTexFilter(tex);
    if (mesh.material.map) mesh.material.map.dispose();
    mesh.material.map = tex;
    mesh.material.color.set(0xffffff);                 // let the photo show true colour
    mesh.material.needsUpdate = true;
    console.info(`[map3d] Base imagery loaded at ${canvas.width}×${canvas.height} (target ${baseImageryTarget}px)`);
    baseImageryArgs = { target: baseImageryTarget };
    setImageryStatus('live', baseImageryTarget);
  }

  // ---- High-detail overlay (dynamic level-of-detail) ----
  // When zoomed in, drape a sharper, higher-zoom photo over just the area in
  // view, on a small terrain-conforming patch, so close-ups gain real detail.
  let detailMesh = null;
  let detailToken = 0;     // guards against an out-of-order async result winning
  let detailTimer = null;
  function clearDetail() {
    if (!detailMesh) return;
    scene.remove(detailMesh);
    detailMesh.geometry.dispose();
    if (detailMesh.material.map) detailMesh.material.map.dispose();
    detailMesh.material.dispose();
    detailMesh = null;
    detailElevation = null;   // close-up elevation cache is also stale
  }
  async function updateDetail() {
    if (!bbox || !terrainMesh) return;
    if (detailMaxDistM <= 0 || dist >= detailMaxDistM) {         // far from the ground: no detail
      console.info(`[map3d] detail OFF (dist=${Math.round(dist)} m, threshold=${detailMaxDistM} m)`);
      const hadDetail = !!detailMesh || !!detailElevation;
      clearDetail();
      if (hadDetail && assetMeshes.length) placeAssets();   // markers fall back to base elevation
      // Restore the legend to whatever the BASE layers loaded as (so the live
      // values for the whole-bbox imagery + elevation come back into view).
      if (hadDetail) {
        if (baseTerrainArgs) setTerrainStatus('live', baseTerrainArgs.lo, baseTerrainArgs.hi, baseTerrainArgs.qSize);
        if (baseImageryArgs) setImageryStatus('live', baseImageryArgs.target);
      }
      return;
    }
    console.info(`[map3d] detail loading (dist=${Math.round(dist)} m, threshold=${detailMaxDistM} m)`);
    // Flip the legend status to "loading" -- same UI as the Retry/Reload buttons.
    setTerrainStatus('loading', elevationQuality);
    setImageryStatus('loading', 3072);   // detail patch's stitch target
    const cx = (bbox.minLon + bbox.maxLon) / 2;
    const cy = (bbox.minLat + bbox.maxLat) / 2;
    const lon = cx + target.x / metersPerLon;                  // view-centre lat/lon
    const lat = cy - target.z / metersPerLat;
    // Detail patch half-size in metres. The visible ground footprint is ~`dist`
    // wide at typical viewing angles, so dist*0.8 covers what you see + a small
    // margin without dragging in the whole bbox. Tweak this multiplier if the
    // patch feels too big or too small.
    const halfM = Math.max(80, dist * 0.8);
    const dLat = halfM / metersPerLat, dLon = halfM / metersPerLon;
    const bb = {
      minLat: Math.max(bbox.minLat, lat - dLat), maxLat: Math.min(bbox.maxLat, lat + dLat),
      minLon: Math.max(bbox.minLon, lon - dLon), maxLon: Math.min(bbox.maxLon, lon + dLon),
    };
    if (bb.maxLat <= bb.minLat || bb.maxLon <= bb.minLon) return;
    const token = ++detailToken;
    // Fetch imagery tiles AND a high-density elevation grid for *just this view*
    // in parallel. Elevation falls progressively if the user's chosen density
    // is too big for the API to serve.
    const elevLadder = [64, 48, 32, 16, 8].filter(n => n <= elevationQuality);
    async function fetchDetailElev() {
      for (const q of elevLadder) {
        const h = await fetchHeightsAtGrid(q, 8000, bb);
        if (h) { console.info(`[map3d] close-up elevation ${q}×${q} for the visible area`); return { heights: h, qgrid: q }; }
      }
      console.warn('[map3d] close-up elevation unavailable; patch will conform to base terrain');
      return null;
    }
    const [canvas, elev] = await Promise.all([
      stitchTiles(bb, 3072, 4096),
      fetchDetailElev(),
    ]);
    if (token !== detailToken || !terrainMesh) return;          // superseded by a newer call
    const tex = new THREE.CanvasTexture(canvas);
    applyTexFilter(tex);
    const GRID = 48;   // conform finely to the terrain so it can't poke through
    const widthM = (bb.maxLon - bb.minLon) * metersPerLon;
    const heightM = (bb.maxLat - bb.minLat) * metersPerLat;
    const ccx = (bb.minLon + bb.maxLon) / 2, ccy = (bb.minLat + bb.maxLat) / 2;
    const centerX = (ccx - cx) * metersPerLon, centerZ = -(ccy - cy) * metersPerLat;
    // Install the close-up elevation BEFORE we build mesh vertices so the
    // detail mesh, markers and paths all read the same fine heights via
    // surfaceHeightXZ. clearDetail() nulls the old one first.
    clearDetail();
    if (elev) {
      detailElevation = {
        heights: elev.heights, qgrid: elev.qgrid,
        centerX, centerZ, widthM, heightM,
      };
    }
    const geo = new THREE.PlaneGeometry(widthM, heightM, GRID - 1, GRID - 1);
    geo.rotateX(-Math.PI / 2);
    const verts = geo.attributes.position;
    for (let k = 0; k < verts.count; k++) {
      const vx = verts.getX(k) + centerX, vz = verts.getZ(k) + centerZ;
      // Take the higher of the two surfaces + a margin so the base never pokes
      // through the detail patch in places where the fine grid dips below the
      // smoothed base (which was showing as "high-def in patches" in flat areas).
      const fineY = surfaceHeightXZ(vx, vz, 0);     // uses detail elevation if available
      const baseY = baseSurfaceHeightXZ(vx, vz, 0); // always the base mesh
      verts.setY(k, Math.max(fineY, baseY) + 0.5);
    }
    verts.needsUpdate = true; geo.computeVertexNormals();
    // polygonOffset makes this patch reliably win the depth test against the
    // base terrain, so the two don't z-fight into high/low-res stripes.
    const mesh = new THREE.Mesh(geo, new THREE.MeshLambertMaterial({
      map: tex, polygonOffset: true, polygonOffsetFactor: -4, polygonOffsetUnits: -4,
    }));
    mesh.position.set(centerX, 0, centerZ);
    detailMesh = mesh;
    scene.add(mesh);
    console.info(`[map3d] detail applied (canvas ${canvas.width}x${canvas.height}, patch ~${Math.round(heightM)}x${Math.round(widthM)} m)`);
    // Update the legend to reflect what the close-up patch actually loaded.
    if (elev) {
      const dLo = Math.min.apply(null, elev.heights);
      const dHi = Math.max.apply(null, elev.heights);
      setTerrainStatus('live', dLo, dHi, elev.qgrid);
    } else if (baseTerrainArgs) {
      setTerrainStatus('live', baseTerrainArgs.lo, baseTerrainArgs.hi, baseTerrainArgs.qSize);
    }
    setImageryStatus('live', canvas.width);
    if (assetMeshes.length) placeAssets();   // markers + paths conform to the close-up elevation
  }
  function scheduleDetail() {
    if (detailTimer) clearTimeout(detailTimer);
    detailTimer = setTimeout(updateDetail, 220);   // debounce: only after movement settles
  }

  function buildTerrainMesh() {
    if (terrainMesh) {
      scene.remove(terrainMesh);
      terrainMesh.geometry.dispose();
      if (terrainMesh.material.map) terrainMesh.material.map.dispose();
      terrainMesh.material.dispose();
    }
    if (!bbox || !terrainHeights) return;
    const widthM = (bbox.maxLon - bbox.minLon) * metersPerLon;
    const heightM = (bbox.maxLat - bbox.minLat) * metersPerLat;
    const geom = new THREE.PlaneGeometry(widthM, heightM, TERRAIN_GRID - 1, TERRAIN_GRID - 1);
    geom.rotateX(-Math.PI / 2);
    const verts = geom.attributes.position;
    // Baseline = min elevation so the mesh sits at y=0 at its lowest.
    let minH = Infinity, maxH = -Infinity;
    for (let i = 0; i < TERRAIN_GRID; i++)
      for (let j = 0; j < TERRAIN_GRID; j++) {
        minH = Math.min(minH, terrainHeights[i][j]);
        maxH = Math.max(maxH, terrainHeights[i][j]);
      }
    terrainMaxY = (maxH - minH) * VERT_EXAGGERATION;
    baseMinH = minH;   // used as the Y baseline by the close-up detail elevation too
    for (let k = 0; k < verts.count; k++) {
      const j = k % TERRAIN_GRID;
      const i = Math.floor(k / TERRAIN_GRID);
      // Data row 0 is the southern edge (minLat), but PlaneGeometry's row 0
      // lands at the northern edge after the rotateX, so flip i. Without this
      // the ground is mirrored N-S against the markers and they sink/float.
      verts.setY(k, (terrainHeights[TERRAIN_GRID - 1 - i][j] - minH) * VERT_EXAGGERATION);
    }
    verts.needsUpdate = true;
    geom.computeVertexNormals();
    const mat = new THREE.MeshLambertMaterial({
      color: 0x6b8e5a, flatShading: false, side: THREE.DoubleSide,
    });
    terrainMesh = new THREE.Mesh(geom, mat);
    scene.add(terrainMesh);
    loadImagery();   // drape the real aerial photo over the terrain (async)
    // Update scene-size-dependent values on every rebuild...
    const extent = Math.max(widthM, heightM);
    sceneExtent = extent;
    clearDetail();                             // any old detail patch is stale
    maxDist = extent * 6;                       // how far out you can zoom
    camera.far = Math.max(5000, maxDist * 2.5); // keep the far plane behind it
    camera.updateProjectionMatrix();
    scene.fog.near = extent * 3;                // haze only well beyond the map
    scene.fog.far  = extent * 8;
    // ...but only auto-frame on the FIRST build, so a retry/quality change
    // doesn't snap the user back to the initial overview view.
    if (!didAutoFrame) {
      target.set(0, 0, 0);
      dist = extent * 1.4;
      elev = 0.85; azim = -0.6;
      didAutoFrame = true;
    }
    updateCam();
  }

  // Look up terrain height at a lat/lon by bilinear interpolation.
  function heightAtLatLon(lat, lon) {
    if (!bbox || !terrainHeights) return 0;
    const fx = (lon - bbox.minLon) / (bbox.maxLon - bbox.minLon);
    const fy = (lat - bbox.minLat) / (bbox.maxLat - bbox.minLat);
    const gx = Math.max(0, Math.min(TERRAIN_GRID - 1.001, fx * (TERRAIN_GRID - 1)));
    const gy = Math.max(0, Math.min(TERRAIN_GRID - 1.001, fy * (TERRAIN_GRID - 1)));
    const i0 = Math.floor(gy), i1 = i0 + 1;
    const j0 = Math.floor(gx), j1 = j0 + 1;
    const dx = gx - j0, dy = gy - i0;
    const h00 = terrainHeights[i0][j0], h01 = terrainHeights[i0][j1];
    const h10 = terrainHeights[i1][j0], h11 = terrainHeights[i1][j1];
    let minH = Infinity;
    for (let i = 0; i < TERRAIN_GRID; i++)
      for (let j = 0; j < TERRAIN_GRID; j++) minH = Math.min(minH, terrainHeights[i][j]);
    const h = (h00 * (1 - dx) + h01 * dx) * (1 - dy) +
              (h10 * (1 - dx) + h11 * dx) * dy;
    return (h - minH) * VERT_EXAGGERATION;
  }

  // Exact surface height at a scene x/z. If a close-up high-density elevation
  // grid is loaded and covers this point, use that (so markers / trees / paths
  // conform to the finer terrain in the area on screen). Otherwise raycast the
  // base terrain mesh.
  const _downRay = new THREE.Raycaster();
  const _downDir = new THREE.Vector3(0, -1, 0);
  const _downOrigin = new THREE.Vector3();
  function detailHeightAtXZ(x, z) {
    if (!detailElevation) return null;
    const de = detailElevation;
    const halfW = de.widthM * 0.5, halfH = de.heightM * 0.5;
    if (x < de.centerX - halfW || x > de.centerX + halfW) return null;
    if (z < de.centerZ - halfH || z > de.centerZ + halfH) return null;
    const fx = (x - (de.centerX - halfW)) / de.widthM;          // 0=west, 1=east
    const fz = (z - (de.centerZ - halfH)) / de.heightM;         // 0=north, 1=south (z grows southward)
    const fLat = 1 - fz;                                        // 0=south (row 0 of the grid), 1=north
    const g = de.qgrid;
    const gi = fLat * (g - 1), gj = fx * (g - 1);
    const i0 = Math.floor(gi), j0 = Math.floor(gj);
    const i1 = Math.min(g - 1, i0 + 1), j1 = Math.min(g - 1, j0 + 1);
    const di = gi - i0, dj = gj - j0;
    const h00 = de.heights[i0 * g + j0], h01 = de.heights[i0 * g + j1];
    const h10 = de.heights[i1 * g + j0], h11 = de.heights[i1 * g + j1];
    const raw = (h00 * (1 - dj) + h01 * dj) * (1 - di) + (h10 * (1 - dj) + h11 * dj) * di;
    return (raw - baseMinH) * VERT_EXAGGERATION;
  }
  function surfaceHeightXZ(x, z, fallback) {
    const dh = detailHeightAtXZ(x, z);
    if (dh != null) return dh;
    return baseSurfaceHeightXZ(x, z, fallback);
  }
  // Same as surfaceHeightXZ but explicitly ignores the close-up detail grid
  // (always raycasts the base mesh). Used when we need to compare detail vs
  // base elevations to keep the detail patch from sinking below the base.
  function baseSurfaceHeightXZ(x, z, fallback) {
    if (!terrainMesh) return fallback;
    _downOrigin.set(x, terrainMaxY + 10000, z);
    _downRay.set(_downOrigin, _downDir);
    const hit = _downRay.intersectObject(terrainMesh, false)[0];
    return hit ? hit.point.y : fallback;
  }

  // ---- Routes between same-line stations ----
  // Connect each line's assets in code order and lay a flat ribbon over the
  // terrain (not a tube), so it reads as a walkable track on the ground. The
  // ribbon width scales with zoom so it stays visible far out and thin close up.
  let pathGroup = new THREE.Group();
  scene.add(pathGroup);
  let lastShown = [];
  let tracksTimer = null;
  function pathHalfWidth() { return Math.max(1, dist * 0.004); }
  function buildPaths(shown) {
    while (pathGroup.children.length) {
      const c = pathGroup.children.pop();
      c.geometry.dispose(); c.material.dispose();
    }
    if (!terrainMesh) return;
    const byLine = {};
    shown.forEach(a => { (byLine[a.line_id] = byLine[a.line_id] || []).push(a); });
    const halfW = pathHalfWidth();
    Object.keys(byLine).forEach(lid => {
      const stns = byLine[lid].slice().sort((p, q) =>
        String(p.code).localeCompare(String(q.code), undefined, { numeric: true }));
      if (stns.length < 2) return;
      // Centre-line, draped over the terrain. Sample roughly every 5m so the
      // ribbon hugs hills instead of cutting straight through their crests.
      const pts = [];
      for (let k = 0; k < stns.length - 1; k++) {
        const A = llToScene(stns[k].latitude, stns[k].longitude, 0);
        const B = llToScene(stns[k + 1].latitude, stns[k + 1].longitude, 0);
        const segLen = Math.hypot(B.x - A.x, B.z - A.z);
        const steps = Math.max(2, Math.min(120, Math.round(segLen / 5)));
        for (let s = (k === 0 ? 0 : 1); s <= steps; s++) {   // skip dup at joins
          const f = s / steps;
          const x = A.x + (B.x - A.x) * f, z = A.z + (B.z - A.z) * f;
          pts.push(new THREE.Vector3(x, surfaceHeightXZ(x, z, 0) + 0.6, z));
        }
      }
      if (pts.length < 2) return;
      // Flat ribbon: offset each centre point left/right in the ground plane.
      const pos = [], idx = [];
      for (let i = 0; i < pts.length; i++) {
        const a = pts[Math.max(0, i - 1)], b = pts[Math.min(pts.length - 1, i + 1)];
        let dx = b.x - a.x, dz = b.z - a.z;
        const len = Math.hypot(dx, dz) || 1; dx /= len; dz /= len;
        const ox = -dz * halfW, oz = dx * halfW;   // perpendicular, in the ground plane
        const P = pts[i];
        pos.push(P.x + ox, P.y, P.z + oz);          // left edge
        pos.push(P.x - ox, P.y, P.z - oz);          // right edge
      }
      for (let i = 0; i < pts.length - 1; i++) {
        const a = 2 * i, b = 2 * i + 1, c = 2 * i + 2, d = 2 * i + 3;
        idx.push(a, b, c, b, d, c);
      }
      const geo = new THREE.BufferGeometry();
      geo.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
      geo.setIndex(idx);
      geo.computeVertexNormals();
      const mat = new THREE.MeshBasicMaterial({
        color: 0xffd23f, side: THREE.DoubleSide,
        polygonOffset: true, polygonOffsetFactor: -8, polygonOffsetUnits: -8,
      });
      pathGroup.add(new THREE.Mesh(geo, mat));
    });
  }
  function scheduleTracks() {
    if (tracksTimer) clearTimeout(tracksTimer);
    tracksTimer = setTimeout(() => buildPaths(lastShown), 120);
  }

  // ---- Assets ----
  let assetGroup = new THREE.Group();
  scene.add(assetGroup);
  let assetData = [];
  let assetMeshes = [];

  function placeAssets() {
    assetGroup.clear ? assetGroup.clear() : (function () {
      while (assetGroup.children.length) assetGroup.remove(assetGroup.children[0]);
    })();
    assetMeshes = [];
    if (!assetData.length) { empty.hidden = false; lastShown = []; buildPaths([]); return; }
    empty.hidden = true;
    const trapGeo = new THREE.BoxGeometry(2.2, 2.2, 2.2);
    trapGeo.translate(0, 1.1, 0);   // origin at the base so it sits on the
    const bsGeo   = new THREE.CylinderGeometry(1.2, 1.2, 3.0, 12);
    bsGeo.translate(0, 1.5, 0);     // ground no matter how it's scaled
    const sel = (lineSelect && lineSelect.value) ? parseInt(lineSelect.value, 10) : null;
    const typeFilter = typeSelect ? typeSelect.value : '';
    const shown = assetData.filter(a =>
      a.latitude != null && a.longitude != null &&
      !(sel && a.line_id !== sel) && !(typeFilter && a.line_type !== typeFilter));
    const s0 = markerViewScale();
    shown.forEach(a => {
      const flat = llToScene(a.latitude, a.longitude, 0);
      // Seat markers a little above the surface so the bounce doesn't dip into
      // the ground (the detail-imagery patch sits ~0.1m above the base terrain).
      const y = surfaceHeightXZ(flat.x, flat.z, heightAtLatLon(a.latitude, a.longitude)) + 0.4;
      const geo = a.asset_type === 'trap' ? trapGeo : bsGeo;
      const mat = new THREE.MeshLambertMaterial({ color: new THREE.Color(a.colour || '#9ec5fe') });
      const m = new THREE.Mesh(geo, mat);
      m.position.set(flat.x, y, flat.z);     // base sits on the terrain surface
      m.scale.setScalar(s0);                 // constant on-screen size (kept in animate)
      m.userData = a;
      m._baseY = y;
      m._bounce = true;                      // all markers bob in place
      m._phase = Math.random() * Math.PI * 2;
      assetGroup.add(m);
      assetMeshes.push(m);
    });
    lastShown = shown;
    buildPaths(shown);
  }

  // ---- Legend ----
  function renderLegend(items) {
    legendList.innerHTML = '';
    items.forEach(it => {
      const li = document.createElement('li');
      li.innerHTML = `<span class="sw" style="background:${it.colour}"></span><span>${it.label}</span>`;
      legendList.appendChild(li);
    });
  }

  // ---- Marker picking ----
  const raycaster = new THREE.Raycaster();
  const ndc = new THREE.Vector2();
  stage.addEventListener('click', (e) => {
    // Click target is the canvas in the normal case, but setPointerCapture on
    // the stage means a synthesized click sometimes fires with the stage itself
    // as target -- accept either. Real overlay UI (buttons, selects, the
    // topbar) has a more specific element as target and is rejected here.
    if (e.target !== renderer.domElement && e.target !== stage) return;
    if (moved) return;   // this was a drag (orbit/pan), not a marker click
    const rect = stage.getBoundingClientRect();
    ndc.x =  ((e.clientX - rect.left) / rect.width)  * 2 - 1;
    ndc.y = -((e.clientY - rect.top)  / rect.height) * 2 + 1;
    raycaster.setFromCamera(ndc, camera);
    const hit = raycaster.intersectObjects(assetMeshes, false)[0];
    if (!hit) return;
    const a = hit.object.userData;
    const ops = (a.operators && a.operators.length) ? a.operators.join(', ') : '(none assigned)';
    const days = Math.max(1, parseInt(daysInput.value, 10) || 30);
    popupBody.innerHTML =
      `<strong>${a.code}</strong> <span class="badge bg-secondary">${a.asset_type === 'trap' ? 'Trap' : 'Bait station'}</span><br>` +
      `Operators: ${ops}<br>` +
      `Line: <strong>${a.line_name}</strong><br>` +
      `Activity last ${days} days: ${a.activity}<br>` +
      `Last check: ${a.last_check ? a.last_check.substring(0,10) : '-'}<br>` +
      `<a href="${CFG.detailUrlTpl}/${a.line_id}" class="btn btn-sm btn-outline-success mt-1">Open line records</a>`;
    popup.classList.add('show');
  });
  popupClose.addEventListener('click', () => popup.classList.remove('show'));

  // ---- Data loading ----
  async function loadGroupData() {
    const url = withGroup(`${CFG.dataUrl}?days=${encodeURIComponent(daysInput.value)}`);
    const r = await fetch(url, { credentials: 'same-origin' });
    if (!r.ok) return;
    const j = await r.json();
    assetData = j.assets || [];
    renderLegend(j.legend || []);
    if (setBboxFromAssets(assetData)) {
      await fetchTerrain();   // builds terrain + markers; trees appear once zoomed in
      maybeApplyInitialLineFromUrl();
    } else {
      empty.hidden = false;
    }
  }

  // If the user landed here via "View in 3D" on a Line detail page, the URL
  // carries ?line=<id>. Pre-select the focus dropdown and frame that line.
  // Guarded so changing the Days input (which re-runs loadGroupData) does
  // not yank the camera back to the deep-linked line every time.
  let initialLineApplied = false;
  function maybeApplyInitialLineFromUrl() {
    if (initialLineApplied) return;
    initialLineApplied = true;
    const params = new URLSearchParams(window.location.search);
    const lineId = params.get('line');
    if (!lineId) return;
    const opt = lineSelect.querySelector(`option[value="${CSS.escape(lineId)}"]`);
    if (!opt) return;
    lineSelect.value = lineId;
    focusLine(lineId);
  }

  async function focusLine(lineId) {
    if (!lineId) { placeAssets(); return; }
    const tpl = withGroup(CFG.lineDataUrl.replace(/0\.json$/, `${lineId}.json`));
    const r = await fetch(tpl, { credentials: 'same-origin' });
    if (!r.ok) { placeAssets(); return; }
    const j = await r.json();
    // Just re-filter to this line's assets in the existing view; the
    // bbox stays the same so terrain doesn't re-fetch.
    placeAssets();
    if (j.bbox) {
      // Auto-frame this line: move the camera target to its centre
      const cLat = (j.bbox.minLat + j.bbox.maxLat) / 2;
      const cLon = (j.bbox.minLon + j.bbox.maxLon) / 2;
      const ctr = llToScene(cLat, cLon, heightAtLatLon(cLat, cLon));
      target.copy(ctr);
      dist = Math.max(
        (j.bbox.maxLat - j.bbox.minLat) * 111320,
        (j.bbox.maxLon - j.bbox.minLon) * metersPerLon
      ) * 2.5;
      updateCam();
      scheduleDetail();    // focusing a line zooms in -> refresh detail + trees
      maybeRetryTerrain();  // user is changing context -> retry elevation if it failed earlier
    }
  }

  function savePrefs() {
    const fd = new FormData();
    fd.append('activity_days', daysInput.value);
    fetch(CFG.prefsUrl, { method: 'POST', body: fd, credentials: 'same-origin' });
  }

  lineSelect.addEventListener('change', () => focusLine(lineSelect.value));
  typeSelect.addEventListener('change', () => placeAssets());
  daysInput.addEventListener('change', () => { savePrefs(); loadGroupData(); });
  if (detailSelect) {
    detailSelect.value = String(detailMaxDistM);   // reflect the JS default
    detailSelect.addEventListener('change', () => {
      detailMaxDistM = parseFloat(detailSelect.value) || 0;
      updateDetail();      // apply immediately at the current zoom
      maybeRetryTerrain(); // user wants detail -> retry elevation if it failed
    });
  }
  if (terrainRetryBtn) {
    terrainRetryBtn.addEventListener('click', () => fetchTerrain());
  }
  if (elevationSelect) {
    elevationSelect.value = String(elevationQuality);   // reflect the JS default
    elevationSelect.addEventListener('change', () => {
      elevationQuality = parseInt(elevationSelect.value, 10) || 32;
      fetchTerrain();   // re-fetch at the new density (no camera reset; see buildTerrainMesh)
    });
  }
  if (imagerySelect) {
    imagerySelect.value = String(baseImageryTarget);   // reflect the JS default
    imagerySelect.addEventListener('change', () => {
      baseImageryTarget = parseInt(imagerySelect.value, 10) || 1280;
      loadImagery();   // re-fetch the base aerial photo at the new resolution
    });
  }
  if (imageryReloadBtn) {
    imageryReloadBtn.addEventListener('click', () => loadImagery());
  }
  if (fullscreenBtn) {
    fullscreenBtn.addEventListener('click', () => {
      if (!document.fullscreenElement) {
        if (stage.requestFullscreen) stage.requestFullscreen();
      } else {
        if (document.exitFullscreen) document.exitFullscreen();
      }
    });
  }
  // Fullscreen toggles change stage dimensions; resync the renderer + camera.
  document.addEventListener('fullscreenchange', () => {
    renderer.setSize(stage.clientWidth, stage.clientHeight);
    camera.aspect = stage.clientWidth / Math.max(stage.clientHeight, 1);
    camera.updateProjectionMatrix();
    if (fullscreenBtn) fullscreenBtn.textContent = document.fullscreenElement ? '⛶ Exit fullscreen' : '⛶ Fullscreen';
  });

  // Markers keep a roughly constant on-screen size (visible when zoomed out,
  // not giant when zoomed in); kept small so dense clusters overlap less.
  function markerViewScale() { return Math.max(0.4, dist * 0.006); }

  // ---- Flyby: trace the focused line at a fixed altitude above the terrain ----
  // Camera position rides 200 m above the LOCAL terrain (so it climbs hills and
  // descends valleys instead of crashing into them). Look-ahead point keeps the
  // view oriented along the path.
  const FLYBY_HEIGHT_M = 400;        // ** maximum ** altitude (real metres above local ground)
  const FLYBY_MIN_HEIGHT_M = 5;      // can't drop the camera into the ground
  const FLYBY_DURATION_MS = 30000;   // total wall-clock duration at 1× speed
  const FLYBY_SPEED_STEPS = [0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5];   // ± buttons step through this ladder
  let flybyActive = false;
  let flybyPaused = false;
  let flybyProgress = 0;                // 0..1 along the path; advances per-frame by dt × speed
  let flybyLastFrameTime = 0;
  let flybySpeedIdx = 3;                // index into FLYBY_SPEED_STEPS (3 = 1×)
  let flybyAltitude = FLYBY_HEIGHT_M;   // real metres -- wheel scroll adjusts this while flying
  let flybyPath = [];                   // [{x, z}, ...] interpolated centre-line at ~10 m spacing
  let flybySmoothedGround = null;       // low-passed ground height for jitter-free vertical motion

  function buildFlybyPathForLine(lineId) {
    const stns = assetData
      .filter(a => a.line_id === lineId && a.latitude != null && a.longitude != null)
      .sort((p, q) => String(p.code).localeCompare(String(q.code), undefined, { numeric: true }));
    if (stns.length < 2) return [];
    const out = [];
    for (let k = 0; k < stns.length - 1; k++) {
      const A = llToScene(stns[k].latitude, stns[k].longitude, 0);
      const B = llToScene(stns[k + 1].latitude, stns[k + 1].longitude, 0);
      const segLen = Math.hypot(B.x - A.x, B.z - A.z);
      const steps = Math.max(2, Math.min(400, Math.round(segLen / 10)));   // a point ~every 10 m
      for (let s = (k === 0 ? 0 : 1); s <= steps; s++) {
        const f = s / steps;
        out.push({ x: A.x + (B.x - A.x) * f, z: A.z + (B.z - A.z) * f });
      }
    }
    return out;
  }

  // Refs to the in-flight control widgets (hidden until a flyby is running).
  const flyCtrls = document.getElementById('m3d-fly-ctrls');
  const flyPauseBtn = document.getElementById('m3d-fly-pause');
  const flySlowBtn = document.getElementById('m3d-fly-slow');
  const flyFastBtn = document.getElementById('m3d-fly-fast');
  const flySpeedLbl = document.getElementById('m3d-fly-speed');
  function flybySpeed() { return FLYBY_SPEED_STEPS[flybySpeedIdx]; }
  function updateFlySpeedLabel() {
    if (!flySpeedLbl) return;
    const s = flybySpeed();
    flySpeedLbl.textContent = Number.isInteger(s) ? `${s}×` : `${s}×`;
  }
  function updateFlyPauseLabel() {
    if (!flyPauseBtn) return;
    flyPauseBtn.textContent = flybyPaused ? '▶ Continue' : '⏸ Pause';
  }
  function setFlyButtonState() {
    if (flyBtn) flyBtn.textContent = flybyActive ? '■ Stop flyby' : '✈ Fly the line';
    if (flyCtrls) flyCtrls.hidden = !flybyActive;
  }

  function startFlyby() {
    if (flybyActive) { stopFlyby(); return; }   // toggle off
    const sel = lineSelect && lineSelect.value;
    if (!sel) { alert('Pick a line in the "Focus line" dropdown first.'); return; }
    const lineId = parseInt(sel, 10);
    const pts = buildFlybyPathForLine(lineId);
    if (pts.length < 2) { alert('That line needs at least two stations to fly along.'); return; }
    flybyPath = pts;
    flybyProgress = 0;
    flybyLastFrameTime = 0;            // tickFlyby seeds this on the first frame
    flybyPaused = false;
    flybySpeedIdx = 3;                 // reset to 1×
    flybyAltitude = FLYBY_HEIGHT_M;    // start at the max; user can wheel down lower
    flybySmoothedGround = null;        // smoothing seeds on the first tick
    flybyActive = true;
    setFlyButtonState();
    updateFlyPauseLabel();
    updateFlySpeedLabel();
  }

  function stopFlyby() {
    if (!flybyActive) return;
    flybyActive = false;
    flybyPaused = false;
    setFlyButtonState();
    // Snap the orbit state to where the camera ended so normal controls resume cleanly.
    target.set(camera.position.x, surfaceHeightXZ(camera.position.x, camera.position.z, 0),
               camera.position.z);
    dist = 300;
    elev = 0.85;
    azim = -0.6;
    updateCam();
  }

  const _flyLook = new THREE.Vector3();
  function tickFlyby() {
    if (!flybyActive || flybyPath.length < 2) return;
    // Advance progress per-frame at the current speed (skips when paused),
    // so pause/speed changes take effect cleanly without time jumps.
    const now = performance.now();
    if (flybyLastFrameTime > 0 && !flybyPaused) {
      const dt = now - flybyLastFrameTime;
      flybyProgress += (dt * flybySpeed()) / FLYBY_DURATION_MS;
    }
    flybyLastFrameTime = now;
    if (flybyProgress >= 1) { stopFlyby(); return; }
    const t = flybyProgress;
    const fIdx = t * (flybyPath.length - 1);
    const i0 = Math.floor(fIdx);
    const i1 = Math.min(flybyPath.length - 1, i0 + 1);
    const frac = fIdx - i0;
    const x = flybyPath[i0].x * (1 - frac) + flybyPath[i1].x * frac;
    const z = flybyPath[i0].z * (1 - frac) + flybyPath[i1].z * frac;

    // Sample the ground ~100 m ahead so the camera starts climbing BEFORE
    // hitting a rising hill, then low-pass filter that value with EMA so the
    // vertical motion is smooth instead of tracking every bump frame-to-frame.
    const aheadIdx = Math.min(flybyPath.length - 1, i0 + 10);
    const groundAhead = surfaceHeightXZ(flybyPath[aheadIdx].x, flybyPath[aheadIdx].z, 0);
    if (flybySmoothedGround === null) flybySmoothedGround = groundAhead;
    else flybySmoothedGround = flybySmoothedGround * 0.92 + groundAhead * 0.08;

    // Terrain Y is exaggerated, so real-metre altitude × VERT_EXAGGERATION.
    const altitude = flybyAltitude * VERT_EXAGGERATION;
    camera.position.set(x, flybySmoothedGround + altitude, z);

    // Look straight forward (level horizon): look-point at the same Y as the
    // camera, just down the path. No tilt up/down regardless of terrain.
    const lookIdx = Math.min(flybyPath.length - 1, i0 + 30);
    const lpt = flybyPath[lookIdx];
    _flyLook.set(lpt.x, camera.position.y, lpt.z);
    camera.lookAt(_flyLook);
  }

  if (flyBtn) {
    flyBtn.addEventListener('click', () => startFlyby());
  }
  if (flyPauseBtn) {
    flyPauseBtn.addEventListener('click', () => {
      if (!flybyActive) return;
      flybyPaused = !flybyPaused;
      updateFlyPauseLabel();
    });
  }
  if (flySlowBtn) {
    flySlowBtn.addEventListener('click', () => {
      if (!flybyActive) return;
      flybySpeedIdx = Math.max(0, flybySpeedIdx - 1);
      updateFlySpeedLabel();
    });
  }
  if (flyFastBtn) {
    flyFastBtn.addEventListener('click', () => {
      if (!flybyActive) return;
      flybySpeedIdx = Math.min(FLYBY_SPEED_STEPS.length - 1, flybySpeedIdx + 1);
      updateFlySpeedLabel();
    });
  }

  function animate() {
    requestAnimationFrame(animate);
    const s = markerViewScale();
    const t = performance.now() * 0.004;
    for (let i = 0; i < assetMeshes.length; i++) {
      const m = assetMeshes[i];
      m.scale.setScalar(s);
      if (m._bounce) {   // bait stations bob in place
        m.position.y = m._baseY + (Math.sin(t + m._phase) * 0.5 + 0.5) * 2.2 * s;
      }
    }
    tickFlyby();   // overrides camera position/orientation while a flyby is running
    renderer.render(scene, camera);
  }
  animate();
  loadGroupData();
})();
