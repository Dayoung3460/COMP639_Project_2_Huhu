/*
 * static/js/edit-trap.js
 * Edit trap form enhancements.
 */

document.addEventListener('DOMContentLoaded', function () {
  if (!window.coordinateInputUtils) return;

  window.coordinateInputUtils.attachCoordinateInputGuards([
    document.getElementById('trapLatitude'),
    document.getElementById('trapLongitude')
  ]);
});
