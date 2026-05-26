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

  const map = createNzMap('area-editor-map', linzApiKey);
  map.setView(MAP_DEFAULT_CENTER, MAP_DEFAULT_ZOOM);

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
    edit: false,
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

  function setEmptyState(isEmpty) {
    mapEl.classList.toggle('area-editor-empty', isEmpty);
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
      setEmptyState(true);
    }
  } else {
    setEmptyState(true);
  }

  let pendingLayer = null;
  const replaceModalEl = document.getElementById('replace-area-modal');
  const replaceModal = replaceModalEl ? new bootstrap.Modal(replaceModalEl) : null;

  const confirmReplaceBtn = document.getElementById('replace-area-confirm-btn');
  if (confirmReplaceBtn) {
    confirmReplaceBtn.addEventListener('click', function () {
      if (pendingLayer) {
        drawnItems.clearLayers();
        drawnItems.addLayer(pendingLayer);
        pendingLayer = null;
        setEmptyState(false);
        serializeDrawnItems();
      }
      if (replaceModal) replaceModal.hide();
    });
  }

  if (replaceModalEl) {
    replaceModalEl.addEventListener('hidden.bs.modal', function () {
      pendingLayer = null;
    });
  }

  map.on(L.Draw.Event.CREATED, function (event) {
    if (drawnItems.getLayers().length > 0 && replaceModal) {
      pendingLayer = event.layer;
      replaceModal.show();
    } else {
      drawnItems.clearLayers();
      drawnItems.addLayer(event.layer);
      setEmptyState(false);
      serializeDrawnItems();
    }
  });

  const normalActions = document.getElementById('area-normal-actions');
  const editActions   = document.getElementById('area-edit-actions');
  const editBoundaryBtn = document.getElementById('area-edit-boundary-btn');
  const editSaveBtn     = document.getElementById('area-edit-save-btn');
  const editCancelBtn   = document.getElementById('area-edit-cancel-btn');

  let editHandler = null;

  function enterEditMode() {
    editHandler = new L.EditToolbar.Edit(map, { featureGroup: drawnItems });
    editHandler.enable();
    if (normalActions) normalActions.classList.add('d-none');
    if (editActions)   editActions.classList.remove('d-none');
  }

  function exitEditMode() {
    if (editHandler) { editHandler.disable(); editHandler = null; }
    if (normalActions) normalActions.classList.remove('d-none');
    if (editActions)   editActions.classList.add('d-none');
  }

  if (editBoundaryBtn) {
    editBoundaryBtn.addEventListener('click', enterEditMode);
  }

  if (editSaveBtn) {
    editSaveBtn.addEventListener('click', function () {
      if (editHandler) editHandler.save();
      serializeDrawnItems();
      if (saveForm) saveForm.requestSubmit();
    });
  }

  if (editCancelBtn) {
    editCancelBtn.addEventListener('click', function () {
      if (editHandler) editHandler.revertLayers();
      exitEditMode();
    });
  }

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
