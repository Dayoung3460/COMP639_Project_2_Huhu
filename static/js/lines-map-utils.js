/*
 * static/js/lines-map-utils.js
 * Shared helpers for Leaflet maps on trap-line pages.
 */

/* ── Map constants ────────────────────────────────────────────────────────── */

var MAP_MIN_ZOOM = 5;
var MAP_MAX_ZOOM = 19;
var MAP_DEFAULT_CENTER = [-41.2865, 174.7762];
var MAP_RETIRED_COLOR = '#343a40';

/**
 * Create a Leaflet map with the LINZ aerial tile layer, bounded to New Zealand.
 * @param {string} elementId  – DOM id of the map container
 * @param {string} linzApiKey – LINZ basemap API key
 * @returns {L.Map}
 */
function createNzMap(elementId, linzApiKey) {
  var nzBounds = L.latLngBounds(
    L.latLng(-47.5, 165.5),
    L.latLng(-33.5, 178.5)
  );

  var map = L.map(elementId, {
    minZoom: MAP_MIN_ZOOM,
    maxZoom: MAP_MAX_ZOOM,
    maxBounds: nzBounds,
    maxBoundsViscosity: 1.0
  });

  var tileUrl =
    'https://basemaps.linz.govt.nz/v1/tiles/aerial/WebMercatorQuad/{z}/{x}/{y}.webp?api=' + linzApiKey;

  L.tileLayer(tileUrl, {
    minZoom: MAP_MIN_ZOOM,
    maxZoom: MAP_MAX_ZOOM,
    noWrap: true,
    attribution: '&copy; <a href="https://www.linz.govt.nz/">LINZ</a>'
  }).addTo(map);

  return map;
}

/**
 * Return Leaflet circleMarker style options for a trap.
 * @param {boolean} isRetired
 * @param {string}  color – base colour for active markers
 */
function getTrapMarkerStyle(isRetired, color) {
  if (isRetired) {
    return {
      radius: 10,
      color: MAP_RETIRED_COLOR,
      fillColor: MAP_RETIRED_COLOR,
      fillOpacity: 0,
      weight: 2.5,
      bubblingMouseEvents: false
    };
  }
  return {
    radius: 9,
    color: color,
    fillColor: color,
    fillOpacity: 0.9,
    weight: 1.5,
    bubblingMouseEvents: false
  };
}

/**
 * Return an HTML status badge string.
 * @param {boolean} isRetired
 * @param {string}  [label] – defaults to "Active" / "Retired"
 */
function statusBadgeHtml(isRetired, label) {
  if (isRetired) {
    return '<span class="trap-status-badge trap-status-retired">' + (label || 'Retired') + '</span>';
  }
  return '<span class="trap-status-badge trap-status-active">' + (label || 'Active') + '</span>';
}

/**
 * Return a Leaflet divIcon for a bait station marker (solid square / hollow square).
 * @param {boolean} isRetired
 * @param {string}  color – base colour for active markers
 */
function getBaitStationIcon(isRetired, color) {
  var html = isRetired
    ? '<div class="map-marker-square map-marker-square-retired"></div>'
    : '<div class="map-marker-square" style="background:' + color + ';border-color:' + color + '"></div>';
  return L.divIcon({
    className: '',
    html: html,
    iconSize: [16, 16],
    iconAnchor: [8, 8],
    popupAnchor: [0, -8]
  });
}

/**
 * Return polyline style options for a line.
 * Active lines (both trap and bait station) use a solid stroke.
 * Retired lines use a dotted gray stroke.
 * @param {boolean} isRetired
 * @param {string}  color – base colour for active lines
 */
function getLinePolylineStyle(isRetired, color) {
  return {
    color: isRetired ? MAP_RETIRED_COLOR : color,
    weight: 3,
    opacity: isRetired ? 0.9 : 0.8,
    dashArray: isRetired ? '2 8' : null
  };
}

function getDistanceSquared(pointA, pointB) {
  const latDiff = pointA[0] - pointB[0];
  const lngDiff = pointA[1] - pointB[1];
  return (latDiff * latDiff) + (lngDiff * lngDiff);
}

function getRouteStartIndex(points) {
  let startIndex = 0;

  for (let index = 1; index < points.length; index += 1) {
    const currentPoint = points[index];
    const startPoint = points[startIndex];

    if (
      currentPoint[1] < startPoint[1] ||
      (currentPoint[1] === startPoint[1] && currentPoint[0] < startPoint[0])
    ) {
      startIndex = index;
    }
  }

  return startIndex;
}

function orderPointsByNearestNeighbor(points) {
  if (points.length < 3) return points.slice();

  const remainingPoints = points.slice();
  const orderedPoints = [];
  let currentPoint = remainingPoints.splice(getRouteStartIndex(remainingPoints), 1)[0];

  orderedPoints.push(currentPoint);

  while (remainingPoints.length > 0) {
    let nearestIndex = 0;
    let nearestDistance = getDistanceSquared(currentPoint, remainingPoints[0]);

    for (let index = 1; index < remainingPoints.length; index += 1) {
      const candidateDistance = getDistanceSquared(currentPoint, remainingPoints[index]);

      if (candidateDistance < nearestDistance) {
        nearestDistance = candidateDistance;
        nearestIndex = index;
      }
    }

    currentPoint = remainingPoints.splice(nearestIndex, 1)[0];
    orderedPoints.push(currentPoint);
  }

  return orderedPoints;
}

/**
 * Scroll so container is visible below the sticky navbar, then focus the first
 * interactive element inside it.
 * @param {HTMLElement} container
 */
function scrollAndFocusForm(container) {
  const navbarH = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--navbar-h')) || 58;
  const scrollTarget = container.getBoundingClientRect().top + window.scrollY - navbarH - 8;
  window.scrollTo({ top: Math.max(0, scrollTarget), behavior: 'smooth' });

  const firstInput = container.querySelector('input, select, button, a[href]');
  if (firstInput) firstInput.focus({ preventScroll: true });
}

/**
 * Create a keyboard focus-trap handler for a container.
 * Tab/Shift+Tab cycles within focusable elements; Escape calls onEscape.
 * @param {HTMLElement} container
 * @param {Function}    onEscape
 * @returns {Function}  keydown handler — pass the same reference to removeEventListener
 */
function makeFocusTrapHandler(container, onEscape) {
  return function (e) {
    const focusable = Array.from(container.querySelectorAll(
      'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
    ));
    if (!focusable.length) return;
    const first = focusable[0];
    const last = focusable[focusable.length - 1];
    if (e.key === 'Tab') {
      if (e.shiftKey) {
        if (document.activeElement === first) { e.preventDefault(); last.focus(); }
      } else {
        if (document.activeElement === last) { e.preventDefault(); first.focus(); }
      }
    }
    if (e.key === 'Escape') { onEscape(); }
  };
}
