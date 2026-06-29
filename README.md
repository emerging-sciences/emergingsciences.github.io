# Emerging Sciences Website

Free Mathematics platform for IIT JAM, CUET PG, TIFR & all MSc entrances.

## Files
- `index.html` — Home page
- `lectures.html` — All video lectures (L-01 to L-16)
- `material.html` — Study material / PDFs
- `style.css` — All styles
- `main.js` — Basic JS

## How to add a new lecture
Open `lectures.html`, find the last lecture card and copy-paste this block:

```html
<a href="YOUR_YOUTUBE_LINK" target="_blank" class="lec-card">
  <div class="lec-thumb">▶</div>
  <div class="lec-info">
    <div class="lec-num">L-17</div>
    <div class="lec-title">Your Lecture Title Here</div>
    <div class="lec-tags"><span class="ltag">ODE</span></div>
  </div>
</a>
```

## How to add a new PDF
Open `material.html`, find the pdf-grid section and add:

```html
<div class="pdf-card">
  <div class="pdf-icon">📄</div>
  <div class="pdf-info">
    <div class="pdf-title">Your PDF Title</div>
    <div class="pdf-desc">Description of the PDF</div>
    <div class="pdf-meta"><span class="pdf-tag">Topic</span></div>
  </div>
  <a href="YOUR_GOOGLE_DRIVE_LINK" target="_blank" class="pdf-btn">⬇ Download PDF</a>
</div>
```
