/*
 * dev-quick-login.js
 * Testing helper for fast role-based login on the login page.
 *
 * Remove this file and the corresponding script tag/quick-login section
 * in app/templates/auth/login.html when no longer needed.
 */

(function () {
  const loginForm = document.getElementById('loginForm');
  if (!loginForm) return;

  const usernameInput = loginForm.querySelector('input[name="username"]');
  const passwordInput = loginForm.querySelector('input[name="password"]');
  const quickLoginButtons = document.querySelectorAll('.quick-login-btn');

  if (!usernameInput || !passwordInput || !quickLoginButtons.length) return;

  quickLoginButtons.forEach((button) => {
    button.addEventListener('click', () => {
      const username = button.dataset.username || '';
      const password = button.dataset.password || '';

      usernameInput.value = username;
      passwordInput.value = password;

      loginForm.submit();
    });
  });
})();
