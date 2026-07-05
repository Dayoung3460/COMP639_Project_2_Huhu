/*
 * photo-preview.js
 * Live preview for the profile-photo file input (#photoInput → #photoPreview).
 * Shared by register and edit-profile pages. The register page additionally
 * has #photoFilename, #photoRemove and #firstNameInput — those are optional
 * and skipped when absent.
 */

(function () {
  const photoInput = document.getElementById('photoInput');
  const photoPreview = document.getElementById('photoPreview');
  const photoFilename = document.getElementById('photoFilename');
  const photoRemove = document.getElementById('photoRemove');
  const firstNameInput = document.getElementById('firstNameInput');

  if (!photoInput || !photoPreview) return;

  function fallbackInitial() {
    const initial = firstNameInput
      ? (firstNameInput.value.trim().charAt(0) || '?').toUpperCase()
      : '?';
    photoPreview.textContent = initial;
  }

  function reset() {
    photoInput.value = '';
    if (photoFilename) photoFilename.textContent = 'No file chosen';
    if (photoRemove) photoRemove.hidden = true;
    fallbackInitial();
  }

  photoInput.addEventListener('change', function () {
    const file = this.files && this.files[0];
    if (!file) {
      // Register shows the initial again; edit-profile keeps the current photo.
      if (photoRemove) reset();
      return;
    }
    if (photoFilename) photoFilename.textContent = file.name;
    if (photoRemove) photoRemove.hidden = false;
    const reader = new FileReader();
    reader.onload = function (e) {
      const img = document.createElement('img');
      img.src = e.target.result;
      img.alt = '';
      photoPreview.replaceChildren(img);
    };
    reader.readAsDataURL(file);
  });

  if (photoRemove) {
    photoRemove.addEventListener('click', reset);
  }

  if (firstNameInput) {
    firstNameInput.addEventListener('input', function () {
      if (!photoInput.files[0]) fallbackInitial();
    });
  }
})();