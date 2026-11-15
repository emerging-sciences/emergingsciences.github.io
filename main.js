function toggleMenu() {
  document.getElementById('mobileMenu').classList.toggle('open');
}

// --- Botpress chatbot --------------------------------------------------------------------------
// The chatbot is NOT on the page until the "Ask" button is pressed. Nothing from Botpress is loaded
// before that, so its round logo can never flash on a tap. The logo (launcher) is also kept hidden
// after loading: the chat opens only from "Ask" (openChat below).
var BP = {
  js:  'https://cdn.botpress.cloud/webchat/v5.0/inject.js',
  cfg: 'https://files.bpcontent.cloud/2026/09/27/17/20260927173023-HO130OD7.js',
  state: 0                       // 0 = not loaded, 1 = loading, 2 = ready
};
var BP_HIDE_CSS = '.bpFabWrapper,.bpFab,.bpFabImage{display:none!important}';

// Botpress draws inside a shadow DOM, so page CSS cannot reach its logo. Hide it in every shadow root.
function bpHideIn(root) {
  if (!root || root.__esHide) return;
  root.__esHide = true;
  try {
    var sh = new CSSStyleSheet();
    sh.replaceSync(BP_HIDE_CSS);
    root.adoptedStyleSheets = Array.prototype.concat.call([], root.adoptedStyleSheets || [], [sh]);
  } catch (e) {
    try { var st = document.createElement('style'); st.textContent = BP_HIDE_CSS; root.appendChild(st); } catch (e2) {}
  }
}
function bpScan() {
  var n = document.body ? document.body.children : [];
  for (var i = 0; i < n.length; i++) bpHideIn(n[i].shadowRoot);
}
function bpGuard() {
  if (window.__esBpGuard) return;
  window.__esBpGuard = true;
  // Runs the moment Botpress creates its shadow root, i.e. before the logo is ever painted.
  var orig = Element.prototype.attachShadow;
  Element.prototype.attachShadow = function (o) {
    var r = orig.call(this, o);
    bpHideIn(r);
    return r;
  };
  var k = 0;
  (function again() { bpScan(); if (k++ < 40) setTimeout(again, 250); })();
}

function bpToast(msg) {
  var t = document.getElementById('es-bp-toast');
  if (!msg) { if (t) t.remove(); return; }
  if (!t) {
    t = document.createElement('div');
    t.id = 'es-bp-toast';
    t.setAttribute('role', 'status');
    t.style.cssText = 'position:fixed;left:50%;transform:translateX(-50%);bottom:calc(92px + env(safe-area-inset-bottom,0px));' +
      'z-index:9999;background:var(--surface2,#131625);color:var(--text,#ECEEF5);border:1px solid var(--border-strong,rgba(255,255,255,.16));' +
      'border-radius:12px;padding:10px 16px;font-size:14px;box-shadow:0 8px 24px rgba(0,0,0,.4)';
    document.body.appendChild(t);
  }
  t.textContent = msg;
}

function bpFail() {
  BP.state = 0;
  ['es-bp-inject', 'es-bp-cfg'].forEach(function (id) { var n = document.getElementById(id); if (n) n.remove(); });
  bpToast('');
  alert('Chatbot load nahi hua. Internet check karke dobara try karo.');
}

function bpStart() {
  BP.state = 1;
  bpToast('Chatbot khul raha hai…');
  bpGuard();
  var s = document.createElement('script');
  s.id = 'es-bp-inject';
  s.src = BP.js;
  s.onerror = bpFail;
  s.onload = function () {
    var b = window.botpress;
    if (!b) { bpFail(); return; }
    var opened = false;
    function go() {                 // chat is initialised: open it (Botpress asks for a short delay)
      if (opened) return;
      opened = true;
      BP.state = 2;
      setTimeout(function () { try { window.botpress.open(); } catch (e) {} bpToast(''); }, 500);
    }
    // The listener must exist before the config script runs init(), otherwise the event is missed.
    try { b.on('webchat:initialized', go); } catch (e) {}
    try { b.on('webchat:opened', function () { bpToast(''); }); } catch (e) {}
    var c = document.createElement('script');
    c.id = 'es-bp-cfg';
    c.src = BP.cfg;
    c.onerror = bpFail;
    c.onload = function () { setTimeout(go, 6000); };   // safety net if the event never arrives
    document.body.appendChild(c);
  };
  document.body.appendChild(s);
}

// --- "Ask" button: opens the Botpress chatbot ---
function openChat(e) {
  if (e) e.preventDefault();
  // mobile menu band kar do
  var mm = document.getElementById('mobileMenu');
  if (mm) mm.classList.remove('open');

  if (BP.state === 1) return;                         // already loading
  if (window.botpress && typeof window.botpress.open === 'function') {
    bpGuard();                                        // (also covers a page that still has the old script tags)
    BP.state = 2;
    window.botpress.open();
    return;
  }
  bpStart();
}
