/*
 * auth-register.js
 * Register-page UI: password show/hide toggles and the strength meter.
 * Photo preview lives in the shared photo-preview.js.
 */

// ── Password show/hide toggles (both fields) ────────────
(function () {
  function wire(buttonId, inputId) {
    const btn = document.getElementById(buttonId);
    const input = document.getElementById(inputId);
    if (!btn || !input) return;
    btn.addEventListener('click', function () {
      const shown = input.type === 'text';
      input.type = shown ? 'password' : 'text';
      btn.setAttribute('aria-pressed', shown ? 'false' : 'true');
      btn.setAttribute('aria-label', shown ? 'Show password' : 'Hide password');
    });
  }
  wire('togglePassword', 'passwordInput');
  wire('toggleConfirmPassword', 'confirmPasswordInput');
})();

// ── Password strength meter ─────────────────────────────
(function () {
  const input = document.getElementById('passwordInput');
  const bar = document.getElementById('strengthBar');
  const label = document.getElementById('strengthLabel');
  const checks = document.getElementById('strengthChecks');
  if (!input || !bar || !label || !checks) return;

  const labels = ['', 'Weak', 'Fair', 'Strong', 'Very strong'];

  function evaluate(pw) {
    const rules = {
      length: pw.length >= 8,
      upper: /[A-Z]/.test(pw),
      lower: /[a-z]/.test(pw),
      number: /[0-9]/.test(pw),
    };

    const passed = Object.values(rules).filter(Boolean).length;

    // Bonus point for length ≥ 14 — bumps to "very strong"
    let score = passed;
    if (passed === 4 && pw.length >= 14) score = 4;
    else if (passed === 4) score = 3;
    else if (passed === 3) score = 2;
    else if (passed >= 1) score = 1;
    else score = 0;

    return { rules: rules, score: score };
  }

  input.addEventListener('input', function () {
    const pw = input.value;
    if (!pw) {
      bar.setAttribute('data-strength', '0');
      label.textContent = 'Enter a password to see strength';
      checks.querySelectorAll('li').forEach(function (li) {
        li.removeAttribute('data-met');
      });
      return;
    }

    const result = evaluate(pw);
    bar.setAttribute('data-strength', String(result.score));
    label.textContent = labels[result.score] || '';

    Object.keys(result.rules).forEach(function (key) {
      const li = checks.querySelector('[data-check="' + key + '"]');
      if (!li) return;
      if (result.rules[key]) li.setAttribute('data-met', 'true');
      else li.removeAttribute('data-met');
    });
  });
})();
