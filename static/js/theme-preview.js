/**
 * theme-preview.js — Live preview shared by the gallery and the
 * customise history page.
 *
 * Wires every .theme-tile-preview-btn on the page so clicking it
 * applies its theme's CSS vars to <html> and flips body classes for
 * the layout axes (nav position + content width). No DB write — this
 * is a transient overlay on top of whatever the server rendered.
 * Navigating away or reloading reverts to the saved theme.
 *
 * Each button is expected to carry:
 *   data-preview-primary           hex string
 *   data-preview-secondary         hex string
 *   data-preview-background        hex string
 *   data-preview-font-heading      font-family name
 *   data-preview-font-body         font-family name
 *   data-preview-button-radius     CSS length ('8px' | '0')
 *   data-preview-nav               'sidebar' | 'topbar'
 *   data-preview-width             'wrap' | 'full'
 *
 * `.is-previewing` is toggled on the nearest .theme-tile OR
 * .theme-history-row ancestor so the same script works for both pages
 * — the gallery's tile ring and the history row's highlight stay
 * scoped to their respective layouts.
 */
(function () {
  'use strict';

  const root = document.documentElement;
  const body = document.body;
  const buttons = document.querySelectorAll('.theme-tile-preview-btn');
  if (!buttons.length) return;

  function applyPreview(btn) {
    const d = btn.dataset;
    root.style.setProperty('--theme-primary',       d.previewPrimary);
    root.style.setProperty('--theme-secondary',     d.previewSecondary);
    root.style.setProperty('--theme-background',    d.previewBackground);
    root.style.setProperty('--theme-font-heading',  '"' + d.previewFontHeading + '"');
    root.style.setProperty('--theme-font-body',     '"' + d.previewFontBody + '"');
    root.style.setProperty('--theme-button-radius', d.previewButtonRadius);

    body.classList.remove('layout-nav-sidebar', 'layout-nav-topbar');
    body.classList.add('layout-nav-' + d.previewNav);
    body.classList.remove('layout-width-wrap', 'layout-width-full');
    body.classList.add('layout-width-' + d.previewWidth);

    document.querySelectorAll('.is-previewing').forEach(function (el) {
      el.classList.remove('is-previewing');
    });
    const host = btn.closest('.theme-tile, .theme-history-row');
    if (host) host.classList.add('is-previewing');
  }

  buttons.forEach(function (btn) {
    btn.addEventListener('click', function () { applyPreview(btn); });
  });
})();
