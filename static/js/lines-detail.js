/*
 * static/js/lines-detail.js
 * Line detail page map rendering (Leaflet)
 */

document.addEventListener('DOMContentLoaded', function () {
  const coordinateInputUtils = window.coordinateInputUtils;

  // Handle status filter dropdown (mobile)
  var statusFilter = document.getElementById('lines-status-filter');
  if (statusFilter) {
    statusFilter.addEventListener('change', function () {
      var url = statusFilter.dataset['url' + statusFilter.value.charAt(0).toUpperCase() + statusFilter.value.slice(1)];
      if (url) window.location.href = url;
    });
  }

  // Handle trap retirement modal (trap lines only)
  const retireTrapModal = document.getElementById('retire-trap-modal')
  if (retireTrapModal) {
    retireTrapModal.addEventListener('show.bs.modal', function(event) {
      const button = event.relatedTarget
      document.getElementById('modal-trap-id').value = button.getAttribute('data-trap-id')
      document.getElementById('modal-trap-code').textContent = button.getAttribute('data-trap-code')
    })
  }

  // Handle bait station deactivation modal (bait station lines only)
  const retireStationModal = document.getElementById('retire-station-modal')
  if (retireStationModal) {
    retireStationModal.addEventListener('show.bs.modal', function(event) {
      const button = event.relatedTarget
      document.getElementById('modal-station-id').value = button.getAttribute('data-station-id')
      document.getElementById('modal-station-code').textContent = button.getAttribute('data-station-code')
    })
  }

  const mapElement = document.getElementById('line-map');
  if (!mapElement || typeof L === 'undefined') return;

  const lineType = mapElement.dataset.lineType || 'Trap';
  const isBaitStation = lineType === 'Bait Station';

  const markersElement = document.getElementById(isBaitStation ? 'station-markers-data' : 'trap-markers-data');
  const markers = markersElement ? JSON.parse(markersElement.textContent) : [];
  const linzApiKey = mapElement.dataset.linzApiKey;
  const lineIsRetired = mapElement.dataset.lineIsRetired === 'true';

  const map = createNzMap('line-map', linzApiKey);

  const lineColor = '#0d6efd';

  if (markers.length > 0) {
    const latlngs = [];

    markers.forEach(function (item) {
      const latLng = [item.latitude, item.longitude];
      const isRetired = Boolean(item.is_retired);

      const marker = isBaitStation
        ? L.marker(latLng, { icon: getBaitStationIcon(isRetired, lineColor) }).addTo(map)
        : L.circleMarker(latLng, getTrapMarkerStyle(isRetired, lineColor)).addTo(map);

      const statusBadge = statusBadgeHtml(isRetired);
      let typeLabel = '';
      if (isBaitStation) {
        typeLabel = item.station_type === 'Other' ? (item.other_type || 'Other') : (item.station_type || '');
      } else {
        typeLabel = item.trap_type || '';
      }

      marker.bindPopup(`<strong>${item.code}</strong><br>${typeLabel}<br>${statusBadge}`);
      latlngs.push(latLng);
    });

    if (latlngs.length >= 2) {
      const orderedLatLngs = orderPointsByNearestNeighbor(latlngs);
      L.polyline(orderedLatLngs, getLinePolylineStyle(lineIsRetired, lineColor)).addTo(map);
    }

    map.fitBounds(latlngs, { padding: [30, 30] });
  } else {
    map.setView(MAP_DEFAULT_CENTER, 6);
  }

  setTimeout(function () { map.invalidateSize(); }, 0);

  // ── Inline Form State ──────────────────────────────────────────────────────
  let activeMode = null; // 'addTrap' | 'addStation' | 'editTrap' | 'editStation'
  let tempMarker = null;
  let tempStationMarker = null;
  let editTempMarker = null;

  function insertFormError(containerId, errorMsg) {
    const formContainer = document.getElementById(containerId);
    if (!formContainer) return;
    const cardBody = formContainer.querySelector('.panel-body');
    const alertDiv = document.createElement('div');
    alertDiv.className = 'notice amber lines-inline-form-error';
    alertDiv.setAttribute('role', 'alert');
    const icon = document.createElement('i');
    icon.className = 'bi bi-exclamation-triangle-fill';
    const message = document.createElement('span');
    message.textContent = errorMsg;
    alertDiv.appendChild(icon);
    alertDiv.appendChild(message);
    cardBody.insertBefore(alertDiv, cardBody.querySelector('form'));
    setTimeout(() => { window.scrollBy({ top: alertDiv.offsetHeight, behavior: 'smooth' }); }, 300);
  }

  // ── Inline Add Trap Functionality ──────────────────────────────────────────
  const addTrapBtn = document.getElementById('inline-add-trap-btn');
  const trapsListContainer = document.getElementById('traps-list-container');

  if (addTrapBtn && trapsListContainer) {
    addTrapBtn.addEventListener('click', function () {
      if (activeMode === 'addTrap') return;
      activeMode = 'addTrap';

      const lineId = mapElement.dataset.lineId || '0';
      const newTrapUrl = addTrapBtn.dataset.newTrapUrl || '#';
      let trapTypes = [
        'A24',
        'DOC 150',
        'DOC 200',
        'DOC 250',
        'Flipping Timmy',
        'Rat trap',
        'T-Rex Rat Trap',
        'Trapinator',
        'Victor'
      ];
      if (addTrapBtn.dataset.trapTypes) {
        try { trapTypes = JSON.parse(addTrapBtn.dataset.trapTypes); } catch (e) {}
      }

      const newRow = document.createElement('div');
      newRow.id = 'new-trap-form-container';
      newRow.className = 'panel mb-3 lines-inline-form-panel lines-inline-form-flash';
      newRow.setAttribute('role', 'region');
      newRow.setAttribute('aria-labelledby', 'lines-inline-form-title');
      newRow.innerHTML = `
        <div class="panel-body lines-inline-form-body">
          <div class="lines-inline-form-title" id="lines-inline-form-title">Add Trap</div>
          <div class="lines-inline-form-hint"><i class="bi bi-geo-alt-fill" aria-hidden="true"></i>Click on the map above to set coordinates, or type them below</div>
          <div id="inline-coord-announce" class="visually-hidden" aria-live="polite"></div>
          <form id="new-trap-inline-form" method="POST" action="${newTrapUrl}" aria-label="Add new trap">
            <div class="row g-3 align-items-end">
              <div class="col-12 col-md-2">
                <label for="inline-code" class="form-label small mb-1">Code</label>
                <input type="text" name="code" id="inline-code" class="form-control form-control-sm" required placeholder="e.g. CL-01" aria-required="true">
              </div>
              <div class="col-12 col-md-2">
                <label for="inline-type" class="form-label small mb-1">Type</label>
                <select name="trap_type" id="inline-type" class="form-select form-select-sm" required aria-required="true">
                  <option value="">Select...</option>
                  ${trapTypes.map(t => `<option value="${t}">${t}</option>`).join('')}
                </select>
              </div>
              <div class="col-12 col-md-2">
                <label for="inline-lat" class="form-label small mb-1">Latitude</label>
                <input type="text" name="latitude" id="inline-lat" class="form-control form-control-sm bg-light" inputmode="decimal" required placeholder="e.g. -43.640914" aria-required="true">
              </div>
              <div class="col-12 col-md-2">
                <label for="inline-lng" class="form-label small mb-1">Longitude</label>
                <input type="text" name="longitude" id="inline-lng" class="form-control form-control-sm bg-light" inputmode="decimal" required placeholder="e.g. 172.475682" aria-required="true">
              </div>
              <div class="col-6 col-md-auto ms-md-auto mt-3 mt-md-0">
                <button type="button" class="btn btn-sm-outline w-100" id="cancel-add-trap" aria-label="Cancel adding trap">Cancel</button>
              </div>
              <div class="col-6 col-md-auto mt-3 mt-md-0">
                <button type="submit" class="btn btn-sm-pf w-100" aria-label="Save new trap">Save</button>
              </div>
            </div>
          </form>
        </div>
      `;

      trapsListContainer.prepend(newRow);

      if (coordinateInputUtils) {
        coordinateInputUtils.attachCoordinateInputGuards([
          document.getElementById('inline-lat'),
          document.getElementById('inline-lng')
        ]);
      }

      setTimeout(() => { newRow.classList.remove('lines-inline-form-flash'); }, 500);

      scrollAndFocusForm(newRow);

      const focusTrapHandler = makeFocusTrapHandler(newRow, cancelAddTrap);
      document.addEventListener('keydown', focusTrapHandler);

      function cancelAddTrap() {
        document.removeEventListener('keydown', focusTrapHandler);
        newRow.remove();
        activeMode = null;
        if (tempMarker) {
          map.removeLayer(tempMarker);
          tempMarker = null;
        }
        addTrapBtn.focus();
      }

      document.getElementById('cancel-add-trap').addEventListener('click', cancelAddTrap);
    });
  }

  // ── Inline Add Station Functionality ───────────────────────────────────────
  const addStationBtn = document.getElementById('inline-add-station-btn');
  const stationsListContainer = document.getElementById('stations-list-container');

  if (addStationBtn && stationsListContainer) {
    addStationBtn.addEventListener('click', function () {
      if (activeMode === 'addStation') return;
      activeMode = 'addStation';

      const newStationUrl = addStationBtn.dataset.newStationUrl || '#';
      let stationTypes = [];
      if (addStationBtn.dataset.baitStationTypes) {
        try { stationTypes = JSON.parse(addStationBtn.dataset.baitStationTypes); } catch (e) {}
      }

      const newRow = document.createElement('div');
      newRow.id = 'new-station-form-container';
      newRow.className = 'panel mb-3 lines-inline-form-panel lines-inline-form-flash';
      newRow.setAttribute('role', 'region');
      newRow.setAttribute('aria-labelledby', 'lines-inline-station-form-title');
      newRow.innerHTML = `
        <div class="panel-body lines-inline-form-body">
          <div class="lines-inline-form-title" id="lines-inline-station-form-title">Add Station</div>
          <div class="lines-inline-form-hint"><i class="bi bi-geo-alt-fill" aria-hidden="true"></i>Click on the map above to set coordinates, or type them below</div>
          <div id="inline-station-coord-announce" class="visually-hidden" aria-live="polite"></div>
          <form id="new-station-inline-form" method="POST" action="${newStationUrl}" aria-label="Add new bait station">
            <div class="row g-3 align-items-end">
              <div class="col-12 col-md-2">
                <label for="inline-station-code" class="form-label small mb-1">Code</label>
                <input type="text" name="code" id="inline-station-code" class="form-control form-control-sm" required placeholder="e.g. BS-01" aria-required="true">
              </div>
              <div class="col-12 col-md-2">
                <label for="inline-station-type" class="form-label small mb-1">Type</label>
                <select name="station_type" id="inline-station-type" class="form-select form-select-sm" required aria-required="true">
                  <option value="">Select...</option>
                  ${stationTypes.map(t => `<option value="${t}">${t}</option>`).join('')}
                </select>
              </div>
              <div class="col-12 col-md-2 d-none" id="inline-station-other-group">
                <label for="inline-station-other-type" class="form-label small mb-1">Specify Type</label>
                <input type="text" name="other_type" id="inline-station-other-type" class="form-control form-control-sm" placeholder="e.g. Custom Type">
              </div>
              <div class="col-12 col-md-2">
                <label for="inline-station-lat" class="form-label small mb-1">Latitude</label>
                <input type="text" name="latitude" id="inline-station-lat" class="form-control form-control-sm bg-light" inputmode="decimal" required placeholder="e.g. -43.640914" aria-required="true">
              </div>
              <div class="col-12 col-md-2">
                <label for="inline-station-lng" class="form-label small mb-1">Longitude</label>
                <input type="text" name="longitude" id="inline-station-lng" class="form-control form-control-sm bg-light" inputmode="decimal" required placeholder="e.g. 172.475682" aria-required="true">
              </div>
              <div class="col-6 col-md-auto ms-md-auto mt-3 mt-md-0">
                <button type="button" class="btn btn-sm-outline w-100" id="cancel-add-station" aria-label="Cancel adding station">Cancel</button>
              </div>
              <div class="col-6 col-md-auto mt-3 mt-md-0">
                <button type="submit" class="btn btn-sm-pf w-100" aria-label="Save new station">Save</button>
              </div>
            </div>
          </form>
        </div>
      `;

      stationsListContainer.prepend(newRow);

      // Toggle "Other type" field visibility
      const typeSelect = document.getElementById('inline-station-type');
      const otherGroup = document.getElementById('inline-station-other-group');
      const otherInput = document.getElementById('inline-station-other-type');
      function toggleOtherType() {
        const isOther = typeSelect.value === 'Other';
        otherGroup.classList.toggle('d-none', !isOther);
        if (otherInput) otherInput.required = isOther;
      }
      typeSelect.addEventListener('change', toggleOtherType);

      if (coordinateInputUtils) {
        coordinateInputUtils.attachCoordinateInputGuards([
          document.getElementById('inline-station-lat'),
          document.getElementById('inline-station-lng')
        ]);
      }

      setTimeout(() => { newRow.classList.remove('lines-inline-form-flash'); }, 500);

      scrollAndFocusForm(newRow);

      const focusTrapHandler = makeFocusTrapHandler(newRow, cancelAddStation);
      document.addEventListener('keydown', focusTrapHandler);

      function cancelAddStation() {
        document.removeEventListener('keydown', focusTrapHandler);
        newRow.remove();
        activeMode = null;
        if (tempStationMarker) {
          map.removeLayer(tempStationMarker);
          tempStationMarker = null;
        }
        addStationBtn.focus();
      }

      document.getElementById('cancel-add-station').addEventListener('click', cancelAddStation);
    });
  }

  // ── Inline Edit Trap / Station State ───────────────────────────────────────
  function closeAnyOpenForms() {
    ['cancel-add-trap', 'cancel-add-station', 'cancel-edit-trap', 'cancel-edit-station']
      .forEach(function (id) { const btn = document.getElementById(id); if (btn) btn.click(); });
  }

  // ── Inline Edit Trap ────────────────────────────────────────────────────────
  if (trapsListContainer) {
    trapsListContainer.addEventListener('click', function (e) {
      const btn = e.target.closest('[data-edit-trap]');
      if (btn) openEditTrapForm(btn, null, null);
    });
  }

  function openEditTrapForm(triggerBtn, errorMsg, prefill) {
    closeAnyOpenForms();
    activeMode = 'editTrap';

    const trapId = triggerBtn.dataset.editTrap;
    const code = (prefill && prefill.code) || triggerBtn.dataset.trapCode || '';
    const trapType = (prefill && prefill.trapType) || triggerBtn.dataset.trapType || '';
    const lat = (prefill && prefill.lat) || triggerBtn.dataset.trapLat || '';
    const lng = (prefill && prefill.lng) || triggerBtn.dataset.trapLng || '';
    const editUrl = triggerBtn.dataset.editUrl;

    let trapTypes = ['A24', 'DOC 150', 'DOC 200', 'DOC 250', 'Flipping Timmy', 'Rat trap', 'T-Rex Rat Trap', 'Trapinator', 'Victor'];
    if (addTrapBtn && addTrapBtn.dataset.trapTypes) {
      try { trapTypes = JSON.parse(addTrapBtn.dataset.trapTypes); } catch (e) {}
    }

    const container = document.createElement('div');
    container.id = 'edit-trap-form-container';
    container.className = 'panel mb-3 lines-inline-form-panel lines-inline-form-flash';
    container.setAttribute('role', 'region');
    container.setAttribute('aria-labelledby', 'edit-trap-form-title');
    container.innerHTML = `
      <div class="panel-body lines-inline-form-body">
        ${errorMsg ? `<div class="notice amber lines-inline-form-error" role="alert"><i class="bi bi-exclamation-triangle-fill"></i><span>${errorMsg}</span></div>` : ''}
        <div class="lines-inline-form-title" id="edit-trap-form-title">Edit Trap</div>
        <div class="lines-inline-form-hint"><i class="bi bi-geo-alt-fill" aria-hidden="true"></i>Click on the map above to update coordinates, or type them below</div>
        <div id="edit-trap-coord-announce" class="visually-hidden" aria-live="polite"></div>
        <form id="edit-trap-inline-form" method="POST" action="${editUrl}" aria-label="Edit trap">
          <div class="row g-3 align-items-end">
            <div class="col-12 col-md-2">
              <label for="edit-trap-code" class="form-label small mb-1">Code</label>
              <input type="text" name="trap_code" id="edit-trap-code" class="form-control form-control-sm" required value="${code}" aria-required="true">
            </div>
            <div class="col-12 col-md-2">
              <label for="edit-trap-type" class="form-label small mb-1">Type</label>
              <select name="trap_type" id="edit-trap-type" class="form-select form-select-sm" required aria-required="true">
                <option value="">Select...</option>
                ${trapTypes.map(t => `<option value="${t}"${t === trapType ? ' selected' : ''}>${t}</option>`).join('')}
              </select>
            </div>
            <div class="col-12 col-md-2">
              <label for="edit-trap-lat" class="form-label small mb-1">Latitude</label>
              <input type="text" name="trap_latitude" id="edit-trap-lat" class="form-control form-control-sm bg-light" inputmode="decimal" required value="${lat}" aria-required="true">
            </div>
            <div class="col-12 col-md-2">
              <label for="edit-trap-lng" class="form-label small mb-1">Longitude</label>
              <input type="text" name="trap_longitude" id="edit-trap-lng" class="form-control form-control-sm bg-light" inputmode="decimal" required value="${lng}" aria-required="true">
            </div>
            <div class="col-6 col-md-auto ms-md-auto mt-3 mt-md-0">
              <button type="button" class="btn btn-sm-outline w-100" id="cancel-edit-trap" aria-label="Cancel editing trap">Cancel</button>
            </div>
            <div class="col-6 col-md-auto mt-3 mt-md-0">
              <button type="submit" class="btn btn-sm-pf w-100" aria-label="Save trap changes">Save</button>
            </div>
          </div>
        </form>
      </div>
    `;

    trapsListContainer.prepend(container);

    if (coordinateInputUtils) {
      coordinateInputUtils.attachCoordinateInputGuards([
        document.getElementById('edit-trap-lat'),
        document.getElementById('edit-trap-lng')
      ]);
    }

    if (lat && lng) {
      const latNum = parseFloat(lat);
      const lngNum = parseFloat(lng);
      if (!isNaN(latNum) && !isNaN(lngNum)) {
        if (editTempMarker) map.removeLayer(editTempMarker);
        editTempMarker = L.marker([latNum, lngNum]).addTo(map)
          .bindPopup(`<strong>Editing: ${code}</strong><br>Lat: ${latNum}<br>Lng: ${lngNum}`)
          .openPopup();
      }
    }

    setTimeout(function () { container.classList.remove('lines-inline-form-flash'); }, 500);

    scrollAndFocusForm(container);

    const focusTrapHandler = makeFocusTrapHandler(container, doCancel);
    document.addEventListener('keydown', focusTrapHandler);

    function doCancel() {
      document.removeEventListener('keydown', focusTrapHandler);
      container.remove();
      activeMode = null;
      if (editTempMarker) { map.removeLayer(editTempMarker); editTempMarker = null; }
      triggerBtn.focus();
    }

    document.getElementById('cancel-edit-trap').addEventListener('click', doCancel);
  }

  // ── Inline Edit Station ─────────────────────────────────────────────────────
  if (stationsListContainer) {
    stationsListContainer.addEventListener('click', function (e) {
      const btn = e.target.closest('[data-edit-station]');
      if (btn) openEditStationForm(btn, null, null);
    });
  }

  function openEditStationForm(triggerBtn, errorMsg, prefill) {
    closeAnyOpenForms();
    activeMode = 'editStation';

    const stationId = triggerBtn.dataset.editStation;
    const code = (prefill && prefill.code) || triggerBtn.dataset.stationCode || '';
    const stationType = (prefill && prefill.stationType) || triggerBtn.dataset.stationType || '';
    const otherType = (prefill && prefill.otherType) || triggerBtn.dataset.otherType || '';
    const lat = (prefill && prefill.lat) || triggerBtn.dataset.stationLat || '';
    const lng = (prefill && prefill.lng) || triggerBtn.dataset.stationLng || '';
    const editUrl = triggerBtn.dataset.editUrl;

    let stationTypes = [];
    if (addStationBtn && addStationBtn.dataset.baitStationTypes) {
      try { stationTypes = JSON.parse(addStationBtn.dataset.baitStationTypes); } catch (e) {}
    }

    const container = document.createElement('div');
    container.id = 'edit-station-form-container';
    container.className = 'panel mb-3 lines-inline-form-panel lines-inline-form-flash';
    container.setAttribute('role', 'region');
    container.setAttribute('aria-labelledby', 'edit-station-form-title');
    container.innerHTML = `
      <div class="panel-body lines-inline-form-body">
        ${errorMsg ? `<div class="notice amber lines-inline-form-error" role="alert"><i class="bi bi-exclamation-triangle-fill"></i><span>${errorMsg}</span></div>` : ''}
        <div class="lines-inline-form-title" id="edit-station-form-title">Edit Station</div>
        <div class="lines-inline-form-hint"><i class="bi bi-geo-alt-fill" aria-hidden="true"></i>Click on the map above to update coordinates, or type them below</div>
        <div id="edit-station-coord-announce" class="visually-hidden" aria-live="polite"></div>
        <form id="edit-station-inline-form" method="POST" action="${editUrl}" aria-label="Edit bait station">
          <div class="row g-3 align-items-end">
            <div class="col-12 col-md-2">
              <label for="edit-station-code" class="form-label small mb-1">Code</label>
              <input type="text" name="code" id="edit-station-code" class="form-control form-control-sm" required value="${code}" aria-required="true">
            </div>
            <div class="col-12 col-md-2">
              <label for="edit-station-type" class="form-label small mb-1">Type</label>
              <select name="station_type" id="edit-station-type" class="form-select form-select-sm" required aria-required="true">
                <option value="">Select...</option>
                ${stationTypes.map(t => `<option value="${t}"${t === stationType ? ' selected' : ''}>${t}</option>`).join('')}
              </select>
            </div>
            <div class="col-12 col-md-2${stationType === 'Other' ? '' : ' d-none'}" id="edit-station-other-group">
              <label for="edit-station-other-type" class="form-label small mb-1">Specify Type</label>
              <input type="text" name="other_type" id="edit-station-other-type" class="form-control form-control-sm" value="${otherType}"${stationType === 'Other' ? ' required' : ''}>
            </div>
            <div class="col-12 col-md-2">
              <label for="edit-station-lat" class="form-label small mb-1">Latitude</label>
              <input type="text" name="latitude" id="edit-station-lat" class="form-control form-control-sm bg-light" inputmode="decimal" required value="${lat}" aria-required="true">
            </div>
            <div class="col-12 col-md-2">
              <label for="edit-station-lng" class="form-label small mb-1">Longitude</label>
              <input type="text" name="longitude" id="edit-station-lng" class="form-control form-control-sm bg-light" inputmode="decimal" required value="${lng}" aria-required="true">
            </div>
            <div class="col-6 col-md-auto ms-md-auto mt-3 mt-md-0">
              <button type="button" class="btn btn-sm-outline w-100" id="cancel-edit-station" aria-label="Cancel editing station">Cancel</button>
            </div>
            <div class="col-6 col-md-auto mt-3 mt-md-0">
              <button type="submit" class="btn btn-sm-pf w-100" aria-label="Save station changes">Save</button>
            </div>
          </div>
        </form>
      </div>
    `;

    stationsListContainer.prepend(container);

    const typeSelect = document.getElementById('edit-station-type');
    const otherGroup = document.getElementById('edit-station-other-group');
    const otherInput = document.getElementById('edit-station-other-type');
    function toggleOther() {
      const isOther = typeSelect.value === 'Other';
      otherGroup.classList.toggle('d-none', !isOther);
      if (otherInput) otherInput.required = isOther;
    }
    typeSelect.addEventListener('change', toggleOther);

    if (coordinateInputUtils) {
      coordinateInputUtils.attachCoordinateInputGuards([
        document.getElementById('edit-station-lat'),
        document.getElementById('edit-station-lng')
      ]);
    }

    if (lat && lng) {
      const latNum = parseFloat(lat);
      const lngNum = parseFloat(lng);
      if (!isNaN(latNum) && !isNaN(lngNum)) {
        if (editTempMarker) map.removeLayer(editTempMarker);
        editTempMarker = L.marker([latNum, lngNum]).addTo(map)
          .bindPopup(`<strong>Editing: ${code}</strong><br>Lat: ${latNum}<br>Lng: ${lngNum}`)
          .openPopup();
      }
    }

    setTimeout(function () { container.classList.remove('lines-inline-form-flash'); }, 500);

    scrollAndFocusForm(container);

    const focusTrapHandler = makeFocusTrapHandler(container, doCancel);
    document.addEventListener('keydown', focusTrapHandler);

    function doCancel() {
      document.removeEventListener('keydown', focusTrapHandler);
      container.remove();
      activeMode = null;
      if (editTempMarker) { map.removeLayer(editTempMarker); editTempMarker = null; }
      triggerBtn.focus();
    }

    document.getElementById('cancel-edit-station').addEventListener('click', doCancel);
  }

  // ── Map Click Handler for Coordinates ──────────────────────────────────────
  map.on('click', function (e) {
    if (!activeMode) return;

    const lat = e.latlng.lat.toFixed(6);
    const lng = e.latlng.lng.toFixed(6);

    if (activeMode === 'addTrap') {
      const latInput = document.getElementById('inline-lat');
      const lngInput = document.getElementById('inline-lng');
      if (latInput) latInput.value = lat;
      if (lngInput) lngInput.value = lng;

      const announce = document.getElementById('inline-coord-announce');
      if (announce) announce.textContent = `Coordinates set to latitude ${lat}, longitude ${lng}`;

      if (tempMarker) map.removeLayer(tempMarker);
      tempMarker = L.marker([lat, lng]).addTo(map)
        .bindPopup(`<strong>New Trap Location</strong><br>Lat: ${lat}<br>Lng: ${lng}`)
        .openPopup();
    } else if (activeMode === 'addStation') {
      const latInput = document.getElementById('inline-station-lat');
      const lngInput = document.getElementById('inline-station-lng');
      if (latInput) latInput.value = lat;
      if (lngInput) lngInput.value = lng;

      const announce = document.getElementById('inline-station-coord-announce');
      if (announce) announce.textContent = `Coordinates set to latitude ${lat}, longitude ${lng}`;

      if (tempStationMarker) map.removeLayer(tempStationMarker);
      tempStationMarker = L.marker([lat, lng]).addTo(map)
        .bindPopup(`<strong>New Station Location</strong><br>Lat: ${lat}<br>Lng: ${lng}`)
        .openPopup();
    } else if (activeMode === 'editTrap') {
      const latInput = document.getElementById('edit-trap-lat');
      const lngInput = document.getElementById('edit-trap-lng');
      if (latInput) latInput.value = lat;
      if (lngInput) lngInput.value = lng;

      const announce = document.getElementById('edit-trap-coord-announce');
      if (announce) announce.textContent = `Coordinates set to latitude ${lat}, longitude ${lng}`;

      if (editTempMarker) map.removeLayer(editTempMarker);
      editTempMarker = L.marker([lat, lng]).addTo(map)
        .bindPopup(`<strong>Updated Location</strong><br>Lat: ${lat}<br>Lng: ${lng}`)
        .openPopup();
    } else {
      const latInput = document.getElementById('edit-station-lat');
      const lngInput = document.getElementById('edit-station-lng');
      if (latInput) latInput.value = lat;
      if (lngInput) lngInput.value = lng;

      const announce = document.getElementById('edit-station-coord-announce');
      if (announce) announce.textContent = `Coordinates set to latitude ${lat}, longitude ${lng}`;

      if (editTempMarker) map.removeLayer(editTempMarker);
      editTempMarker = L.marker([lat, lng]).addTo(map)
        .bindPopup(`<strong>Updated Location</strong><br>Lat: ${lat}<br>Lng: ${lng}`)
        .openPopup();
    }
  });

  // ── Auto-open forms if redirected back with errors ─────────────────────────
  const urlParams = new URLSearchParams(window.location.search);

  if (urlParams.get('edit_trap') && trapsListContainer) {
    const trapId = urlParams.get('edit_trap');
    const triggerBtn = trapsListContainer.querySelector(`[data-edit-trap="${trapId}"]`);
    if (triggerBtn) {
      const errorMsg = urlParams.get('error') || null;
      const prefill = {
        code: urlParams.get('code') || triggerBtn.dataset.trapCode,
        trapType: urlParams.get('trap_type') || triggerBtn.dataset.trapType,
        lat: urlParams.get('latitude') || triggerBtn.dataset.trapLat,
        lng: urlParams.get('longitude') || triggerBtn.dataset.trapLng,
      };
      openEditTrapForm(triggerBtn, errorMsg, prefill);

      if (prefill.lat && prefill.lng && !isNaN(parseFloat(prefill.lat)) && !isNaN(parseFloat(prefill.lng))) {
        if (editTempMarker) {
          editTempMarker.setLatLng([parseFloat(prefill.lat), parseFloat(prefill.lng)]);
        }
      }
    }
  }

  // ── Auto-open Edit Station form if redirected back with errors ──────────────
  if (urlParams.get('edit_station') && stationsListContainer) {
    const stationId = urlParams.get('edit_station');
    const triggerBtn = stationsListContainer.querySelector(`[data-edit-station="${stationId}"]`);
    if (triggerBtn) {
      const errorMsg = urlParams.get('error') || null;
      const prefill = {
        code: urlParams.get('code') || triggerBtn.dataset.stationCode,
        stationType: urlParams.get('station_type') || triggerBtn.dataset.stationType,
        otherType: urlParams.get('other_type') || triggerBtn.dataset.otherType,
        lat: urlParams.get('latitude') || triggerBtn.dataset.stationLat,
        lng: urlParams.get('longitude') || triggerBtn.dataset.stationLng,
      };
      openEditStationForm(triggerBtn, errorMsg, prefill);

      if (prefill.lat && prefill.lng && !isNaN(parseFloat(prefill.lat)) && !isNaN(parseFloat(prefill.lng))) {
        if (editTempMarker) {
          editTempMarker.setLatLng([parseFloat(prefill.lat), parseFloat(prefill.lng)]);
        }
      }
    }
  }

  // ── Auto-open Add Station form if redirected back with errors ──────────────
  if (urlParams.get('add_station') === '1' && addStationBtn) {
    addStationBtn.click();

    const errorMsg = urlParams.get('error');
    if (errorMsg) insertFormError('new-station-form-container', errorMsg);

    const codeInput = document.getElementById('inline-station-code');
    const typeSelect = document.getElementById('inline-station-type');
    const otherInput = document.getElementById('inline-station-other-type');
    const otherGroup = document.getElementById('inline-station-other-group');
    const latInput = document.getElementById('inline-station-lat');
    const lngInput = document.getElementById('inline-station-lng');

    if (codeInput && urlParams.get('code')) codeInput.value = urlParams.get('code');
    if (typeSelect && urlParams.get('station_type')) {
      typeSelect.value = urlParams.get('station_type');
      if (typeSelect.value === 'Other' && otherGroup) {
        otherGroup.classList.remove('d-none');
        if (otherInput) otherInput.required = true;
      }
    }
    if (otherInput && urlParams.get('other_type')) otherInput.value = urlParams.get('other_type');
    if (latInput && urlParams.get('latitude')) latInput.value = urlParams.get('latitude');
    if (lngInput && urlParams.get('longitude')) lngInput.value = urlParams.get('longitude');

    if (coordinateInputUtils) {
      if (latInput) latInput.value = coordinateInputUtils.sanitizeCoordinateValue(latInput.value);
      if (lngInput) lngInput.value = coordinateInputUtils.sanitizeCoordinateValue(lngInput.value);
    }

    if (latInput && latInput.value && lngInput && lngInput.value) {
      const lat = parseFloat(latInput.value);
      const lng = parseFloat(lngInput.value);
      if (!isNaN(lat) && !isNaN(lng)) {
        tempStationMarker = L.marker([lat, lng]).addTo(map)
          .bindPopup(`<strong>New Station Location</strong><br>Lat: ${lat}<br>Lng: ${lng}`)
          .openPopup();
      }
    }
  }

  // ── Auto-open Add Trap form if redirected back with errors ─────────────────
  if (urlParams.get('add_trap') === '1' && addTrapBtn) {
    addTrapBtn.click();

    const errorMsg = urlParams.get('error');
    if (errorMsg) insertFormError('new-trap-form-container', errorMsg);

    const codeInput = document.querySelector('input[name="code"]');
    const typeSelect = document.querySelector('select[name="trap_type"]');
    const latInput = document.getElementById('inline-lat');
    const lngInput = document.getElementById('inline-lng');

    if (codeInput && urlParams.get('code')) codeInput.value = urlParams.get('code');
    if (typeSelect && urlParams.get('trap_type')) typeSelect.value = urlParams.get('trap_type');
    if (latInput && urlParams.get('latitude')) latInput.value = urlParams.get('latitude');
    if (lngInput && urlParams.get('longitude')) lngInput.value = urlParams.get('longitude');

    if (coordinateInputUtils) {
      if (latInput) latInput.value = coordinateInputUtils.sanitizeCoordinateValue(latInput.value);
      if (lngInput) lngInput.value = coordinateInputUtils.sanitizeCoordinateValue(lngInput.value);
    }

    if (latInput && latInput.value && lngInput && lngInput.value) {
      const lat = parseFloat(latInput.value);
      const lng = parseFloat(lngInput.value);
      if (!isNaN(lat) && !isNaN(lng)) {
        tempMarker = L.marker([lat, lng]).addTo(map)
          .bindPopup(`<strong>New Trap Location</strong><br>Lat: ${lat}<br>Lng: ${lng}`)
          .openPopup();
      }
    }
  }
});

// Safari BFCache: modals can get stuck open with backdrop when navigating back
window.addEventListener('pageshow', function (event) {
  if (event.persisted) {
    ['retire-trap-modal', 'retire-station-modal'].forEach(function (id) {
      const modal = document.getElementById(id);
      if (modal) {
        modal.style.display = 'none';
        modal.classList.remove('show');
      }
    });
    document.querySelectorAll('.modal-backdrop').forEach(function (b) { b.remove(); });
    document.body.classList.remove('modal-open');
    document.body.style.removeProperty('overflow');
    document.body.style.removeProperty('padding-right');
    window.location.reload();
  }
});
