document.addEventListener('DOMContentLoaded', function () {
  const typeSelect = document.getElementById('station_type');
  const otherGroup = document.getElementById('other-type-group');
  const otherInput = document.getElementById('other_type');

  function toggleOther() {
    const isOther = typeSelect.value === 'Other';
    otherGroup.classList.toggle('d-none', !isOther);
    if (otherInput) otherInput.required = isOther;
  }

  if (typeSelect) {
    typeSelect.addEventListener('change', toggleOther);
    toggleOther();
  }
});
