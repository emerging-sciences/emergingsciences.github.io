/* Emerging Sciences — Focus timer engine + mini timer bar.
   Loaded on every page (nav.js loads it). The timer state lives in localStorage, so the timer keeps
   running when the student opens lectures, material or any other page of this site. */
(function(){
'use strict';
if(window.ESFocus)return;
var KEY='es_focusrun',CFGK='es_focuscfg',AWAY_MIN=3000,FROZEN=20000,STRICT_MS=30000;
function jget(k,d){try{var v=localStorage.getItem(k);return v?JSON.parse(v):d}catch(e){return d}}
function jset(k,v){try{localStorage.setItem(k,JSON.stringify(v))}catch(e){}}
function dayKey(d){return (d||new Date()).toLocaleDateString('en-CA')}
function fmt(ms){var s=Math.max(0,Math.ceil(ms/1000)),m=Math.floor(s/60);s%=60;return (m<10?'0':'')+m+':'+(s<10?'0':'')+s}
function cfg(){var c=jget(CFGK,{});return {f:Math.max(1,Math.min(180,+c.f||25)),b:Math.max(1,Math.min(60,+c.b||5)),subj:c.subj||'',wake:c.wake!==false,note:!!c.note,strict:!!c.strict}}
function idle(c){return {ph:'focus',run:0,end:0,tot:c.f*60000,left:c.f*60000,hb:0,vt:0,sec:0,lv:0,aw:0}}
function load(){var s=jget(KEY,null);if(!s||typeof s!=='object'||!(s.tot>0))s=idle(cfg());return s}
function save(s){jset(KEY,s)}
function sessionActive(s){return !!(s.run||s.left<s.tot||s.sec>0||s.ph==='break')}

var listeners=[],hiddenAt=0,lastT=Date.now(),carry=0,wl=null,actx=null,timer=null;
function emit(ev){listeners.forEach(function(f){try{f(ev||'tick')}catch(e){}});ui()}

/* ---------- study time (same storage as the lecture player) ---------- */
function addStudy(sec){var m=jget('es_study',{}),k=dayKey();m[k]=(m[k]||0)+sec;jset('es_study',m);try{window.dispatchEvent(new Event('es-study'))}catch(e){}}

/* ---------- log ---------- */
function commit(S,done){
  if(S.sec>=60||S.lv>0){var log=jget('es_focuslog',[]);
    log.push({d:dayKey(),t:Date.now(),sec:S.sec,subj:cfg().subj||'',leaves:S.lv,away:Math.round(S.aw/1000),done:!!done});
    jset('es_focuslog',log.slice(-150))}
  S.sec=0;S.lv=0;S.aw=0}

/* ---------- sound / notification / wake lock ---------- */
function unlock(){try{var AC=window.AudioContext||window.webkitAudioContext;if(!AC)return;if(!actx)actx=new AC();if(actx.state==='suspended')actx.resume()}catch(e){}}
function beep(){try{unlock();if(!actx)return;[0,0.28,0.56].forEach(function(t){var o=actx.createOscillator(),g=actx.createGain();o.type='sine';o.frequency.value=880;o.connect(g);g.connect(actx.destination);
  var n=actx.currentTime+t;g.gain.setValueAtTime(0.0001,n);g.gain.exponentialRampToValueAtTime(0.25,n+0.02);g.gain.exponentialRampToValueAtTime(0.0001,n+0.22);o.start(n);o.stop(n+0.25)})}catch(e){}
  try{navigator.vibrate&&navigator.vibrate([200,100,200])}catch(e){}}
function notify(t,b){try{if(cfg().note&&window.Notification&&Notification.permission==='granted')new Notification(t,{body:b,icon:'icon-192.png'})}catch(e){}}
function wakeSync(on){try{
  if(on&&cfg().wake&&navigator.wakeLock&&!wl&&!document.hidden){wl=true;navigator.wakeLock.request('screen').then(function(l){wl=l;l.addEventListener('release',function(){wl=null})}).catch(function(){wl=null})}
  else if(!on&&wl&&wl!==true){wl.release();wl=null}}catch(e){wl=null}}

/* ---------- core ---------- */
function away(S,ms){
  if(ms<AWAY_MIN)return false;
  S.lv++;S.aw+=ms;var sec=Math.round(ms/1000);
  if(cfg().strict&&ms>STRICT_MS){commit(S,false);var N=idle(cfg());for(var k in N)S[k]=N[k];emit({t:'strict',sec:sec});return true}
  emit({t:'away',sec:sec});return false}

function finish(S,now){
  var c=cfg(),late=now-S.end>FROZEN,N;
  if(S.ph==='focus'){
    var done=!late||S.sec>=(S.tot/1000)*0.6;commit(S,done);
    if(!late){S.ph='break';S.tot=c.b*60000;S.left=S.tot;S.end=now+S.tot;S.run=1;S.hb=now;beep();notify('Round complete 🎉','Take a short break.');emit({t:'done'})}
    else{N=idle(c);for(var k in N)S[k]=N[k];emit({t:'late'})}}
  else{N=idle(c);for(var j in N)S[j]=N[j];if(!late){beep();notify('Break over','Ready for the next round?')}emit({t:'breakdone'})}}

function tick(nowArg){
  var now=nowArg||Date.now(),S=load();
  if(!S.run){lastT=now;carry=0;wakeSync(false);emit('tick');return}
  var gap=S.hb?now-S.hb:0;
  if(S.ph==='focus'&&gap>FROZEN&&!hiddenAt){if(away(S,gap)){save(S);lastT=now;wakeSync(false);emit('tick');return}}
  if(!document.hidden&&S.ph==='focus'){
    carry+=Math.min(2000,Math.max(0,now-lastT));var w=Math.floor(carry/1000);
    if(w>0){carry-=w*1000;addStudy(w);S.sec+=w}
    S.vt=now}
  lastT=now;S.hb=now;
  if(S.end-now<=0)finish(S,now);
  save(S);wakeSync(!!(S.run&&S.ph==='focus'));emit('tick')}

function onVis(nowArg){
  var now=nowArg||Date.now(),S;
  if(document.hidden){S=load();if(S.run&&S.ph==='focus')hiddenAt=now;return}
  lastT=now;
  if(hiddenAt){
    var ms=now-hiddenAt,from=hiddenAt;hiddenAt=0;S=load();
    if(S.run&&S.ph==='focus'){
      var elsewhere=S.vt&&(S.vt-from)>ms*0.5;          /* another tab of this site was visible: not a real "leave" */
      if(!elsewhere)away(S,ms);
      S.hb=now;save(S)}}
  emit('tick')}

function start(){var S=load(),now=Date.now();if(S.run)return;if(S.left<=0)S.left=S.tot;S.run=1;S.end=now+S.left;S.hb=now;lastT=now;carry=0;hiddenAt=document.hidden?now:0;save(S);unlock();emit('tick')}
function pause(){var S=load(),now=Date.now();if(!S.run)return;S.left=Math.max(0,S.end-now);S.run=0;save(S);wakeSync(false);emit('tick')}
function toggle(){load().run?pause():start()}
function reset(){var S=load();commit(S,false);save(idle(cfg()));wakeSync(false);emit('tick')}
function skipBreak(){var S=load();if(S.ph==='break'){save(idle(cfg()));emit('tick')}}
function setCfg(p){var c=cfg();for(var k in p)c[k]=p[k];jset(CFGK,c);var S=load();if(!sessionActive(S))save(idle(cfg()));emit('tick')}
function get(){var S=load(),now=Date.now();return {ph:S.ph,run:!!S.run,left:S.run?Math.max(0,S.end-now):S.left,tot:S.tot,sec:S.sec,lv:S.lv,active:sessionActive(S)}}
function active(){var S=load();return !!(S.run&&S.ph==='focus')}

/* ---------- mini bar (every page except the focus page) ---------- */
var bar=null,tEl=null,pEl=null,onFocusPage=/focus\.html$/i.test(location.pathname||''),toastEl=null,toastT=0;
function toast(msg,cls){if(!toastEl||onFocusPage)return;toastEl.textContent=msg;toastEl.className='on'+(cls?' '+cls:'');clearTimeout(toastT);toastT=setTimeout(function(){toastEl.className=''},6000)}
function buildBar(){try{
  if(onFocusPage||!document.body||bar)return;
  var css=document.createElement('style');
  css.textContent='#esfb{position:fixed;left:50%;transform:translateX(-50%);bottom:calc(88px + env(safe-area-inset-bottom,0px));z-index:55;display:flex;align-items:center;gap:6px;background:var(--surface,#0a0a0a);border:1px solid var(--border-strong,rgba(255,255,255,.18));border-radius:99px;padding:5px 6px 5px 14px;box-shadow:0 6px 22px rgba(0,0,0,.5);color:var(--text,#ececec);font:600 14px Inter,system-ui,sans-serif}'
   +'#esfb[hidden]{display:none}#esfb a{color:inherit;text-decoration:none;display:flex;align-items:baseline;gap:6px}#esfb b{font-variant-numeric:tabular-nums;font-size:16px}#esfb span{font-size:11px;color:var(--text2,#a3a3a3);font-weight:500}'
   +'#esfb.brk b{color:var(--green,#34d399)}#esfb button{border:0;background:rgba(127,127,160,.18);color:inherit;width:30px;height:30px;border-radius:50%;cursor:pointer;font-size:13px}'
   +'#esfbToast{position:fixed;left:50%;transform:translateX(-50%);bottom:calc(132px + env(safe-area-inset-bottom,0px));z-index:56;max-width:min(92vw,420px);background:var(--surface,#0a0a0a);border:1px solid var(--border-strong,rgba(255,255,255,.18));border-radius:12px;padding:8px 14px;font:500 13px Inter,system-ui,sans-serif;color:var(--text,#ececec);display:none;text-align:center}'
   +'#esfbToast.on{display:block}#esfbToast.warn{border-color:#fbbf24;color:#fbbf24}#esfbToast.good{border-color:var(--green,#34d399);color:var(--green,#34d399)}';
  document.head.appendChild(css);
  bar=document.createElement('div');bar.id='esfb';bar.hidden=true;
  bar.innerHTML='<a href="focus.html" aria-label="Open focus timer">⏱ <b id="esfbT">00:00</b><span id="esfbL">Focus</span></a><button id="esfbP" aria-label="Pause or resume">⏸</button><button id="esfbX" aria-label="Stop timer">✕</button>';
  document.body.appendChild(bar);
  toastEl=document.createElement('div');toastEl.id='esfbToast';toastEl.setAttribute('role','status');document.body.appendChild(toastEl);
  tEl=bar.querySelector('#esfbT');pEl=bar.querySelector('#esfbP');
  bar.querySelector('#esfbP').addEventListener('click',function(){toggle()});
  bar.querySelector('#esfbX').addEventListener('click',function(){if(confirm('Stop the focus timer?'))reset()});
}catch(e){}}
function ui(){try{
  if(!bar)return;var S=load(),show=sessionActive(S);bar.hidden=!show;if(!show)return;
  var left=S.run?Math.max(0,S.end-Date.now()):S.left;
  tEl.textContent=fmt(left);bar.className=S.ph==='break'?'brk':'';
  bar.querySelector('#esfbL').textContent=S.ph==='break'?'Break':(S.run?'Focus':'Paused');
  pEl.textContent=S.run?'⏸':'▶'}catch(e){}}
listeners.push(function(ev){if(ev&&ev.t){
  if(ev.t==='away')toast('You were away for '+ev.sec+' seconds. Back to study 💪','warn');
  else if(ev.t==='strict')toast('Round ended: you were away for '+ev.sec+' seconds.','warn');
  else if(ev.t==='done')toast('Round complete! Take a break 🎉','good');
  else if(ev.t==='breakdone')toast('Break is over. Ready for the next round?','good');
  else if(ev.t==='late')toast('Your focus round ended while you were away.','warn')}});

window.ESFocus={get:get,start:start,pause:pause,toggle:toggle,reset:reset,skipBreak:skipBreak,setCfg:setCfg,cfg:cfg,active:active,
  on:function(f){listeners.push(f)},fmt:fmt,dayKey:dayKey,_tick:tick,_vis:onVis,_load:load};

function boot(){buildBar();ui();
  timer=setInterval(function(){tick()},500);
  document.addEventListener('visibilitychange',function(){onVis()});
  window.addEventListener('storage',function(e){if(e.key===KEY||e.key===CFGK)emit('tick')});
  ['pointerdown','touchstart','keydown'].forEach(function(ev){document.addEventListener(ev,unlock,{passive:true})})}
if(window.__FX_TEST)return;
if(document.body)boot();else document.addEventListener('DOMContentLoaded',boot);
})();
