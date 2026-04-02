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
  const mapMinZoom = 5;
  const mapMaxZoom = 19;

  // ── Initialise map (same pattern as lines-detail.js) ────────────────────
  const map = L.map('observation-map', {
    minZoom: mapMinZoom,
    maxZoom: mapMaxZoom
  });

  const tileUrl = `https://basemaps.linz.govt.nz/v1/tiles/aerial/WebMercatorQuad/{z}/{x}/{y}.webp?api=${linzApiKey}`;
  L.tileLayer(tileUrl, {
    minZoom: mapMinZoom,
    maxZoom: mapMaxZoom,
    noWrap: true,
    attribution: '&copy; <a href="https://www.linz.govt.nz/">LINZ</a>'
  }).addTo(map);

  // Default view: Lincoln University area
  map.setView([-43.6409, 172.4678], 13);

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

  // ── Lat/Lng input change → update marker ────────────────────────────────
  function onCoordinateInput() {
    const lat = parseFloat(latInput.value);
    const lng = parseFloat(lngInput.value);
    if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      setMarker(lat, lng);
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

  // ── If lat/lng already have values on load, show marker ─────────────────
  if (latInput && lngInput && latInput.value && lngInput.value) {
    const lat = parseFloat(latInput.value);
    const lng = parseFloat(lngInput.value);
    if (!isNaN(lat) && !isNaN(lng)) {
      setMarker(lat, lng);
    }
  }
});
