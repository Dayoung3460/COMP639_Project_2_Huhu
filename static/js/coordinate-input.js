/*
 * static/js/coordinate-input.js
 * Restrict coordinate inputs to signed decimal numbers only.
 */

(function (window) {
  function sanitizeCoordinateValue(value) {
    let sanitized = '';
    let hasDecimalPoint = false;

    for (let index = 0; index < value.length; index += 1) {
      const character = value[index];

      if (character >= '0' && character <= '9') {
        sanitized += character;
        continue;
      }

      if (character === '-' && sanitized.length === 0) {
        sanitized += character;
        continue;
      }

      if (character === '.' && !hasDecimalPoint) {
        sanitized += character;
        hasDecimalPoint = true;
      }
    }

    return sanitized;
  }

  function normalizeIncompleteCoordinate(input) {
    if (!input) return;

    if (input.value === '-' || input.value === '.' || input.value === '-.') {
      input.value = '';
    }
  }

  function attachCoordinateInputGuard(input) {
    if (!input) return;

    input.setAttribute('inputmode', 'decimal');
    input.setAttribute('autocomplete', 'off');

    input.addEventListener('input', function () {
      const sanitized = sanitizeCoordinateValue(input.value);

      if (input.value !== sanitized) {
        input.value = sanitized;
      }
    });

    input.addEventListener('blur', function () {
      normalizeIncompleteCoordinate(input);
    });
  }

  function attachCoordinateInputGuards(inputs) {
    Array.from(inputs || []).forEach(attachCoordinateInputGuard);
  }

  window.coordinateInputUtils = {
    attachCoordinateInputGuard: attachCoordinateInputGuard,
    attachCoordinateInputGuards: attachCoordinateInputGuards,
    sanitizeCoordinateValue: sanitizeCoordinateValue
  };
})(window);
