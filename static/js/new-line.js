document.addEventListener('DOMContentLoaded', function () {
  const nameInput = document.getElementById('name');
  if (nameInput) {
    const updateValidity = function (e) {
      e.target.setCustomValidity('');
      if (e.target.validity.patternMismatch) {
        e.target.setCustomValidity('Name cannot be empty or just spaces');
      }
    };
    nameInput.addEventListener('input', function (e) {
      updateValidity(e);
      e.target.reportValidity();
    });
    nameInput.addEventListener('invalid', updateValidity);
  }
});
