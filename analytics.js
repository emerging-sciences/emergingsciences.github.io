/* Visitor counting with GoatCounter (free, no cookies). Loaded on every page by nav.js.
   1) Sign up at goatcounter.com and choose a site code (e.g. emergingsciences).
   2) Write that code between the quotes below. Leave it empty "" to switch counting off. */
(function(){
  var CODE = "";

  window.ES_GC_ON = !!CODE;
  if(!CODE || window.__esgc) return;
  if(navigator.doNotTrack === "1") { window.ES_GC_ON = false; return; }   /* respect "Do Not Track" */
  window.__esgc = 1;
  var s = document.createElement("script");
  s.async = true;
  s.src = "https://gc.zgo.at/count.js";
  s.setAttribute("data-goatcounter", "https://" + CODE + ".goatcounter.com/count");
  document.head.appendChild(s);
})();
