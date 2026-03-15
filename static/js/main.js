/*
 * static/js/main.js — PF-LU shared JavaScript
 */

// Auto-dismiss flash messages after 4 seconds
document.addEventListener('DOMContentLoaded', function () {
  setTimeout(function () {
    document.querySelectorAll('.alert.alert-dismissible').forEach(function (el) {
      bootstrap.Alert.getOrCreateInstance(el).close();
    });
  }, 4000);
});
