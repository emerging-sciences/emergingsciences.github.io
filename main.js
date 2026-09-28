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

// --- Google Sheet Sync Code ---
const SHEET_API_URL = "https://script.google.com/macros/s/AKfycbwAZfY3eanWymqzfXh66ga4OK4xsc0mnjze_2tFxC8mxEQt_R_qXOjM_jkGLtqahxdW/exec";

async function loadData() {
  try {
    let response = await fetch(SHEET_API_URL);
    let data = await response.json();
    
    if (document.getElementById('lectures-container')) {
      let container = document.getElementById('lectures-container');
      container.innerHTML = "";
      data.forEach(item => {
        let card = `
          <a href="${item.link}" target="_blank" class="lec-card">
            <div class="lec-thumb">▶</div>
            <div class="lec-info">
              <div class="lec-num">${item.num}</div>
              <div class="lec-title">${item.title}</div>
              <div class="lec-tags"><span class="ltag">${item.tag}</span></div>
            </div>
          </a>
        `;
        container.innerHTML += card;
      });
    }
  } catch (error) {
    console.error("Error loading data from Google Sheet:", error);
  }
}

document.addEventListener("DOMContentLoaded", loadData);
