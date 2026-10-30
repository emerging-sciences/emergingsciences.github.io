/* Emerging Sciences — content loader.
   1) reads your published Google Sheet (if sheet-config.js is filled) and merges it into ES_DATA
   2) on pages opened with ?e=<exam> keeps only the lectures / material meant for that exam
   3) then starts the site (app-core.js).
   If the sheet is not configured or cannot be reached, the site simply uses data.js. */
(function(){
'use strict';
var TIMEOUT=3500, CACHE_KEY='es_sheetcache_v1';

/* ---------- helpers ---------- */
function norm(s){return String(s==null?'':s).toLowerCase().replace(/[^a-z0-9]/g,'')}
function txt(s){return String(s==null?'':s).replace(/[<>]/g,'').replace(/\s+/g,' ').trim()}   /* plain text: no tags */
function idOk(s){return /^[A-Za-z0-9_-]+$/.test(s)}
function cleanId(s){return String(s==null?'':s).trim().replace(/[^A-Za-z0-9_-]/g,'-').replace(/-+/g,'-').replace(/^-|-$/g,'')}
function httpUrl(s){s=String(s==null?'':s).trim();return /^https?:\/\//i.test(s)?s:''}
function ytId(s){s=String(s==null?'':s).trim();if(!s)return '';var m=s.match(/(?:v=|youtu\.be\/|embed\/|shorts\/|live\/)([A-Za-z0-9_-]{6,20})/);if(m)return m[1];return /^[A-Za-z0-9_-]{6,20}$/.test(s)?s:''}
function driveId(s){s=String(s==null?'':s).trim();if(!s)return '';var m=s.match(/\/d\/([A-Za-z0-9_-]{10,})/)||s.match(/[?&]id=([A-Za-z0-9_-]{10,})/);if(m)return m[1];return /^[A-Za-z0-9_-]{10,}$/.test(s)?s:''}

function parseCSV(t){
  var rows=[],row=[],f='',q=false,i,c;t=String(t||'').replace(/^\uFEFF/,'');
  for(i=0;i<t.length;i++){c=t[i];
    if(q){if(c==='"'){if(t[i+1]==='"'){f+='"';i++}else q=false}else f+=c}
    else if(c==='"')q=true;
    else if(c===','){row.push(f);f=''}
    else if(c==='\n'||c==='\r'){if(c==='\r'&&t[i+1]==='\n')i++;row.push(f);rows.push(row);row=[];f=''}
    else f+=c}
  if(f!==''||row.length){row.push(f);rows.push(row)}
  return rows}

var ALIAS={topic:'topic',topicid:'topic',exams:'exams',exam:'exams',no:'no',number:'no',num:'no',lecture:'no',title:'title',name:'name',
  type:'type',kind:'type',youtube:'youtube',youtubeid:'youtube',yt:'youtube',video:'youtube',id:'id',icon:'icon',subject:'subject',paper:'subject',
  live:'live',description:'desc',desc:'desc',drive:'drive',driveid:'drive',file:'drive',pdf:'drive',year:'year',
  questionpaper:'qp',qp:'qp',paper_qp:'qp',answerkey:'key',key:'key',group:'group',note:'note',notes:'note',link:'link',url:'link',source:'src',src:'src'};
function toObjects(rows){
  if(!rows||rows.length<2)return [];
  var h=rows[0].map(function(x){return ALIAS[norm(x)]||norm(x)}),out=[];
  for(var i=1;i<rows.length;i++){var r=rows[i],o={},any=false;
    for(var j=0;j<h.length;j++){var v=r[j]==null?'':String(r[j]).trim();if(v!=='')any=true;if(h[j]&&o[h[j]]===undefined)o[h[j]]=v}
    if(any){o._row=i+1;out.push(o)}}
  return out}

/* ---------- exam / subject name resolving ---------- */
function makeCtx(D,warn){
  var exAlias={},papAlias={};
  (D.exams||[]).forEach(function(e){[e.id,e.short,e.name].forEach(function(n){if(n)exAlias[norm(n)]=e.id})});
  exAlias.iitjam=exAlias.iitjam||exAlias.jam;exAlias.cuet=exAlias.cuet||exAlias.cuetpg;exAlias.csirnet=exAlias.csirnet||exAlias.csir;exAlias.tifrgs=exAlias.tifrgs||exAlias.tifr;
  (D.papers||[]).forEach(function(p){papAlias[norm(p.id)]=p.id;papAlias[norm(p.name)]=p.id});
  function eligible(e,p){var has=e.papers&&e.papers.length;return has?e.papers.indexOf(p||'ma')>-1:(!p||p==='ma')}
  function paper(v,where){v=String(v==null?'':v).trim();if(!v)return '';var id=papAlias[norm(v)];if(!id){warn(where+': unknown subject "'+v+'"');return ''}return id}
  /* returns 'all' or an array of exam ids */
  function exams(v,where){
    v=String(v==null?'':v).trim();if(!v||norm(v)==='all'||norm(v)==='sab')return 'all';
    var out=[];
    v.split(/[,;|\n]+/).forEach(function(item){item=item.trim();if(!item)return;
      var id=exAlias[norm(item)];
      if(id){if(out.indexOf(id)<0)out.push(id);return}
      var parts=item.split(/\s+/),bad=[];
      parts.forEach(function(w){var k=exAlias[norm(w)];if(k){if(out.indexOf(k)<0)out.push(k)}else bad.push(w)});
      if(bad.length)warn(where+': unknown exam "'+bad.join(' ')+'"')});
    return out}
  return {eligible:eligible,paper:paper,exams:exams}}

/* ---------- merge: sheet tabs -> ES_DATA ---------- */
function merge(D,T,warn){
  var C=makeCtx(D,warn),used=[];
  var subjectIds={};

  /* Topics */
  if(T.topics&&T.topics.length){
    var subs=[],per=[],seen={};
    T.topics.forEach(function(r){var w='Topics row '+r._row,id=cleanId(r.id),name=txt(r.name||r.title);
      if(!id||!name){warn(w+': needs id and name — skipped');return}
      if(seen[id]){warn(w+': duplicate topic id "'+id+'" — skipped');return}seen[id]=1;
      var p=C.paper(r.subject,w),o={id:id,name:name,icon:txt(r.icon)||'📘'};if(p&&p!=='ma')o.p=p;
      o.live=String(r.live||'').trim()===''||/^(y|yes|true|1|live)$/i.test(r.live);
      var ex=C.exams(r.exams,w);if(ex!=='all'&&!ex.length){warn(w+': no valid exam in "'+r.exams+'" — topic skipped');return}
      subs.push(o);per.push(ex)});
    var prev={};D.exams.forEach(function(e){prev[e.id]=(e.subjects||[]).slice();e.subjects=[]});
    subs.forEach(function(s,i){var ex=per[i];
      D.exams.forEach(function(e){
        if(ex==='all'){if(C.eligible(e,s.p))e.subjects.push(s.id)}
        else if(ex.indexOf(e.id)>-1){e.subjects.push(s.id);if(!C.eligible(e,s.p))warn('Topic "'+s.id+'" is listed for '+e.id+' but that exam has no "'+(s.p||'ma')+'" subject — it will stay hidden')}})});
    /* topics already known keep their old position (exam priority order); new topics follow in sheet order */
    D.exams.forEach(function(e){e.subjects=e.subjects.map(function(id,n){var k=prev[e.id].indexOf(id);return {id:id,k:k<0?1e6+n:k}}).sort(function(a,b){return a.k-b.k}).map(function(x){return x.id})});
    D.subjects=subs;used.push('topics')}
  D.subjects.forEach(function(s){subjectIds[s.id]=1});

  /* Lectures */
  if(T.lectures&&T.lectures.length){
    var L=[],ids={},cnt={};
    T.lectures.forEach(function(r){var w='Lectures row '+r._row,s=cleanId(r.topic),yt=ytId(r.youtube),t=txt(r.title);
      if(!s||!subjectIds[s]){warn(w+': topic "'+(r.topic||'')+'" not found in Topics — skipped');return}
      if(!t||!yt){warn(w+': needs a title and a valid YouTube link/id — skipped');return}
      var id=cleanId(r.id)||(s+'-'+yt);if(ids[id]){warn(w+': duplicate id "'+id+'" — skipped');return}ids[id]=1;
      cnt[s]=(cnt[s]||0)+1;
      var o={id:id,s:s,n:txt(r.no)||('L-'+(cnt[s]<10?'0':'')+cnt[s]),t:t,k:/^p/i.test(r.type||'')?'P':'T',yt:yt},ex=C.exams(r.exams,w);
      if(ex!=='all'&&!ex.length){warn(w+': no valid exam in "'+r.exams+'" — row hidden');return}
      if(ex!=='all')o.ex=ex;L.push(o)});
    D.lectures=L;used.push('lectures')}

  /* Material */
  if(T.material&&T.material.length){
    var M=[],mids={};
    T.material.forEach(function(r){var w='Material row '+r._row,s=cleanId(r.topic),dr=driveId(r.drive),t=txt(r.title);
      if(!s||!subjectIds[s]){warn(w+': topic "'+(r.topic||'')+'" not found in Topics — skipped');return}
      if(!t||!dr){warn(w+': needs a title and a valid Google Drive link/id — skipped');return}
      var id=cleanId(r.id)||('m-'+dr.slice(0,14));if(mids[id]){warn(w+': duplicate id "'+id+'" — skipped');return}mids[id]=1;
      var o={id:id,t:t,d:txt(r.desc),k:txt(r.type)||'Notes',s:s,drive:dr},ex=C.exams(r.exams,w);
      if(ex!=='all'&&!ex.length){warn(w+': no valid exam in "'+r.exams+'" — row hidden');return}
      if(ex!=='all')o.ex=ex;M.push(o)});
    D.material=M;used.push('material')}

  /* PYQs (one row per exam) */
  if(T.pyqs&&T.pyqs.length){
    var Q=[];
    T.pyqs.forEach(function(r){var w='PYQs row '+r._row,y=parseInt(r.year,10),qp=httpUrl(r.qp),key=httpUrl(r.key),t=txt(r.title),p=C.paper(r.subject,w);
      if(!y||!t||(!qp&&!key)){warn(w+': needs year, title and a link — skipped');return}
      var ex=C.exams(r.exams,w);if(ex!=='all'&&!ex.length){warn(w+': no valid exam in "'+r.exams+'" — row skipped');return}
      D.exams.forEach(function(e){if(ex==='all'?C.eligible(e,p):ex.indexOf(e.id)>-1){
        var o={e:e.id};if(p&&p!=='ma')o.p=p;o.y=y;o.t=t;if(qp)o.qp=qp;if(txt(r.note))o.n=txt(r.note);if(key)o.key=key;if(txt(r.group))o.g=txt(r.group);Q.push(o)}})});
    D.pyqs=Q;used.push('pyqs')}

  /* Syllabus (one row per exam) */
  if(T.syllabus&&T.syllabus.length){
    var Y=[];
    T.syllabus.forEach(function(r){var w='Syllabus row '+r._row,u=httpUrl(r.link),t=txt(r.title),p=C.paper(r.subject,w);
      if(!t||!u){warn(w+': needs a title and a link — skipped');return}
      var ex=C.exams(r.exams,w);if(ex!=='all'&&!ex.length){warn(w+': no valid exam in "'+r.exams+'" — row skipped');return}
      D.exams.forEach(function(e){if(ex==='all'?C.eligible(e,p):ex.indexOf(e.id)>-1){
        var o={e:e.id};if(p&&p!=='ma')o.p=p;o.t=t;o.url=u;if(txt(r.src))o.src=txt(r.src);if(txt(r.note))o.n=txt(r.note);Y.push(o)}})});
    D.syllabus=Y;used.push('syllabus')}
  return used}

function inEx(r,id){return !r.ex||r.ex==='all'||r.ex.indexOf(id)>-1}
function filterByExam(D,examId){
  if(!examId||!(D.exams||[]).some(function(e){return e.id===examId}))return;
  D.lectures=D.lectures.filter(function(r){return inEx(r,examId)});
  D.material=D.material.filter(function(r){return inEx(r,examId)})}

window.ES_SHEET_API={parseCSV:parseCSV,toObjects:toObjects,merge:merge,filterByExam:filterByExam};
if(window.__ES_TEST)return;

/* ---------- browser part ---------- */
var warns=[];function warn(m){warns.push(m)}
function loadScript(src,cb){var s=document.createElement('script');s.src=src;s.onload=s.onerror=function(){cb()};document.head.appendChild(s)}
function readCache(){try{return JSON.parse(localStorage.getItem(CACHE_KEY)||'{}')}catch(e){return {}}}
function writeCache(o){try{localStorage.setItem(CACHE_KEY,JSON.stringify(o))}catch(e){}}

function boot(){
  try{filterByExam(window.ES_DATA,new URLSearchParams(location.search).get('e'))}catch(e){console.warn('Emerging Sciences: exam filter failed',e)}
  var s=document.createElement('script');s.src='app-core.js';document.body.appendChild(s)}

function run(){
  var cfg=window.ES_SHEETS||{},D=window.ES_DATA;
  if(!D||!cfg.pub||!cfg.gids){boot();return}
  var names=['topics','lectures','material','pyqs','syllabus'],cache=readCache(),got={},fresh={},pending=names.length,done=false;
  function finish(){if(done)return;done=true;
    try{
      var T={};names.forEach(function(n){if(got[n]!=null)T[n]=toObjects(parseCSV(got[n]))});
      var used=merge(D,T,warn);
      if(warns.length)console.warn('Emerging Sciences sheet — please check:\n• '+warns.join('\n• '));
      window.ES_SHEET_STATUS={used:used,warnings:warns.slice()};
      if(/[?&]sheetdebug=1/.test(location.search))console.log('Sheet loaded:',used,'lectures',D.lectures.length,'material',D.material.length,'pyqs',D.pyqs.length)
    }catch(e){console.warn('Emerging Sciences: sheet could not be applied, using data.js',e)}
    boot()}
  var timer=setTimeout(function(){names.forEach(function(n){if(got[n]==null&&cache[n]!=null)got[n]=cache[n]});finish()},TIMEOUT);
  names.forEach(function(n){
    var gid=cfg.gids[n];
    if(gid===''||gid==null){pending--;if(!pending&&!done){clearTimeout(timer);finish()}return}
    var url='https://docs.google.com/spreadsheets/d/e/'+encodeURIComponent(cfg.pub)+'/pub?gid='+encodeURIComponent(gid)+'&single=true&output=csv';
    fetch(url,{cache:'no-store'}).then(function(r){if(!r.ok)throw new Error(r.status);return r.text()}).then(function(t){
      if(/^\s*<(!doctype|html)/i.test(t))throw new Error('not csv');
      got[n]=t;fresh[n]=t;var c=readCache();c[n]=t;writeCache(c)
    }).catch(function(){if(cache[n]!=null)got[n]=cache[n]}).then(function(){
      pending--;if(!pending&&!done){clearTimeout(timer);finish()}})})
  if(!pending&&!done){clearTimeout(timer);finish()}}

loadScript('sheet-config.js',run);
})();
