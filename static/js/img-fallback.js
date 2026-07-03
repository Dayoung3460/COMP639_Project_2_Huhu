/*
 * static/js/img-fallback.js — swap broken uploaded images for bundled defaults.
 *
 * Files under /static/images/uploads/ are user uploads and are not guaranteed
 * to exist (the hosting filesystem is ephemeral, and seed data may reference
 * files that were never deployed). Any <img> pointing there can 404.
 *
 * Avatar-style images (wrapper class contains "avatar", or alt mentions
 * "profile photo") fall back to the default profile picture; everything else
 * (covers, tiles, update photos) falls back to the default cover.
 *
 * Loaded from base.html and base_marketing.html.
 */
(function () {
  var UPLOADS_PATH = '/static/images/uploads/';
  var DEFAULT_PROFILE = '/static/images/default-profile.png';
  var DEFAULT_COVER = '/static/images/default-cover.jpg';

  function isUploadImg(img) {
    return img.src.indexOf(UPLOADS_PATH) !== -1;
  }

  function isAvatarImg(img) {
    return !!img.closest('[class*="avatar"]') ||
           (img.alt || '').toLowerCase().indexOf('profile photo') !== -1;
  }

  function applyFallback(img) {
    if (img.dataset.fallbackApplied) return;
    img.dataset.fallbackApplied = 'true';
    img.src = isAvatarImg(img) ? DEFAULT_PROFILE : DEFAULT_COVER;
  }

  // Catches images that fail after this script has loaded. Error events
  // don't bubble, so listen in the capture phase.
  document.addEventListener('error', function (event) {
    var img = event.target;
    if (img instanceof HTMLImageElement && isUploadImg(img)) {
      applyFallback(img);
    }
  }, true);

  // Catches images that already failed before this script loaded
  // (scripts sit at the end of <body>, after the images).
  document.addEventListener('DOMContentLoaded', function () {
    Array.prototype.forEach.call(document.images, function (img) {
      if (isUploadImg(img) && img.complete && img.naturalWidth === 0) {
        applyFallback(img);
      }
    });
  });
})();
