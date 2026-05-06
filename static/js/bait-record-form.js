document.addEventListener('DOMContentLoaded', function () {
  const lineSelect = document.getElementById('line_id');
  const stationSelect = document.getElementById('station_id');

  if (!lineSelect || !stationSelect) return;

  const allOptions = Array.from(stationSelect.querySelectorAll('option, optgroup'));

  function filterStations() {
    const selectedLine = lineSelect.value;
    const groups = stationSelect.querySelectorAll('optgroup');

    groups.forEach(function (group) {
      const options = group.querySelectorAll('option');
      const lineId = options[0] ? options[0].dataset.line : null;
      const visible = !selectedLine || lineId === selectedLine;
      group.style.display = visible ? '' : 'none';
      options.forEach(function (opt) {
        opt.disabled = !visible;
        if (!visible && opt.selected) {
          opt.selected = false;
          stationSelect.value = '';
        }
      });
    });
  }

  lineSelect.addEventListener('change', filterStations);
  filterStations();
});
