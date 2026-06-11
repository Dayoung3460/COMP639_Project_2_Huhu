/* ════════════════════════════════════════════════════════════
   home-browse.js — homepage browse interactivity
   Search · visibility filter · region picker · sort ·
   grid/list/map views. Group data comes from the server via the
   #homeData JSON blob (the grid is server-rendered for no-JS;
   this script re-renders it when filters change).
   ════════════════════════════════════════════════════════════ */
(function () {
  "use strict";

  var dataEl = document.getElementById("homeData");
  var grid = document.getElementById("grid");
  if (!dataEl || !grid) return;

  var GROUPS = [];
  try { GROUPS = (JSON.parse(dataEl.textContent).groups || []); } catch (e) { return; }
  if (!GROUPS.length) return;

  /* ─────────── State ─────────── */
  var state = { q: "", vis: "all", region: "anywhere", sort: "members", view: "grid", activeId: null };

  /* ─────────── Helpers ─────────── */
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };
  var norm = function (s) { return (s || "").toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, ""); };
  var esc = function (s) {
    return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  };
  var initials = function (n) {
    return (n || "").replace(/[^A-Za-z\u0100-\u017F ]/g, "").split(/\s+/)
      .filter(Boolean).slice(0, 2).map(function (w) { return w[0]; }).join("").toUpperCase();
  };

  /* Region "home" positions — centroid of each region's groups on the
     schematic map (positions are projected from real trap coordinates). */
  var REGION_POS = {};
  var REGIONS = [];
  GROUPS.forEach(function (g) {
    if (!g.region) return;
    if (!REGION_POS[g.region]) { REGION_POS[g.region] = { x: 0, y: 0, n: 0, count: 0 }; REGIONS.push(g.region); }
    var rp = REGION_POS[g.region];
    rp.count++;
    if (g.x != null && g.y != null) { rp.x += g.x; rp.y += g.y; rp.n++; }
  });
  REGIONS.sort();
  REGIONS.forEach(function (r) {
    var rp = REGION_POS[r];
    if (rp.n) { rp.x /= rp.n; rp.y /= rp.n; }
  });

  // Schematic %-units → rough km (NZ bounding box ≈ 1050 km wide, 1440 km tall)
  function distKm(x1, y1, x2, y2) {
    return Math.round(Math.hypot((x1 - x2) * 10.5, (y1 - y2) * 14.4));
  }
  function dist(g) {
    if (state.region === "anywhere") return null;
    var p = REGION_POS[state.region];
    if (!p || !p.n || g.x == null || g.y == null) return null;
    return distKm(g.x, g.y, p.x, p.y);
  }

  /* ─────────── Filtering & sorting ─────────── */
  function compute() {
    var list = GROUPS.slice();
    if (state.vis !== "all") list = list.filter(function (g) { return g.vis === state.vis; });
    if (state.region !== "anywhere") list = list.filter(function (g) { return g.region === state.region; });
    if (state.q.trim()) {
      var q = norm(state.q.trim());
      list = list.filter(function (g) {
        return norm(g.name).includes(q) || norm(g.location).includes(q) || norm(g.blurb).includes(q);
      });
    }
    var by = {
      members: function (a, b) { return b.members - a.members; },
      lines:   function (a, b) { return b.lines - a.lines; },
      catches: function (a, b) { return b.catches - a.catches; },
      newest:  function (a, b) { return (b.founded || 0) - (a.founded || 0); },
      az:      function (a, b) { return a.name.localeCompare(b.name); },
    };
    if (state.region !== "anywhere") {
      list.sort(function (a, b) { return (dist(a) == null ? 1e9 : dist(a)) - (dist(b) == null ? 1e9 : dist(b)); });
    } else {
      list.sort(by[state.sort] || by.members);
    }
    return list;
  }

  /* ─────────── Renderers ─────────── */
  var mapview = $("#mapview"), mapEl = $("#homeMap"),
      maplist = $("#maplist"), empty = $("#emptyFilter");

  function lockIcon() {
    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="11" width="16" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></svg>';
  }
  function pinIcon() {
    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 21s-7-6.2-7-12a7 7 0 1 1 14 0c0 5.8-7 12-7 12Z"/><circle cx="12" cy="9" r="2.5"/></svg>';
  }

  function cardHTML(g, i) {
    var isPrivate = g.vis === "private";
    var d = dist(g);
    var distChip = d != null ? '<span class="card-dist">~' + d + ' km</span>' : "";
    var badge = isPrivate ? '<span class="card-badge">' + lockIcon() + ' Private</span>' : "";
    var region = g.region ? '<span class="card-region">' + pinIcon() + ' ' + esc(g.region) + '</span>' : "";
    var tile = g.tile ? '<img src="' + esc(g.tile) + '" alt="" loading="lazy">' : "";
    var lock = isPrivate ? '<span class="card-lock">' + lockIcon() + ' Joining requires permission</span>' : "";
    var founded = g.founded ? '<p class="card-founded">Founded ' + g.founded + '</p>' : "";
    var aria = (isPrivate ? "Request access to " : "View ") + esc(g.name) + " — " + g.vis +
               " group with " + g.members + (g.members === 1 ? " member" : " members");
    return '' +
      '<a class="card" role="listitem" href="' + esc(g.url) + '"' +
      ' data-id="' + g.id + '" data-private="' + isPrivate + '"' +
      ' style="--card-accent:' + esc(g.accent || "var(--color-accent)") + ';animation-delay:' + Math.min(i * 45, 360) + 'ms"' +
      ' aria-label="' + aria + '">' +
      '<div class="card-photo" aria-hidden="true">' + tile + badge + region + '</div>' +
      '<div class="card-body">' +
      '<h3 class="card-name">' + esc(g.name) + '</h3>' + founded +
      '<p class="card-blurb">' + esc(g.blurb) + '</p>' + lock +
      '<div class="card-reveal"><span class="card-cta">View group <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg></span></div>' +
      '</div>' +
      '<div class="card-foot">' +
      '<span><b>' + g.members + '</b> ' + (g.members === 1 ? "member" : "members") + '</span>' +
      (distChip || '<span><b>' + g.lines + '</b> ' + (g.lines === 1 ? "line" : "lines") + '</span>') +
      '</div></a>';
  }

  function renderGrid(list) {
    grid.innerHTML = list.map(cardHTML).join("");
    settleEntrances(grid, ".card");
  }

  /* Leaflet map — lazy-initialised the first time the map view is
     shown (Leaflet can't size itself inside display:none). Uses the
     shared createNzMap helper (LINZ aerial tiles, NZ-bounded). */
  var leafletMap = null, markerLayer = null, markersById = {};

  function ensureMap() {
    if (leafletMap || !mapEl) return;
    if (typeof L === "undefined" || typeof createNzMap !== "function") return;
    leafletMap = createNzMap("homeMap", mapEl.dataset.linzKey || "");
    leafletMap.setView([-41.2, 172.5], 5);
    markerLayer = L.layerGroup().addTo(leafletMap);
  }

  function pinHTML(g) {
    return '<span class="pin-dot"><span>' + g.members + '</span></span>';
  }

  function renderMap(list) {
    ensureMap();
    if (!leafletMap) return;
    markerLayer.clearLayers();
    markersById = {};
    var latlngs = [];
    list.forEach(function (g) {
      if (g.lat == null || g.lng == null) return;
      var marker = L.marker([g.lat, g.lng], {
        icon: L.divIcon({
          className: "home-pin" + (g.vis === "private" ? " home-pin--private" : ""),
          html: pinHTML(g),
          iconSize: [30, 30],
          iconAnchor: [15, 30],
        }),
        keyboard: true,
        alt: g.name,
      });
      marker.bindTooltip(esc(g.name), { direction: "top", offset: [0, -28] });
      marker.bindPopup(
        '<div class="home-pop"><b>' + esc(g.name) + '</b>' +
        '<span>' + g.members + (g.members === 1 ? " member" : " members") + " · " +
        g.lines + (g.lines === 1 ? " line" : " lines") + '</span>' +
        '<a href="' + esc(g.url) + '">View group →</a></div>'
      );
      marker.on("click", function () { setActive(String(g.id), true); });
      marker.on("mouseover", function () { setActive(String(g.id), false); });
      marker.addTo(markerLayer);
      markersById[String(g.id)] = marker;
      latlngs.push([g.lat, g.lng]);
    });
    leafletMap.invalidateSize();
    if (latlngs.length) {
      leafletMap.fitBounds(L.latLngBounds(latlngs), { padding: [48, 48], maxZoom: 11 });
    }
    maplist.innerHTML = list.map(function (g) {
      var d = dist(g);
      var sub = d != null
        ? esc(g.region) + " · ~" + d + " km"
        : esc(g.region || g.location) + " · " + g.members + " members";
      return '<a class="maplist-item" href="' + esc(g.url) + '" data-id="' + g.id + '" data-private="' + (g.vis === "private") + '">' +
        '<span class="maplist-marker" aria-hidden="true">' + esc(initials(g.name)) + '</span>' +
        '<span><span class="maplist-name">' + esc(g.name) + '</span>' +
        '<span class="maplist-sub"><span>' + sub + '</span><span>' + g.lines + (g.lines === 1 ? " line" : " lines") + '</span></span></span></a>';
    }).join("");
    $$(".maplist-item", maplist).forEach(function (it) {
      it.addEventListener("mouseenter", function () { setActive(it.dataset.id, false); });
      it.addEventListener("focus", function () { setActive(it.dataset.id, false); });
    });
  }

  // Entrance animations are decorative. After they should have finished,
  // strip them so content is guaranteed visible even if the frame timeline
  // was throttled/paused (e.g. background tab) and never advanced.
  function settleEntrances(root, sel) {
    var els = $$(sel, root);
    setTimeout(function () { els.forEach(function (e) { e.style.animation = "none"; }); }, 700);
  }

  function setActive(id, scroll) {
    state.activeId = id;
    Object.keys(markersById).forEach(function (mid) {
      var el = markersById[mid].getElement();
      if (el) el.dataset.active = (mid === id);
    });
    $$(".maplist-item", maplist).forEach(function (it) {
      var on = it.dataset.id === id;
      it.dataset.active = on;
      if (on && scroll) it.scrollIntoView({ block: "nearest", behavior: "smooth" });
    });
  }

  /* ─────────── Master render ─────────── */
  function render() {
    var list = compute();

    $("#resultNum").textContent = list.length;
    $("#resultWord").textContent = list.length === 1 ? "group" : "groups";

    renderChips();

    var isEmpty = list.length === 0;
    empty.dataset.show = isEmpty;
    grid.style.display = (state.view !== "map" && !isEmpty) ? "" : "none";
    mapview.dataset.show = (state.view === "map" && !isEmpty);

    if (isEmpty) return;

    if (state.view === "map") {
      renderMap(list);
      if (!state.activeId || !list.some(function (g) { return String(g.id) === state.activeId; })) {
        setActive(String(list[0].id), false);
      }
    } else {
      grid.dataset.view = state.view;
      renderGrid(list);
    }
  }

  function renderChips() {
    var chips = $("#chips");
    var parts = [];
    if (state.vis !== "all")
      parts.push(chip(state.vis === "public" ? "Public" : "Private", function () { setVis("all"); }));
    if (state.region !== "anywhere")
      parts.push(chip("Near " + state.region, function () { setRegion("anywhere"); }));
    if (state.q.trim())
      parts.push(chip('"' + state.q.trim() + '"', function () {
        searchInput.value = ""; state.q = ""; updateClear(); render();
      }));
    chips.innerHTML = "";
    parts.forEach(function (p) { chips.appendChild(p); });
  }
  function chip(label, onRemove) {
    var el = document.createElement("span");
    el.className = "fchip";
    el.textContent = label + " ";
    var btn = document.createElement("button");
    btn.type = "button";
    btn.setAttribute("aria-label", "Remove filter: " + label);
    btn.innerHTML = '<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg>';
    btn.addEventListener("click", onRemove);
    el.appendChild(btn);
    return el;
  }

  /* ─────────── Controls: search ─────────── */
  var searchInput = $("#searchInput"), searchClear = $("#searchClear");
  function updateClear() { searchClear.dataset.show = !!searchInput.value; }
  searchInput.addEventListener("input", function () { state.q = searchInput.value; updateClear(); render(); });
  searchClear.addEventListener("click", function () {
    searchInput.value = ""; state.q = ""; updateClear(); render(); searchInput.focus();
  });

  /* ─────────── Controls: visibility segmented ─────────── */
  var visSeg = $("#visSeg"), visThumb = $("#visThumb");
  function moveThumb() {
    var active = $('[aria-pressed="true"]', visSeg);
    if (!active) return;
    visThumb.style.left = active.offsetLeft + "px";
    visThumb.style.width = active.offsetWidth + "px";
  }
  function setVis(v) {
    state.vis = v;
    $$("button[data-vis]", visSeg).forEach(function (b) { b.setAttribute("aria-pressed", b.dataset.vis === v); });
    moveThumb();
    render();
  }
  $$("button[data-vis]", visSeg).forEach(function (b) {
    b.addEventListener("click", function () { setVis(b.dataset.vis); });
  });

  /* ─────────── Controls: region picker ─────────── */
  var regionControl = $("#regionControl"), regionMenu = $("#regionMenu"),
      regionBtn = $("#regionBtn"), regionLabel = $("#regionLabel");
  REGIONS.forEach(function (r) {
    var b = document.createElement("button");
    b.className = "menu-item";
    b.type = "button";
    b.dataset.region = r;
    b.setAttribute("role", "option");
    b.innerHTML = "<span>" + esc(r) + "</span><small>" + REGION_POS[r].count + "</small>";
    b.addEventListener("click", function () { setRegion(r); closeMenus(); });
    regionMenu.appendChild(b);
  });
  function setRegion(r) {
    state.region = r;
    regionLabel.textContent = r === "anywhere" ? "anywhere" : r;
    $$("[data-region]", regionMenu).forEach(function (it) {
      it.setAttribute("aria-selected", it.dataset.region === r);
    });
    // when a region is set, sort is superseded by proximity
    sortControl.style.opacity = r === "anywhere" ? "1" : "0.5";
    sortControl.style.pointerEvents = r === "anywhere" ? "" : "none";
    render();
  }
  regionBtn.addEventListener("click", function (e) { e.stopPropagation(); toggleMenu(regionControl); });

  // "Use my location" — geolocate, then pick the nearest region centroid
  var useLocation = $("#useLocation");
  useLocation.addEventListener("click", function (e) {
    e.stopPropagation();
    var span = useLocation.firstElementChild;
    var original = span.innerHTML;
    function restore() { span.innerHTML = original; }
    if (!navigator.geolocation) { closeMenus(); return; }
    span.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" class="locspin"><path d="M12 3a9 9 0 1 0 9 9"/></svg> Locating…';
    var spin = span.querySelector(".locspin");
    if (spin && spin.animate) spin.animate([{ transform: "rotate(0)" }, { transform: "rotate(360deg)" }], { duration: 700, iterations: Infinity });
    navigator.geolocation.getCurrentPosition(function (pos) {
      // Same NZ-bounding-box projection the server uses for pins
      var x = (pos.coords.longitude - 166.0) / 13.0 * 100;
      var y = (-34.5 - pos.coords.latitude) / 13.0 * 100;
      var best = null, bd = Infinity;
      REGIONS.forEach(function (r) {
        var p = REGION_POS[r];
        if (!p.n) return;
        var d = Math.hypot(x - p.x, y - p.y);
        if (d < bd) { bd = d; best = r; }
      });
      restore();
      if (best) setRegion(best);
      closeMenus();
    }, function () { restore(); closeMenus(); }, { timeout: 8000 });
  });

  /* ─────────── Controls: sort ─────────── */
  var sortControl = $("#sortControl"), sortMenu = $("#sortMenu"),
      sortBtn = $("#sortBtn"), sortLabel = $("#sortLabel");
  $$("[data-sort]", sortMenu).forEach(function (it) {
    it.addEventListener("click", function () {
      state.sort = it.dataset.sort;
      sortLabel.textContent = it.textContent.trim();
      $$("[data-sort]", sortMenu).forEach(function (o) { o.setAttribute("aria-selected", o === it); });
      closeMenus();
      render();
    });
  });
  sortBtn.addEventListener("click", function (e) { e.stopPropagation(); toggleMenu(sortControl); });

  /* ─────────── Menu open/close plumbing ─────────── */
  function toggleMenu(ctrl) {
    var open = ctrl.dataset.open === "true";
    closeMenus();
    if (!open) {
      ctrl.dataset.open = "true";
      var btn = $(".control-btn", ctrl);
      if (btn) btn.setAttribute("aria-expanded", "true");
    }
  }
  function closeMenus() {
    $$(".control").forEach(function (c) {
      c.dataset.open = "false";
      var b = $(".control-btn", c);
      if (b) b.setAttribute("aria-expanded", "false");
    });
  }
  document.addEventListener("click", closeMenus);
  document.addEventListener("keydown", function (e) { if (e.key === "Escape") closeMenus(); });

  /* ─────────── Controls: view toggle ─────────── */
  var viewToggle = $("#viewToggle");
  $$("button[data-view]", viewToggle).forEach(function (b) {
    b.addEventListener("click", function () {
      state.view = b.dataset.view;
      $$("button[data-view]", viewToggle).forEach(function (o) { o.setAttribute("aria-pressed", o === b); });
      render();
    });
  });

  /* ─────────── Reset ─────────── */
  $("#resetBtn").addEventListener("click", function () {
    searchInput.value = ""; state.q = ""; updateClear();
    setVis("all"); setRegion("anywhere");
  });

  /* ─────────── Hero: "Find a group near you" ─────────── */
  var findNearBtn = document.getElementById("findNearBtn");
  if (findNearBtn) {
    findNearBtn.addEventListener("click", function (e) {
      e.preventDefault();
      document.getElementById("groups").scrollIntoView({ behavior: "smooth", block: "start" });
      setTimeout(function () { toggleMenu(regionControl); }, 650);
    });
  }

  /* ─────────── Init ─────────── */
  moveThumb();
  setTimeout(moveThumb, 0);
  setTimeout(moveThumb, 300);
  window.addEventListener("resize", moveThumb);
  window.addEventListener("load", moveThumb);
})();
