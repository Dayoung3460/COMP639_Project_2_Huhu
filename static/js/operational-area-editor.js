/*
 * static/js/operational-area-editor.js
 * Leaflet.Draw integration for the Group Operational Area editor.
 */

document.addEventListener('DOMContentLoaded', function () {
  const mapEl = document.getElementById('area-editor-map');
  if (!mapEl || typeof L === 'undefined') return;

  const linzApiKey = mapEl.dataset.linzApiKey;
  const dataEl = document.getElementById('area-editor-geojson-data');
  const existingGeoJSON = dataEl ? dataEl.textContent.trim() : '';

  const map = createLincolnMap('area-editor-map', linzApiKey);
  map.setView(MAP_DEFAULT_CENTER, 13);

  const drawnItems = new L.FeatureGroup();
  map.addLayer(drawnItems);

  const drawControl = new L.Control.Draw({
    draw: {
      polygon: {
        allowIntersection: false,
        showArea: true,
        shapeOptions: { className: 'area-polygon' },
      },
      polyline:    false,
      rectangle:   false,
      circle:      false,
      circlemarker: false,
      marker:      false,
    },
    edit: {
      featureGroup: drawnItems,
      remove: true,
    },
  });
  map.addControl(drawControl);

  const geojsonInput = document.getElementById('area-geojson-input');
  const validationNotice = document.getElementById('area-editor-notice');

  function serializeDrawnItems() {
    const layers = drawnItems.getLayers();
    if (layers.length === 0) {
      geojsonInput.value = '';
      return;
    }
    geojsonInput.value = JSON.stringify(layers[0].toGeoJSON().geometry);
  }

  if (existingGeoJSON && existingGeoJSON !== 'null') {
    try {
      const geom = JSON.parse(existingGeoJSON);
      const layer = L.geoJSON(geom, { style: { className: 'area-polygon' } });
      layer.eachLayer(function (l) { drawnItems.addLayer(l); });
      map.fitBounds(drawnItems.getBounds(), { padding: [30, 30] });
      serializeDrawnItems();
    } catch (e) {
      // Stored geometry is unreadable; start with an empty canvas
    }
  }

  map.on(L.Draw.Event.CREATED, function (event) {
    drawnItems.clearLayers();
    drawnItems.addLayer(event.layer);
    serializeDrawnItems();
  });

  map.on(L.Draw.Event.EDITED, function () { serializeDrawnItems(); });
  map.on(L.Draw.Event.DELETED, function () { serializeDrawnItems(); });

  const saveForm = document.getElementById('area-save-form');
  if (saveForm) {
    saveForm.addEventListener('submit', function (event) {
      serializeDrawnItems();
      if (!geojsonInput.value) {
        event.preventDefault();
        if (validationNotice) validationNotice.classList.remove('d-none');
      } else if (validationNotice) {
        validationNotice.classList.add('d-none');
      }
    });
  }

  setTimeout(function () { map.invalidateSize(); }, 0);
});
