/*
 * static/js/observation-map.js
 * Map for add observation page — click to set lat/lng, type to update marker.
 * Borrows Leaflet + LINZ tile logic from lines-detail.js.
 */

document.addEventListener('DOMContentLoaded', function () {
  const coordinateInputUtils = window.coordinateInputUtils;
  const mapElement = document.getElementById('observation-map');
  if (!mapElement || typeof L === 'undefined') return;

  const linzApiKey = mapElement.dataset.linzApiKey;

  // ── Initialise bounded NZ map (shared with trap line pages) ─────────────
  const map = createNzMap('observation-map', linzApiKey);

  // Default view: Lincoln University area (or server-provided center)
  const centerLat = parseFloat(mapElement.dataset.centerLat);
  const centerLng = parseFloat(mapElement.dataset.centerLng);
  const defaultCenter = (!isNaN(centerLat) && !isNaN(centerLng))
    ? [centerLat, centerLng]
    : MAP_DEFAULT_CENTER;
  map.setView(defaultCenter, 14);

  // ── References ──────────────────────────────────────────────────────────
  const latInput = document.getElementById('obs-lat');
  const lngInput = document.getElementById('obs-lng');
  const lineSelect = document.getElementById('lineSelect');
  const trapSelect = document.getElementById('trapSelect');
  let marker = null;

  // Attach coordinate input guards (from coordinate-input.js)
  if (coordinateInputUtils) {
    coordinateInputUtils.attachCoordinateInputGuards([latInput, lngInput]);
  }

  // ── Helper: place or move marker ────────────────────────────────────────
  function setMarker(lat, lng) {
    if (marker) {
      marker.setLatLng([lat, lng]);
    } else {
      marker = L.marker([lat, lng]).addTo(map);
    }
    marker.bindPopup(
      `<strong>Observation Location</strong><br>Lat: ${Number(lat).toFixed(6)}<br>Lng: ${Number(lng).toFixed(6)}`
    ).openPopup();
    map.setView([lat, lng], Math.max(map.getZoom(), 15));
  }

  function clearMarker() {
    if (marker) {
      map.removeLayer(marker);
      marker = null;
    }
  }

  // ── Map click → fill lat/lng inputs ─────────────────────────────────────
  map.on('click', function (e) {
    const lat = e.latlng.lat.toFixed(6);
    const lng = e.latlng.lng.toFixed(6);
    if (latInput) latInput.value = lat;
    if (lngInput) lngInput.value = lng;
    setMarker(lat, lng);
  });

  // ── Lat/Lng input change → update marker (or re-center if invalid) ──────
  const latMin = parseFloat(mapElement.dataset.latMin);
  const latMax = parseFloat(mapElement.dataset.latMax);
  const lngMin = parseFloat(mapElement.dataset.lngMin);
  const lngMax = parseFloat(mapElement.dataset.lngMax);
  const hasAllowedRange = ![latMin, latMax, lngMin, lngMax].some(isNaN);

  function isWithinAllowedRange(lat, lng) {
    if (isNaN(lat) || isNaN(lng)) return false;
    if (!hasAllowedRange) return true;
    return lat >= latMin && lat <= latMax && lng >= lngMin && lng <= lngMax;
  }

  function onCoordinateInput() {
    const latRaw = latInput ? latInput.value.trim() : '';
    const lngRaw = lngInput ? lngInput.value.trim() : '';
    if (!latRaw && !lngRaw) {
      clearMarker();
      map.setView(defaultCenter, 14);
      return;
    }
    const lat = parseFloat(latRaw);
    const lng = parseFloat(lngRaw);
    if (isWithinAllowedRange(lat, lng)) {
      setMarker(lat, lng);
    } else {
      // Out of Lincoln boundary — drop marker and recenter to Lincoln.
      clearMarker();
      map.setView(defaultCenter, 14);
    }
  }

  if (latInput) latInput.addEventListener('change', onCoordinateInput);
  if (lngInput) lngInput.addEventListener('change', onCoordinateInput);

  // ── Filter traps by selected line ───────────────────────────────────────
  if (lineSelect && trapSelect) {
    lineSelect.addEventListener('change', function () {
      const selectedLineId = this.value;
      const trapOptions = trapSelect.querySelectorAll('option[data-line-id]');

      trapOptions.forEach(function (option) {
        option.style.display = (option.dataset.lineId === selectedLineId) ? '' : 'none';
      });

      // Reset trap if it doesn't belong to the selected line
      if (trapSelect.selectedOptions[0] && trapSelect.selectedOptions[0].dataset.lineId !== selectedLineId) {
        trapSelect.value = '';
      }
    });

    // When a trap is selected, jump map to its location
    trapSelect.addEventListener('change', function () {
      const selected = this.selectedOptions[0];
      if (selected && selected.dataset.lat && selected.dataset.lng) {
        const lat = parseFloat(selected.dataset.lat);
        const lng = parseFloat(selected.dataset.lng);
        if (!isNaN(lat) && !isNaN(lng)) {
          latInput.value = lat.toFixed(6);
          lngInput.value = lng.toFixed(6);
          setMarker(lat, lng);
        }
      }
    });

    // Trigger line filter on page load for pre-selected line
    if (lineSelect.value) {
      lineSelect.dispatchEvent(new Event('change'));
    }
  }

  // ── If lat/lng already have values on load, show marker (or recenter) ───
  if (latInput && lngInput && latInput.value && lngInput.value) {
    const lat = parseFloat(latInput.value);
    const lng = parseFloat(lngInput.value);
    if (isWithinAllowedRange(lat, lng)) {
      setMarker(lat, lng);
    } else {
      map.setView(defaultCenter, 14);
    }
  }
});
