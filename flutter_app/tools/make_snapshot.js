// Bundles the website's current content into the app (assets/snapshot.json) so the app
// has something to show on the very first start, even without internet.
// Usage: node make_snapshot.js <website folder> <output json>
const fs = require('fs'), path = require('path'), vm = require('vm');
const [siteDir, outFile] = process.argv.slice(2);
if (!siteDir || !outFile) { console.error('usage: make_snapshot.js <siteDir> <out.json>'); process.exit(2); }

const read = (f) => { try { return fs.readFileSync(path.join(siteDir, f), 'utf8'); } catch (e) { return ''; } };
const snap = { dataJs: read('data.js'), sheetsJs: read('sheet-config.js'), csv: {}, builtAt: new Date().toISOString() };
if (!snap.dataJs) { console.error('data.js not found in ' + siteDir); process.exit(1); }

(async () => {
  try {
    const sb = { window: {} }; vm.createContext(sb);
    vm.runInContext(snap.dataJs, sb, { timeout: 3000 });
    const D = sb.window.ES_DATA;
    console.log('data.js OK: ' + D.exams.length + ' exams, ' + D.lectures.length + ' lectures, ' + D.material.length + ' PDFs');
  } catch (e) { console.warn('WARNING: data.js could not be evaluated: ' + e.message); }

  let cfg = null;
  try {
    const sb = { window: {} }; vm.createContext(sb);
    vm.runInContext(snap.sheetsJs, sb, { timeout: 3000 });
    cfg = sb.window.ES_SHEETS;
  } catch (e) { console.log('no usable sheet-config.js (' + e.message + ') - data.js only'); }

  if (cfg && cfg.pub && cfg.gids) {
    for (const tab of ['topics', 'lectures', 'material', 'pyqs', 'syllabus']) {
      const gid = cfg.gids[tab];
      if (gid === '' || gid == null) continue;
      const url = 'https://docs.google.com/spreadsheets/d/e/' + encodeURIComponent(cfg.pub) + '/pub?gid=' + encodeURIComponent(gid) + '&single=true&output=csv';
      try {
        const r = await fetch(url);
        const t = await r.text();
        if (!r.ok || /^\s*<(!doctype|html)/i.test(t)) throw new Error('HTTP ' + r.status);
        snap.csv[tab] = t;
        console.log('sheet tab ' + tab + ': ' + t.split('\n').length + ' lines');
      } catch (e) { console.warn('sheet tab ' + tab + ' skipped: ' + e.message); }
    }
  }
  fs.mkdirSync(path.dirname(outFile), { recursive: true });
  fs.writeFileSync(outFile, JSON.stringify(snap));
  console.log('snapshot written: ' + outFile + ' (' + fs.statSync(outFile).size + ' bytes)');
})();
