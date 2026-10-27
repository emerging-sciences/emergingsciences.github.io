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
