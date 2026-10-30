/* Single source for the site header + bottom navigation.
   Usage in a page:  <script src="nav.js" data-part="hdr"></script>  (where the header goes)
                     <script src="nav.js" data-part="nav"></script>  (end of body)          */
(function(){
  var me=document.currentScript,part=me&&me.getAttribute('data-part');
  var file=(location.pathname.split('/').pop()||'index.html').toLowerCase();
  var cur={'index.html':'home','':'home','lectures.html':'lectures','watch.html':'lectures','material.html':'material','mock.html':'mock','test.html':'mock','doubts.html':'doubts'}[file];
  var ic=function(p){return '<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'+p+'</svg>'};
  var fill=function(p){return '<svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor">'+p+'</svg>'};
  var items=[
    ['home','index.html','Home',ic('<path d="M3 11l9-8 9 8v10a1 1 0 01-1 1h-5v-7H9v7H4a1 1 0 01-1-1z"/>')],
    ['lectures','lectures.html','Lectures',ic('<rect x="3" y="4" width="18" height="16" rx="3"/><path d="M10 9l5 3-5 3z"/>')],
    ['material','material.html','Material',ic('<path d="M4 5a2 2 0 012-2h13v16H6a2 2 0 00-2 2z"/><path d="M4 21V5"/>')],
    ['mock','mock.html','Mock Test',ic('<rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4h6v3H9zM9 14l2 2 4-4"/>')],
    ['doubts','doubts.html','Doubts',ic('<circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 015 .5c0 1.5-2.5 2-2.5 3.5M12 17h.01"/>')],
    ['ask','#','Ask',ic('<path d="M21 12a8 8 0 01-11.6 7.1L4 20l1-4.6A8 8 0 1121 12z"/>')]
  ];
  var html;
  if(part==='hdr'){
    html='<header class="hdr"><a href="index.html" class="hdr-logo"><img src="logo-icon.png" alt="">Emerging Sciences</a><div class="hdr-r">'
     +'<a href="https://youtube.com/@EmergingSciences-msc" target="_blank" rel="noopener noreferrer" aria-label="YouTube">'+fill('<path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>')+'</a>'
     +'<a href="https://t.me/emer816" target="_blank" rel="noopener noreferrer" aria-label="Telegram">'+fill('<path d="M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12S18.627 0 12 0zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.14-.26.26-.534.26l.213-3.053 5.56-5.023c.242-.213-.054-.333-.373-.121l-6.871 4.326-2.962-.924c-.643-.204-.657-.643.136-.953l11.57-4.461c.537-.194 1.006.131.831.941z"/>')+'</a>'
     +'<a href="https://x.com/emergingsc28041" target="_blank" rel="noopener noreferrer" aria-label="X (Twitter)">'+fill('<path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>')+'</a>'
     +'<a href="search.html" aria-label="Search">'+ic('<circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/>')+'</a></div></header>';
  }else{
    html='<div class="bnav" role="navigation" aria-label="Main navigation">'+items.map(function(i){
      var ask=i[0]==='ask';
      return '<a href="'+i[1]+'"'+(i[0]===cur?' class="on" aria-current="page"':'')+(ask?' role="button" onclick="if(typeof openChat===\'function\'){openChat(event)}else{event.preventDefault();location.href=\'doubts.html\'}"':'')+'>'+i[3]+'<span>'+i[2]+'</span></a>';
    }).join('')+'</div>';
  }
  me.insertAdjacentHTML('beforebegin',html);
})();
