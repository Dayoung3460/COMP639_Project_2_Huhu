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

  const map = createLincolnMap('line-map', linzApiKey);

  const lineColor = '#0d6efd';

  if (markers.length > 0) {
    const latlngs = [];

    markers.forEach(function (trap) {
      const latLng = [trap.latitude, trap.longitude];
      const isRetired = Boolean(trap.is_retired);

      const marker = L.circleMarker(latLng, getTrapMarkerStyle(isRetired, lineColor)).addTo(map);

      const statusBadge = statusBadgeHtml(isRetired);

      marker.bindPopup(`<strong>${trap.code}</strong><br>${trap.trap_type}<br>${statusBadge}`);
      latlngs.push(latLng);
    });

    if (latlngs.length >= 2) {
      const orderedLatLngs = orderPointsByNearestNeighbor(latlngs);

      L.polyline(orderedLatLngs, getLinePolylineStyle(lineIsRetired, lineColor)).addTo(map);
    }

    map.fitBounds(latlngs, { padding: [30, 30] });
  } else {
    // Fallback: Lincoln University area
    map.setView(MAP_DEFAULT_CENTER, 13);
  }

  setTimeout(function () { map.invalidateSize(); }, 0);

  // ── Inline Add Trap Functionality ──────────────────────────────────────────
  let isAddingTrap = false;
  let tempMarker = null;

  const addTrapBtn = document.getElementById('inline-add-trap-btn');
  const trapsListContainer = document.getElementById('traps-list-container');

  if (addTrapBtn && trapsListContainer) {
    addTrapBtn.addEventListener('click', function () {
      if (isAddingTrap) return; // Prevent opening multiple forms
      isAddingTrap = true;

      // Extract line ID and trap types (fallback to a default list if not provided)
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
            <div class="row g-2 align-items-end">
              <div class="col-12 col-md-1">
                <label for="inline-code" class="form-label small mb-1">Code</label>
                <input type="text" name="code" id="inline-code" class="form-control form-control-sm" required placeholder="e.g. CL-01" aria-required="true">
              </div>
              <div class="col-12 col-md-2 ms-md-3">
                <label for="inline-type" class="form-label small mb-1">Type</label>
                <select name="trap_type" id="inline-type" class="form-select form-select-sm" required aria-required="true">
                  <option value="">Select...</option>
                  ${trapTypes.map(t => `<option value="${t}">${t}</option>`).join('')}
                </select>
              </div>
              <div class="col-12 col-md-2 ms-md-5">
                <label for="inline-lat" class="form-label small mb-1">Latitude</label>
                <input type="text" name="latitude" id="inline-lat" class="form-control form-control-sm bg-light" inputmode="decimal" required placeholder="e.g. -43.640914" aria-required="true">
              </div>
              <div class="col-12 col-md-2 ms-md-4">
                <label for="inline-lng" class="form-label small mb-1">Longitude</label>
                <input type="text" name="longitude" id="inline-lng" class="form-control form-control-sm bg-light" inputmode="decimal" required placeholder="e.g. 172.475682" aria-required="true">
              </div>
              <div class="col-6 col-md-1 ms-md-auto mt-3 mt-md-0">
                <button type="button" class="btn btn-sm-outline w-100" id="cancel-add-trap" aria-label="Cancel adding trap">Cancel</button>
              </div>
              <div class="col-6 col-md-1 mt-3 mt-md-0">
              <button type="submit" class="btn btn-sm-pf w-100" aria-label="Save new trap">Save</button>
              </div>
            </div>
          </form>
        </div>
      `;

      // Insert at the top of the list
      trapsListContainer.prepend(newRow);

      if (coordinateInputUtils) {
        coordinateInputUtils.attachCoordinateInputGuards([
          document.getElementById('inline-lat'),
          document.getElementById('inline-lng')
        ]);
      }

      setTimeout(() => {
        newRow.classList.remove('lines-inline-form-flash');
      }, 500);

      // Scroll into view, wait a split second, then push down an extra ~1cm (40px)
      newRow.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      setTimeout(() => {
        window.scrollBy({ top: 40, behavior: 'smooth' });
      }, 250);

      // Focus the first input without triggering a competing scroll
      const firstInput = newRow.querySelector('input, select, button, a[href]');
      if (firstInput) firstInput.focus({ preventScroll: true });

      // Focus trap: keep Tab/Shift+Tab inside the form; Escape cancels
      const focusTrapHandler = function (e) {
        const focusable = Array.from(newRow.querySelectorAll(
          'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
        ));
        if (!focusable.length) return;
        const first = focusable[0];
        const last = focusable[focusable.length - 1];

        if (e.key === 'Tab') {
          if (e.shiftKey) {
            if (document.activeElement === first) {
              e.preventDefault();
              last.focus();
            }
          } else {
            if (document.activeElement === last) {
              e.preventDefault();
              first.focus();
            }
          }
        }

        if (e.key === 'Escape') {
          cancelAddTrap();
        }
      };
      document.addEventListener('keydown', focusTrapHandler);

      function cancelAddTrap() {
        document.removeEventListener('keydown', focusTrapHandler);
        newRow.remove();
        isAddingTrap = false;
        if (tempMarker) {
          map.removeLayer(tempMarker);
          tempMarker = null;
        }
        addTrapBtn.focus();
      }

      // Handle Cancel
      document.getElementById('cancel-add-trap').addEventListener('click', cancelAddTrap);
    });
  }

  // ── Map Click Handler for Coordinates ──────────────────────────────────────
  map.on('click', function (e) {
    if (!isAddingTrap) return; // Only capture clicks if the form is open

    const lat = e.latlng.lat.toFixed(6);
    const lng = e.latlng.lng.toFixed(6);

    // Populate the form fields
    const latInput = document.getElementById('inline-lat');
    const lngInput = document.getElementById('inline-lng');
    if (latInput) latInput.value = lat;
    if (lngInput) lngInput.value = lng;

    // Announce coordinate update to screen readers
    const announce = document.getElementById('inline-coord-announce');
    if (announce) announce.textContent = `Coordinates set to latitude ${lat}, longitude ${lng}`;

    // Update the temporary map marker
    if (tempMarker) map.removeLayer(tempMarker);
    tempMarker = L.marker([lat, lng]).addTo(map)
      .bindPopup(`<strong>New Trap Location</strong><br>Lat: ${lat}<br>Lng: ${lng}`)
      .openPopup();
  });

  // ── Auto-open Add Trap form if redirected back with errors ─────────────────
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.get('add_trap') === '1' && addTrapBtn) {
    addTrapBtn.click();

    // Show error directly in the add trap form
    const errorMsg = urlParams.get('error');
    if (errorMsg) {
      const formContainer = document.getElementById('new-trap-form-container');
      if (formContainer) {
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

        // Compensate for the extra height the error message adds to the form
        setTimeout(() => {
          window.scrollBy({ top: alertDiv.offsetHeight, behavior: 'smooth' });
        }, 300);
      }
    }

    // Populate fields
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

    // Re-create temporary map marker
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
