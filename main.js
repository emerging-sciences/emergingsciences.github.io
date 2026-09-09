function toggleMenu() {
  document.getElementById('mobileMenu').classList.toggle('open');
}

// --- Google Sheet Sync Code ---
const SHEET_API_URL = "https://script.google.com/macros/s/AKfycbzExGmb16kZTqC0R7XUpytnbOiKIt2KY8zW3K_WR6Ra1VcERIvO_5Hf3Ve7MN60FDrL/exec";

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
