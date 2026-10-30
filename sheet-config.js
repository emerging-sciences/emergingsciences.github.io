// GOOGLE SHEET SETTINGS — fill this once. Leave "pub" empty to keep using data.js only.
//
// 1) In your Google Sheet:  File → Share → Publish to web → choose "Entire document" and "Web page" → Publish.
//    You get a link like  https://docs.google.com/spreadsheets/d/e/2PACX-1vABC...xyz/pubhtml
//    Copy ONLY the long part between  /d/e/  and  /pub   and paste it in "pub" below.
// 2) Click each tab in the sheet. The address bar ends with  #gid=123456  — paste that number for that tab below.
//
// Check: open this in a browser, a CSV file should download:
//    https://docs.google.com/spreadsheets/d/e/<pub>/pub?gid=<topics gid>&single=true&output=csv
window.ES_SHEETS = {
  "pub": "",
  "gids": {
    "topics": "",
    "lectures": "",
    "material": "",
    "pyqs": "",
    "syllabus": ""
  }
};
