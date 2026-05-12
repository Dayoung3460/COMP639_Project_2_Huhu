/*
 * static/js/lines-index.js
 * Trap lines index map rendering (Leaflet)
 */

document.addEventListener('DOMContentLoaded', function () {
  function normalizeText(value) {
    return String(value || '').trim().toLowerCase();
  }

  const lineCards = Array.from(document.querySelectorAll('.js-line-card'));
  let noLocationTimeout = null;
  const searchInput = document.getElementById('lines-search-input');
  const typeFilter = document.getElementById('lines-type-filter');
  const operatorFilter = document.getElementById('lines-operator-filter');
  const clearFiltersButton = document.getElementById('lines-clear-filters');
  const filterSummary = document.getElementById('lines-filter-summary');
  const emptyFilterState = document.getElementById('lines-empty-filter-state');
  const statusFilter = document.getElementById('lines-status-filter');

  if (statusFilter) {
    statusFilter.addEventListener('change', function () {
      var url = statusFilter.dataset['url' + statusFilter.value.charAt(0).toUpperCase() + statusFilter.value.slice(1)];
      if (url) window.location.href = url;
    });
  }

  // Handle line retirement modal
  const retireLineModal = document.getElementById('retire-line-modal')
  if (retireLineModal) {
    retireLineModal.addEventListener('show.bs.modal', function(event) {
      const button = event.relatedTarget
      const lineId = button.getAttribute('data-line-id')
      const lineName = button.getAttribute('data-line-name')
      const lineAction = button.getAttribute('data-line-action')
      const hasActiveItems = button.getAttribute('data-has-active-traps') === 'true'
      const lineType = button.getAttribute('data-line-type') || ''

      document.getElementById('modal-line-id').value = lineId
      document.getElementById('modal-line-name').textContent = lineName
      document.getElementById('modal-line-action').action = lineAction

      document.getElementById('modal-warning-active-trap').classList.add('d-none')
      document.getElementById('modal-warning-active-station').classList.add('d-none')
      document.getElementById('modal-warning-no-active').classList.add('d-none')

      if (hasActiveItems && lineType === 'Bait Station') {
        document.getElementById('modal-warning-active-station').classList.remove('d-none')
      } else if (hasActiveItems) {
        document.getElementById('modal-warning-active-trap').classList.remove('d-none')
      } else {
        document.getElementById('modal-warning-no-active').classList.remove('d-none')
      }
    })
  }

  const mapElement = document.getElementById('lines-overview-map');
  let map = null;
  const lineColors = [
    '#0d6efd', '#6610f2', '#20c997', '#fd7e14', '#d63384', '#198754', '#6f42c1',
    '#dc3545', '#0dcaf0', '#ffc107', '#d4a017', '#1982c4', '#8ac926', '#ff595e',
    '#ff924c', '#9b5de5', '#2ec4b6', '#e71d36', '#3a86ff', '#8338ec'
  ];
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
      map.setView(MAP_DEFAULT_CENTER, 13);
    }
  }

  function applyFilters() {
    if (!lineCards.length) return;

    const query = normalizeText(searchInput ? searchInput.value : '');
    const selectedType = typeFilter ? typeFilter.value : '';
    const selectedOperator = operatorFilter ? operatorFilter.value : '';
    const visibleLineIds = new Set();
    let visibleCount = 0;

    lineCards.forEach(function (card) {
      const lineName = normalizeText(card.dataset.lineName);
      const lineType = card.dataset.lineType || '';
      const operatorLabels = (card.dataset.operatorLabels || '')
        .split('||')
        .map(function (label) { return label.trim(); })
        .filter(Boolean);

      const matchesQuery = !query || lineName.includes(query);
      const matchesType = !selectedType || lineType === selectedType;
      const matchesOperator = !selectedOperator || operatorLabels.includes(selectedOperator);
      const isVisible = matchesQuery && matchesType && matchesOperator;

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

    // Update "Me" badge visibility on the dropdown label
    const meBadge = document.getElementById('operator-me-badge');
    if (meBadge && operatorFilter) {
      const selectedOption = operatorFilter.options[operatorFilter.selectedIndex];
      if (selectedOption && selectedOption.text.includes('(Me)')) {
        meBadge.classList.remove('d-none');
      } else {
        meBadge.classList.add('d-none');
      }
    }

    updateMapVisibility(visibleLineIds);
  }

  if (searchInput) {
    searchInput.addEventListener('input', applyFilters);
  }

  if (typeFilter) {
    typeFilter.addEventListener('change', applyFilters);
  }

  if (operatorFilter) {
    operatorFilter.addEventListener('change', applyFilters);
  }

  if (clearFiltersButton) {
    clearFiltersButton.addEventListener('click', function () {
      if (searchInput) searchInput.value = '';
      if (typeFilter) typeFilter.value = '';
      if (operatorFilter) operatorFilter.value = '';

      applyFilters();
    });
  }

  if (mapElement && typeof L !== 'undefined') {
    const markersElement = document.getElementById('lines-overview-traps-data');
    const traps = markersElement ? JSON.parse(markersElement.textContent) : [];
    const linzApiKey = mapElement.dataset.linzApiKey;
    const lineFilter = new URLSearchParams(window.location.search).get('filter') || 'all';

    map = createLincolnMap('lines-overview-map', linzApiKey);

    traps.forEach(function (trap) {
      const lineId = String(trap.line_id);
      const latLng = [trap.latitude, trap.longitude];
      const isRetiredVisual = Boolean(trap.trap_is_retired);
      const shouldShowMarker = lineFilter === 'all'
        || (lineFilter === 'active' && !isRetiredVisual)
        || (lineFilter === 'retired' && isRetiredVisual);

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
      const marker = trap.is_station
        ? L.marker(latLng, { icon: getBaitStationIcon(isRetiredVisual, lineColor) }).addTo(map)
        : L.circleMarker(latLng, getTrapMarkerStyle(isRetiredVisual, lineColor)).addTo(map);

      const lineStatusBadge = statusBadgeHtml(Boolean(trap.line_is_retired));
      const trapStatusBadge = statusBadgeHtml(Boolean(trap.trap_is_retired));

      const itemLabel = trap.is_station ? 'Station Code' : 'Trap Code';
      marker.bindPopup(
        `<div class="mb-1"><strong>Line:</strong> ${trap.line_name} ${lineStatusBadge}</div>` +
        `<div class="mb-1"><strong>${itemLabel}:</strong> ${trap.code} ${trapStatusBadge}</div>` +
        `<a href="${trap.detail_url}" class="small">View line details</a>`
      );

      markersByLine[lineId].push({ marker: marker, latLng: latLng });
    });

    Object.keys(linePointsByLine).forEach(function (lineId) {
      const linePoints = orderPointsByNearestNeighbor(linePointsByLine[lineId]);

      if (linePoints.length < 2) return;

      polylinesByLine[lineId] = L.polyline(linePoints, getLinePolylineStyle(
        lineRetiredById[lineId], getLineColor(lineId)
      )).addTo(map);
    });

    if (allLatLngs.length > 0) {
      map.fitBounds(allLatLngs, { padding: [30, 30] });
    } else {
      map.setView(MAP_DEFAULT_CENTER, 13);
    }

    // Leaflet reads container dimensions at init time, before CSS layout is
    // fully resolved. Deferring invalidateSize to the next paint cycle ensures
    // the container has its final width and tiles fill the whole map area.
    setTimeout(function () { map.invalidateSize(); }, 0);
  }

  lineCards.forEach(function (card) {
    card.addEventListener('click', function (event) {
      if (event.target.closest('a, button, form')) return;

      const lineId = card.dataset.lineId;
      const lineMarkers = markersByLine[lineId] || [];
      const linePoints = linePointsByLine[lineId] || [];
      if (!map || linePoints.length === 0) {
        highlightLineCard(lineId);
        if (map && linePoints.length === 0) {
          const noticeEl = document.getElementById('lines-map-no-location-notice');
          if (noticeEl) {
            if (noLocationTimeout) clearTimeout(noLocationTimeout);
            noticeEl.classList.add('is-visible');
            noLocationTimeout = setTimeout(function () {
              noticeEl.classList.remove('is-visible');
            }, 3000);
          }
        }
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

  if (operatorFilter && operatorFilter.value) {
    operatorFilter.classList.add('pf-flash-highlight');
    operatorFilter.addEventListener('animationend', function () {
      operatorFilter.classList.remove('pf-flash-highlight');
    }, { once: true });
  }
});

// Safari BFCache: modal can get stuck open with backdrop when navigating back
window.addEventListener('pageshow', function (event) {
  if (event.persisted) {
    const modal = document.getElementById('retire-line-modal');
    if (modal) {
      modal.style.display = 'none';
      modal.classList.remove('show');
    }
    document.querySelectorAll('.modal-backdrop').forEach(function (b) { b.remove(); });
    document.body.classList.remove('modal-open');
    document.body.style.removeProperty('overflow');
    document.body.style.removeProperty('padding-right');
    window.location.reload();
  }
});
