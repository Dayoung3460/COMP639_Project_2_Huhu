/*
 * auth-login.js
 * Handles login-page UI interactions.
 */

(function () {
  const input = document.getElementById('passwordInput');
  const button = document.getElementById('togglePassword');
  const icon = document.getElementById('toggleIcon');

  if (!input || !button || !icon) return;

  button.addEventListener('click', function () {
    const isPassword = input.type === 'password';
    input.type = isPassword ? 'text' : 'password';
    icon.classList.toggle('bi-eye', !isPassword);
    icon.classList.toggle('bi-eye-slash', isPassword);
  });
})();
