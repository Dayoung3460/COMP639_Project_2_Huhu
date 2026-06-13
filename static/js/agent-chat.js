(function () {
  'use strict';

  var trigger  = document.getElementById('agentChatTrigger');
  var panel    = document.getElementById('agentChatPanel');
  var messages = document.getElementById('agentChatMessages');
  var form     = document.getElementById('agentChatForm');
  var input    = document.getElementById('agentChatInput');
  var resetBtn = document.getElementById('agentChatReset');
  var closeBtn = document.getElementById('agentChatClose');
  var sendBtn  = document.getElementById('agentChatSend');

  if (!trigger || !panel) return;

  // ── Open / close ────────────────────────────────────────────

  function open() {
    panel.classList.add('is-open');
    panel.setAttribute('aria-hidden', 'false');
    trigger.setAttribute('aria-expanded', 'true');
    input.focus();
  }

  function close() {
    panel.classList.remove('is-open');
    panel.setAttribute('aria-hidden', 'true');
    trigger.setAttribute('aria-expanded', 'false');
    trigger.focus();
  }

  trigger.addEventListener('click', open);
  closeBtn.addEventListener('click', close);

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && panel.classList.contains('is-open')) {
      close();
    }
  });

  // ── Message rendering ────────────────────────────────────────

  function appendMessage(role, text, isError) {
    var wrapper = document.createElement('div');
    wrapper.className = 'agent-chat-msg agent-chat-msg--' + role;

    var bubble = document.createElement('div');
    bubble.className = 'agent-chat-bubble' + (isError ? ' agent-chat-bubble--error' : '');
    bubble.textContent = text;

    wrapper.appendChild(bubble);
    messages.appendChild(wrapper);
    messages.scrollTop = messages.scrollHeight;
    return wrapper;
  }

  function appendTyping() {
    var wrapper = document.createElement('div');
    wrapper.className = 'agent-chat-msg agent-chat-msg--agent';
    wrapper.id = 'agentTyping';

    var bubble = document.createElement('div');
    bubble.className = 'agent-chat-bubble agent-chat-typing';
    bubble.innerHTML = '<span></span><span></span><span></span>';

    wrapper.appendChild(bubble);
    messages.appendChild(wrapper);
    messages.scrollTop = messages.scrollHeight;
  }

  function removeTyping() {
    var el = document.getElementById('agentTyping');
    if (el) el.remove();
  }

  // ── Input state ──────────────────────────────────────────────

  function setLoading(loading) {
    input.disabled  = loading;
    sendBtn.disabled = loading;
  }

  // ── Chat submit ──────────────────────────────────────────────

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    var msg = input.value.trim();
    if (!msg) return;

    input.value = '';
    appendMessage('user', msg, false);
    appendTyping();
    setLoading(true);

    fetch('/agent/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: msg }),
      credentials: 'same-origin'
    })
      .then(function (res) { return res.json(); })
      .then(function (data) {
        removeTyping();
        if (data.error) {
          appendMessage('agent', data.error, true);
        } else {
          appendMessage('agent', data.reply, false);
        }
      })
      .catch(function () {
        removeTyping();
        appendMessage('agent', 'Something went wrong. Please try again.', true);
      })
      .finally(function () {
        setLoading(false);
        input.focus();
      });
  });

  // ── Reset conversation ───────────────────────────────────────

  resetBtn.addEventListener('click', function () {
    fetch('/agent/reset', {
      method: 'POST',
      credentials: 'same-origin'
    }).catch(function () {});

    messages.innerHTML =
      '<div class="agent-chat-welcome">' +
        '<i class="bi bi-stars agent-chat-welcome-icon" aria-hidden="true"></i>' +
        '<p>Conversation reset. Ask me anything about your group\'s data or the Tiaki platform.</p>' +
      '</div>';
    input.focus();
  });
})();