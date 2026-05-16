// ── Cap date filters at today ─────────────────────────────────────────────
(function () {
  const today = new Date().toISOString().split('T')[0];
  const dateFrom = document.getElementById('date_from');
  const dateTo = document.getElementById('date_to');
  if (dateFrom) dateFrom.max = today;
  if (dateTo) dateTo.max = today;
})();

// ── Search by station code ────────────────────────────────────────────────
const stationSearch = document.getElementById('stationSearch');
if (stationSearch) {
  stationSearch.addEventListener('input', function () {
    const term = this.value.toLowerCase().trim();
    document.querySelectorAll('#recordsTable tbody tr').forEach(row => {
      const code = row.querySelector('td strong');
      if (!code) return;
      row.style.display = code.textContent.toLowerCase().includes(term) ? '' : 'none';
    });
  });
  stationSearch.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') e.preventDefault();
  });
}

// ── Column sorting ────────────────────────────────────────────────────────
(function () {
  const table = document.getElementById('recordsTable');
  if (!table) return;
  const headers = table.querySelectorAll('th.sortable');
  let currentCol = -1, ascending = true;

  headers.forEach(th => {
    th.style.cursor = 'pointer';
    th.addEventListener('click', function () {
      const col = parseInt(this.dataset.sortCol);
      if (currentCol === col) { ascending = !ascending; } else { currentCol = col; ascending = true; }

      const tbody = table.querySelector('tbody');
      const rows = Array.from(tbody.querySelectorAll('tr'));
      rows.sort((a, b) => {
        const cellA = a.children[col], cellB = b.children[col];
        if (!cellA || !cellB) return 0;
        let valA = cellA.dataset.sortValue || cellA.textContent.trim().toLowerCase();
        let valB = cellB.dataset.sortValue || cellB.textContent.trim().toLowerCase();
        const numA = parseFloat(valA), numB = parseFloat(valB);
        if (!isNaN(numA) && !isNaN(numB)) return ascending ? numA - numB : numB - numA;
        return ascending ? valA.localeCompare(valB) : valB.localeCompare(valA);
      });
      rows.forEach(r => tbody.appendChild(r));

      headers.forEach(h => {
        const icon = h.querySelector('i');
        if (icon) icon.className = 'bi bi-chevron-expand text-muted small';
      });
      const activeIcon = this.querySelector('i');
      if (activeIcon) activeIcon.className = ascending ? 'bi bi-chevron-up small' : 'bi bi-chevron-down small';
    });
  });
})();

// ── Text detail modal ─────────────────────────────────────────────────────
const textDetailModal = document.getElementById('textDetailModal');
if (textDetailModal) {
  textDetailModal.addEventListener('show.bs.modal', function (e) {
    const trigger = e.relatedTarget;
    if (trigger && trigger.dataset.fullText) {
      document.getElementById('textDetailBody').textContent = trigger.dataset.fullText;
    }
  });
}

// ── CSV download ──────────────────────────────────────────────────────────
function escapeCSV(val) {
  if (val == null) return '';
  const str = String(val);
  if (str.includes(',') || str.includes('"') || str.includes('\n')) {
    return '"' + str.replace(/"/g, '""') + '"';
  }
  return str;
}

function generateDownload() {
  const dataNode = document.getElementById('csv-data');
  const csvRecords = JSON.parse(dataNode.textContent);
  const headers = [
    'date', 'station', 'line', 'target species', 'active ingredient',
    'formulation', 'concentration (%)', 'bait remaining (kg)',
    'bait removed (kg)', 'bait added (kg)', 'notes', 'recorded by'
  ];
  const rows = [headers.join(',')];
  csvRecords.forEach(r => {
    const row = headers.map(h => {
      if (h === 'date' && r[h]) return `="${String(r[h]).replace(/"/g, '""')}"`;
      return escapeCSV(r[h]);
    });
    rows.push(row.join(','));
  });
  const blob = new Blob([rows.join('\n')], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = typeof CSV_FILENAME !== 'undefined' ? CSV_FILENAME : 'bait_records.csv';
  link.click();
  URL.revokeObjectURL(link.href);
}

const btn = document.getElementById('downloadCsvBtn');
if (btn) btn.addEventListener('click', generateDownload);
