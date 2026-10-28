function toggleMenu() {
  document.getElementById('mobileMenu').classList.toggle('open');
}

// --- "Ask" button: opens the Botpress chatbot ---
function openChat(e) {
  if (e) e.preventDefault();
  // mobile menu band kar do
  var mm = document.getElementById('mobileMenu');
  if (mm) mm.classList.remove('open');

  var tries = 0;
  (function tryOpen() {
    if (window.botpress && typeof window.botpress.open === 'function') {
      window.botpress.open();
    } else if (tries++ < 20) {          // chatbot load ho raha ho to 5 sec tak wait
      setTimeout(tryOpen, 250);
    } else {
      alert('Chatbot abhi load nahi hua. Page refresh karke dobara try karo.');
    }
  })();
}

// --- Hide Botpress floating logo (it lives inside a shadow DOM, so page CSS can't reach it) ---
// The chat still opens from the "Ask" button via openChat() above.
(function hideBpFab() {
  var tries = 0;
  (function look() {
    var hosts = document.querySelectorAll('body *');
    for (var i = 0; i < hosts.length; i++) {
      var root = hosts[i].shadowRoot;
      if (root && root.querySelector('.bpFab') && !root.getElementById('es-hide-fab')) {
        var st = document.createElement('style');
        st.id = 'es-hide-fab';
        st.textContent = '.bpFabWrapper,.bpFab{display:none!important}';
        root.appendChild(st);
      }
    }
    if (tries++ < 60) setTimeout(look, 500);   // keep checking for 30 sec while Botpress loads
  })();
})();
