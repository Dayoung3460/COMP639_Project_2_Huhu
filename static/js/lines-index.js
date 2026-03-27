/*
 * static/js/lines-index.js
 * Trap lines index map rendering (Leaflet)
 */

document.addEventListener('DOMContentLoaded', function () {
  function normalizeText(value) {
    return String(value || '').trim().toLowerCase();
  }

  const lineCards = Array.from(document.querySelectorAll('.js-line-card'));
  const searchInput = document.getElementById('lines-search-input');
  const operatorFilter = document.getElementById('lines-operator-filter');
  const clearFiltersButton = document.getElementById('lines-clear-filters');
  const filterSummary = document.getElementById('lines-filter-summary');
  const emptyFilterState = document.getElementById('lines-empty-filter-state');

  // Handle line retirement modal
  const retireLineModal = document.getElementById('retire-line-modal')
  if (retireLineModal) {
    retireLineModal.addEventListener('show.bs.modal', function(event) {
      const button = event.relatedTarget
      const lineId = button.getAttribute('data-line-id')
      const lineName = button.getAttribute('data-line-name')
      const lineAction = button.getAttribute('data-line-action')
      const hasActiveTraps = button.getAttribute('data-has-active-traps') === 'true'

      document.getElementById('modal-line-id').value = lineId
      document.getElementById('modal-line-name').textContent = lineName
      document.getElementById('modal-line-action').action = lineAction

      // Show correct warning based on active traps status
      document.getElementById('modal-warning-active').style.display = hasActiveTraps ? 'block' : 'none'
      document.getElementById('modal-warning-no-active').style.display = hasActiveTraps ? 'none' : 'block'
    })
  }

  const mapElement = document.getElementById('lines-overview-map');
  const defaultCenter = [-43.6409, 172.4678];
  let map = null;
  const lineColors = [
    '#0d6efd', '#6610f2', '#20c997', '#fd7e14', '#d63384', '#198754', '#6f42c1',
    '#dc3545', '#0dcaf0', '#ffc107', '#6c757d', '#1982c4', '#8ac926', '#ff595e',
    '#ff924c', '#9b5de5', '#2ec4b6', '#e71d36', '#3a86ff', '#8338ec'
  ];
  const retiredColor = '#343a40';
  const retiredFillColor = '#adb5bd';
  const markersByLine = {};
  const linePointsByLine = {};
  const polylinesByLine = {};
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

  function updateMapVisibility(visibleLineIds) {
    if (!map) return;

    const visibleLatLngs = [];

    Object.keys(markersByLine).forEach(function (lineId) {
      const shouldShowLine = visibleLineIds.has(lineId);

      markersByLine[lineId].forEach(function (markerEntry) {
        if (shouldShowLine) {
          if (!map.hasLayer(markerEntry.marker)) {
            markerEntry.marker.addTo(map);
          }
          visibleLatLngs.push(markerEntry.latLng);
        } else if (map.hasLayer(markerEntry.marker)) {
          map.removeLayer(markerEntry.marker);
        }
      });

      const polyline = polylinesByLine[lineId];
      if (!polyline) return;

      if (shouldShowLine) {
        if (!map.hasLayer(polyline)) {
          polyline.addTo(map);
        }
        (linePointsByLine[lineId] || []).forEach(function (latLng) {
          visibleLatLngs.push(latLng);
        });
      } else if (map.hasLayer(polyline)) {
        map.removeLayer(polyline);
      }
    });

    if (visibleLatLngs.length > 0) {
      map.fitBounds(visibleLatLngs, { padding: [30, 30] });
    } else {
      map.setView(defaultCenter, 13);
    }
  }

  function applyFilters() {
    if (!lineCards.length) return;

    const query = normalizeText(searchInput ? searchInput.value : '');
    const selectedOperator = operatorFilter ? operatorFilter.value : '';
    const visibleLineIds = new Set();
    let visibleCount = 0;

    lineCards.forEach(function (card) {
      const lineName = normalizeText(card.dataset.lineName);
      const operatorLabels = (card.dataset.operatorLabels || '')
        .split('||')
        .map(function (label) { return label.trim(); })
        .filter(Boolean);

      const matchesQuery = !query || lineName.includes(query);
      const matchesOperator = !selectedOperator || operatorLabels.includes(selectedOperator);
      const isVisible = matchesQuery && matchesOperator;

      card.classList.toggle('d-none', !isVisible);

      if (isVisible) {
        visibleCount += 1;
        visibleLineIds.add(card.dataset.lineId);
      }
    });

    if (filterSummary) {
      filterSummary.textContent = String(visibleCount);
    }

    if (emptyFilterState) {
      emptyFilterState.classList.toggle('d-none', visibleCount !== 0);
    }

    updateMapVisibility(visibleLineIds);
  }

  if (searchInput) {
    searchInput.addEventListener('input', applyFilters);
  }

  if (operatorFilter) {
    operatorFilter.addEventListener('change', applyFilters);
  }

  if (clearFiltersButton) {
    clearFiltersButton.addEventListener('click', function () {
      if (searchInput) searchInput.value = '';
      if (operatorFilter) operatorFilter.value = '';

      applyFilters();
    });
  }

  if (mapElement && typeof L !== 'undefined') {
    const markersElement = document.getElementById('lines-overview-traps-data');
    const traps = markersElement ? JSON.parse(markersElement.textContent) : [];
    const linzApiKey = mapElement.dataset.linzApiKey;
    const showRetired = new URLSearchParams(window.location.search).get('show_retired') === '1';
    const mapMinZoom = 5;
    const mapMaxZoom = 19;
    const tileUrl = `https://basemaps.linz.govt.nz/v1/tiles/aerial/WebMercatorQuad/{z}/{x}/{y}.webp?api=${linzApiKey}`;

    map = L.map('lines-overview-map', {
      minZoom: mapMinZoom,
      maxZoom: mapMaxZoom
    });

    L.tileLayer(tileUrl, {
      minZoom: mapMinZoom,
      maxZoom: mapMaxZoom,
      noWrap: true,
      attribution: '&copy; <a href="https://www.linz.govt.nz/">LINZ</a>'
    }).addTo(map);

    traps.forEach(function (trap) {
      const lineId = String(trap.line_id);
      const latLng = [trap.latitude, trap.longitude];
      const isRetiredVisual = Boolean(trap.trap_is_retired);
      const shouldShowMarker = showRetired || !isRetiredVisual;

      if (!linePointsByLine[lineId]) {
        linePointsByLine[lineId] = [];
      }
      linePointsByLine[lineId].push(latLng);

      if (!markersByLine[lineId]) {
        markersByLine[lineId] = [];
      }
      lineRetiredById[lineId] = Boolean(trap.line_is_retired);

      allLatLngs.push(latLng);

      if (!shouldShowMarker) return;

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
        ? '<span class="trap-status-badge trap-status-retired">Retired trap</span>'
        : '<span class="trap-status-badge trap-status-active">Active trap</span>';

      marker.bindPopup(
        `<strong>Line:</strong> ${trap.line_name}<br>` +
        `<div class="mb-1"><strong>Trap Code:</strong> ${trap.code}</div>` +
        `${lineStatusBadge} ${trapStatusBadge}<br>` +
        `<a href="${trap.detail_url}" class="small">View line details</a>`
      );

      markersByLine[lineId].push({ marker: marker, latLng: latLng });
    });

    Object.keys(linePointsByLine).forEach(function (lineId) {
      const linePoints = orderPointsByNearestNeighbor(linePointsByLine[lineId]);

      if (linePoints.length < 2) return;

      polylinesByLine[lineId] = L.polyline(linePoints, {
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
  }

  lineCards.forEach(function (card) {
    card.addEventListener('click', function (event) {
      if (event.target.closest('a, button, form')) return;

      const lineId = card.dataset.lineId;
      const lineMarkers = markersByLine[lineId] || [];
      const linePoints = linePointsByLine[lineId] || [];
      if (!map || linePoints.length === 0) {
        highlightLineCard(lineId);
        return;
      }

      const bounds = L.latLngBounds(linePoints);

      map.fitBounds(bounds, { padding: [40, 40], maxZoom: 17 });
      if (lineMarkers.length > 0) {
        lineMarkers[0].marker.openPopup();
      }
      highlightLineCard(lineId);
    });
  });

  applyFilters();
});
