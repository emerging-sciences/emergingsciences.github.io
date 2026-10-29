// SUPPORT PAGE SETTINGS — edit this file only (data.js is not touched).
// After every edit check for a missing comma or quote.
window.ES_SUPPORT = {
  "name": "Piyush Agarwal",

  // Optional photo: upload a file (e.g. piyush.jpg) to the repo and write its name here. Leave "" for no photo.
  "photo": "",

  // Your PUBLIC UPI id (people can only SEND money to it, never take). Example: "yourname@okhdfcbank". Leave "" until ready.
  "upi": "piyush4518@axl",

  // QR image downloaded from your UPI app (e.g. upi-qr.png), uploaded to the repo. Leave "" if none.
  "qr": "upi-qr.png",

  // Where the money goes. Edit these lines so they are exactly true.
  "uses": [
    "AI tool subscription used to prepare lectures, notes and mock-test questions",
    "Other tools and internet needed to create and upload content"
  ],

  // Family photo + line shown as a separate card on the Support page. Upload the photo to the repo with the same file name.
  "story": {
    "photo": "blessings.jpg",
    "line": "Dada ji aur Dadi ji ke ashirwad ke saath.",
    "caption": "Bachpan ki meri sabse pyaari photo. Unhi ke ashirwad se main ye kaam kar raha hu, taaki shiksha kisi ke liye bhi paise ki wajah se na ruke.",
    "alt": "Piyush Agarwal bachpan me apne dada ji aur dadi ji ke saath"
  },

  // LIVE ACCOUNT SHEET (optional). Google Sheet -> File -> Share -> Publish to web -> pick the tab -> "Comma-separated values (.csv)" -> Publish -> paste that link here.
  // Sheet header row must be:  date | type | amount | who | note | proof   (type = in or out). Leave "" to use the ledger below instead.
  "sheet": "https://docs.google.com/spreadsheets/d/e/2PACX-1vRMqGQgd5PSTcmaJAaAWIYQSRkJGBNeyHv_W2tcYlYM2OEqpKX_RDa93buZhbQWUhahbxx5o6YxpuX-/pub?gid=0&single=true&output=csv",

  // PUBLIC ACCOUNT BOOK (used when "sheet" is empty or cannot load). Add one line for every rupee that comes in or goes out. Newest can be added at the end.
  //   money received : { "d": "2026-11-02", "type": "in",  "amt": 100, "who": "Rahul K.", "note": "" }
  //   money spent    : { "d": "2026-11-05", "type": "out", "amt": 399, "note": "AI subscription (1 month)", "proof": "https://link-to-bill-screenshot" }
  // "who" = first name or "Anonymous" (ask the donor). "proof" is optional but builds trust.
  "ledger": []
};
