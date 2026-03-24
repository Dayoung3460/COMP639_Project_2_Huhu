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
      let trapTypes = ['SA200', 'SA250', 'DOC150', 'DOC200', 'DOC250', 'Timms', 'Live Capture', 'Goodnature A24', 'Other'];
      if (addTrapBtn.dataset.trapTypes) {
        try { trapTypes = JSON.parse(addTrapBtn.dataset.trapTypes); } catch (e) {}
      }

      const newRow = document.createElement('div');
      newRow.id = 'new-trap-form-container';
      newRow.className = 'card mb-3 shadow-sm';
      newRow.style.borderColor = '#1a5c38';
      newRow.innerHTML = `
        <div class="card-body py-3">
          <h6 class="card-title mb-2" style="color: #1a5c38;">Add Trap</h6>
          <form id="new-trap-inline-form" method="POST" action="${newTrapUrl}">
            <div class="row g-0 mb-1">
              <div class="col-md-4 text-center" style="margin-left: 24%;">
                <small class="fw-medium" style="color: #1a5c38;"><i class="bi bi-geo-alt-fill me-1"></i>Click on the map above to set coordinates</small>
              </div>
            </div>
            <div class="row g-2 align-items-end">
              <div class="col-md-1">
                <label class="form-label small mb-1">Code</label>
                <input type="text" name="code" class="form-control form-control-sm" required placeholder="e.g. CL-01">
              </div>
              <div class="col-md-2 ms-3">
                <label class="form-label small mb-1">Type</label>
                <select name="trap_type" class="form-select form-select-sm" required>
                  <option value="">Select...</option>
                  ${trapTypes.map(t => `<option value="${t}">${t}</option>`).join('')}
                </select>
              </div>
              <div class="col-md-2 ms-5">
                <label class="form-label small mb-1">Latitude</label>
                <input type="text" name="latitude" id="inline-lat" class="form-control form-control-sm bg-light" required placeholder="e.g. -43.640914">
              </div>
              <div class="col-md-2 ms-4">
                <label class="form-label small mb-1">Longitude</label>
                <input type="text" name="longitude" id="inline-lng" class="form-control form-control-sm bg-light" required placeholder="e.g. 172.475682">
              </div>
              <div class="col-md-1 ms-auto">
                <button type="button" class="btn btn-outline-secondary btn-sm w-100" id="cancel-add-trap">Cancel</button>
              </div>
              <div class="col-md-1">
              <button type="submit" class="btn btn-pf btn-sm w-100">Save</button>
              </div>
            </div>
          </form>
        </div>
      `;

      // Insert at the top of the list
      trapsListContainer.prepend(newRow);

      // Flash effect (briefly highlight the background in a soft green)
      newRow.style.transition = 'background-color 0.5s ease-out';
      newRow.style.backgroundColor = '#d4edda';
      setTimeout(() => {
        newRow.style.backgroundColor = '';
      }, 500);

      // Scroll into view, wait a split second, then push down an extra ~1cm (40px)
      newRow.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      setTimeout(() => {
        window.scrollBy({ top: 40, behavior: 'smooth' });
      }, 250);

      // Handle Cancel
      document.getElementById('cancel-add-trap').addEventListener('click', function () {
        newRow.remove();
        isAddingTrap = false;
        if (tempMarker) {
          map.removeLayer(tempMarker);
          tempMarker = null;
        }
      });
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
        const cardBody = formContainer.querySelector('.card-body');
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-danger py-2 px-3 mb-3 small';

        const icon = document.createElement('i');
        icon.className = 'bi bi-exclamation-triangle-fill me-2';
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