/*
 * static/js/lines-index.js
 * Trap lines index map rendering (Leaflet)
 */

document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.js-confirm-retire-line-form').forEach(function (form) {
    form.addEventListener('submit', function (event) {
      if (!window.confirm('Retire this line?')) {
        event.preventDefault();
      }
    });
  });

  const mapElement = document.getElementById('lines-overview-map');
  if (!mapElement || typeof L === 'undefined') return;

  const markersElement = document.getElementById('lines-overview-traps-data');
  const traps = markersElement ? JSON.parse(markersElement.textContent) : [];
  const linzApiKey = mapElement.dataset.linzApiKey;

  const map = L.map('lines-overview-map');
  const tileUrl = `https://basemaps.linz.govt.nz/v1/tiles/aerial/WebMercatorQuad/{z}/{x}/{y}.webp?api=${linzApiKey}`;

  L.tileLayer(tileUrl, {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.linz.govt.nz/">LINZ</a>'
  }).addTo(map);

  const defaultCenter = [-43.6409, 172.4678];
  const lineColors = [
    '#0d6efd', '#6610f2', '#20c997', '#fd7e14', '#d63384', '#198754', '#6f42c1',
    '#dc3545', '#0dcaf0', '#ffc107', '#6c757d', '#1982c4', '#8ac926', '#ff595e',
    '#ff924c', '#9b5de5', '#2ec4b6', '#e71d36', '#3a86ff', '#8338ec'
  ];
  const retiredColor = '#343a40';
  const retiredFillColor = '#adb5bd';
  const markersByLine = {};
  const lineRetiredById = {};
  const allLatLngs = [];

  function getLineColor(lineId) {
    return lineColors[Math.abs(Number(lineId)) % lineColors.length];
  }

  function highlightLineCard(lineId) {
    document.querySelectorAll('.js-line-card').forEach(function (card) {
      card.classList.remove('border-primary', 'shadow-sm');
    });

    const card = document.getElementById(`line-card-${lineId}`);
    if (!card) return;

    card.classList.add('border-primary', 'shadow-sm');
    card.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  traps.forEach(function (trap) {
    const lineId = String(trap.line_id);
    const latLng = [trap.latitude, trap.longitude];
    const isRetiredVisual = Boolean(trap.trap_is_retired || trap.line_is_retired);

    if (!markersByLine[lineId]) {
      markersByLine[lineId] = [];
    }
    lineRetiredById[lineId] = Boolean(trap.line_is_retired);

    const lineColor = getLineColor(lineId);
    const marker = L.circleMarker(latLng, isRetiredVisual
      ? {
          radius: 8,
          color: retiredColor,
          fillColor: retiredFillColor,
          fillOpacity: 0.15,
          weight: 3
        }
      : {
          radius: 7,
          color: lineColor,
          fillColor: lineColor,
          fillOpacity: 0.9,
          weight: 1.5
        }
    ).addTo(map);

    const lineStatusBadge = trap.line_is_retired
      ? '<span class="badge bg-dark">Retired line</span>'
      : '<span class="badge bg-success">Active line</span>';
    const trapStatusBadge = trap.trap_is_retired
      ? '<span class="badge bg-secondary">Retired trap</span>'
      : '<span class="badge bg-success">Active trap</span>';

    marker.bindPopup(
      `<strong>Line:</strong> ${trap.line_name}<br>` +
      `<div class="mb-1"><strong>Trap Code:</strong> ${trap.code}</div>` +
      `${lineStatusBadge} ${trapStatusBadge}<br>` +
      `<a href="${trap.detail_url}" class="small">View line details</a>`
    );

    markersByLine[lineId].push({ marker: marker, latLng: latLng });
    allLatLngs.push(latLng);
  });

  Object.keys(markersByLine).forEach(function (lineId) {
    const linePoints = markersByLine[lineId].map(function (entry) {
      return entry.latLng;
    });

    if (linePoints.length < 2) return;

    L.polyline(linePoints, {
      color: lineRetiredById[lineId] ? retiredColor : getLineColor(lineId),
      weight: lineRetiredById[lineId] ? 4 : 3,
      opacity: lineRetiredById[lineId] ? 0.95 : 0.8,
      dashArray: lineRetiredById[lineId] ? '8 6' : null
    }).addTo(map);
  });

  if (allLatLngs.length > 0) {
    map.fitBounds(allLatLngs, { padding: [30, 30] });
  } else {
    map.setView(defaultCenter, 13);
  }

  document.querySelectorAll('.js-line-card').forEach(function (card) {
    card.addEventListener('click', function (event) {
      if (event.target.closest('a, button, form')) return;

      const lineId = card.dataset.lineId;
      const lineMarkers = markersByLine[lineId];
      if (!lineMarkers || lineMarkers.length === 0) return;

      const bounds = L.latLngBounds(lineMarkers.map(function (entry) {
        return entry.latLng;
      }));

      map.fitBounds(bounds, { padding: [40, 40], maxZoom: 17 });
      lineMarkers[0].marker.openPopup();
      highlightLineCard(lineId);
    });
  });
});
