/*
 * static/js/lines-detail.js
 * Line detail page map rendering (Leaflet)
 */

document.addEventListener('DOMContentLoaded', function () {
  // Handle trap retirement modal
  const retireTrapModal = document.getElementById('retire-trap-modal')
  retireTrapModal.addEventListener('show.bs.modal', function(event) {
    const button = event.relatedTarget
    const trapId = button.getAttribute('data-trap-id')
    const trapCode = button.getAttribute('data-trap-code')

    document.getElementById('modal-trap-id').value = trapId
    document.getElementById('modal-trap-code').textContent = trapCode
  })

  const mapElement = document.getElementById('line-map');
  if (!mapElement || typeof L === 'undefined') return;

  const markersElement = document.getElementById('trap-markers-data');
  const markers = markersElement ? JSON.parse(markersElement.textContent) : [];
  const linzApiKey = mapElement.dataset.linzApiKey;
  const lineIsRetired = mapElement.dataset.lineIsRetired === 'true';

  const map = L.map('line-map');
  const tileUrl = `https://basemaps.linz.govt.nz/v1/tiles/aerial/WebMercatorQuad/{z}/{x}/{y}.webp?api=${linzApiKey}`;

  L.tileLayer(tileUrl, {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.linz.govt.nz/">LINZ</a>'
  }).addTo(map);

  if (markers.length > 0) {
    const latlngs = [];

    markers.forEach(function (trap) {
      const marker = L.marker([trap.latitude, trap.longitude]).addTo(map);
      const statusBadge = trap.is_retired
        ? '<span class="badge bg-secondary">Retired</span>'
        : '<span class="badge bg-success">Active</span>';

      marker.bindPopup(`<strong>${trap.code}</strong><br>${trap.trap_type}<br>${statusBadge}`);
      latlngs.push([trap.latitude, trap.longitude]);
    });

    if (latlngs.length >= 2) {
      L.polyline(latlngs, {
        color: '#0d6efd',
        weight: 3,
        opacity: 0.8,
        dashArray: lineIsRetired ? '8 6' : null
      }).addTo(map);
    }

    map.fitBounds(latlngs, { padding: [30, 30] });
  } else {
    // Fallback: Lincoln University area
    map.setView([-43.6409, 172.4678], 13);
  }
});