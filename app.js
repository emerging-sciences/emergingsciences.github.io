(function(){
const D=window.ES_DATA,P=new URLSearchParams(location.search),$=(s,r=document)=>r.querySelector(s);
const LS={g(k,d){try{const v=localStorage.getItem('es_'+k);return v?JSON.parse(v):d}catch(e){return d}},s(k,v){try{localStorage.setItem('es_'+k,JSON.stringify(v))}catch(e){}}};
const esc=s=>String(s).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const day=(d=new Date())=>d.toLocaleDateString('en-CA');
const S=id=>D.subjects.find(x=>x.id==id), LECS=s=>D.lectures.filter(l=>l.s==s), LEC=id=>D.lectures.find(l=>l.id==id);
const done=()=>LS.g('done',{}), saved=()=>LS.g('saved',{}), study=()=>LS.g('study',{});
const goal=()=>(LS.g('goal',D.goalMin))*60;
function toggle(key,id){const o=LS.g(key,{});o[id]?delete o[id]:o[id]=1;LS.s(key,o);return !!o[id]}
function streak(){const st=study(),g=goal();let n=0,d=new Date();if((st[day(d)]||0)<g)d.setDate(d.getDate()-1);while((st[day(d)]||0)>=g){n++;d.setDate(d.getDate()-1)}return n}
function addSec(){const st=study(),k=day();st[k]=(st[k]||0)+1;LS.s('study',st);dash()}
const EX=id=>(D.exams||[]).find(x=>x.id==id), examOf=sid=>(D.exams||[]).find(x=>x.subjects.includes(sid));
const days=e=>{const t=new Date();t.setHours(0,0,0,0);return Math.round((new Date(e.date+'T00:00:00')-t)/864e5)};
const cd=e=>{const d=days(e);return d>0?`<b>${d}</b> day${d==1?'':'s'} left`:d==0?'<b>Today</b>':'Exam held · next date awaited'};
const pageTitle={lectures:'Lectures',material:'Study Material',mock:'Mock Tests'};
/* ---- papers: an exam with "papers" gets an extra subject step (e.g. IIT JAM -> Physics) ---- */
const DEFP='ma',PAP=id=>(D.papers||[]).find(x=>x.id==id),papersOf=e=>(e.papers||[]).map(PAP).filter(Boolean),hasP=e=>papersOf(e).length>0;
const subP=s=>s.p||DEFP,topicsOf=(ex,p)=>ex.subjects.map(S).filter(Boolean).filter(s=>!hasP(ex)||subP(s)==p);
const mockOf=(ex,sid,p)=>(D.mocks||[]).filter(m=>m.e==ex.id&&m.s==sid&&(!p||sid!='full'||(m.p||DEFP)==p));
const stepText={lectures:'Step 2 — choose a subject',material:'Step 2 — choose Syllabus, year-wise PYQs or a subject',mock:'Step 2 — choose full-length tests or a subject'};
function dash(){const el=$('#dash');if(!el)return;const t=study()[day()]||0,g=goal(),pct=Math.min(100,t/g*100);
 const up=(D.exams||[]).filter(e=>days(e)>=0).sort((a,b)=>days(a)-days(b))[0];
 el.innerHTML=`<div class="a-card"><b>Daily goal</b><div class="bar"><i style="width:${pct}%"></i></div><small>${Math.floor(t/60)} / ${g/60} min · counts while a lecture plays</small></div>
 <div class="a-card"><b>🔥 ${streak()} days</b><small>Study streak</small></div>
 ${up?`<a class="a-card" href="#exams"><b>${days(up)} days</b><small>to ${esc(up.short)} · ${esc(up.dateText)} (${esc(up.note)})</small></a>`:''}`}
function examCard(e){return `<div class="exam-card x-card"><div class="exam-icon" style="background:${e.color}22;color:${e.color}">${e.tag}</div><div class="x-body">
 <div class="exam-name">${esc(e.name)}</div><div class="x-org">${esc(e.body)}</div><div class="exam-desc">${esc(e.desc)}</div>
 <div class="x-meta"><span class="x-cd">${cd(e)}</span><span class="x-date">📅 ${esc(e.dateText)} · ${esc(e.note)}</span></div>
 <div class="x-btns"><a class="x-go" href="lectures.html?e=${e.id}">▶ Lectures</a><a href="material.html?e=${e.id}">📄 Material</a><a href="mock.html?e=${e.id}">📝 Mock</a><a href="${e.site}" target="_blank" rel="noopener noreferrer">Official site ↗</a></div></div></div>`}
function examPick(e,page){const n=hasP(e)&&page!='mock'?papersOf(e).length+' subjects':page=='mock'?(D.mocks||[]).filter(m=>m.e==e.id).length+' test'+((D.mocks||[]).filter(m=>m.e==e.id).length==1?'':'s'):page=='material'?e.subjects.filter(i=>D.material.some(m=>m.s==i)).length+' of '+e.subjects.length+' subjects with PDFs':e.subjects.filter(i=>(S(i)||{}).live).length+' of '+e.subjects.length+' subjects live';
 return `<a class="a-card pick" href="${page}.html?e=${e.id}"><span class="pk" style="color:${e.color}">${e.short}</span><h3>${esc(e.name)}</h3><small>${esc(e.body)}</small><small>${n}</small><span class="x-cd">${cd(e)}</span></a>`}
function chooser(page){return `<section class="section"><div class="section-inner"><h1 class="a-h">${pageTitle[page]}</h1><p>Step 1 — choose your exam</p><div class="a-grid">${D.exams.map(e=>examPick(e,page)).join('')}</div></div></section>`}
function crumbs(page,e,sub,pp){return `<div class="crumbs"><a href="${page}.html">${pageTitle[page]}</a>${e?` › <a href="${page}.html?e=${e.id}">${esc(e.short)}</a>`:''}${pp?` › <a href="${page}.html?e=${e.id}&p=${pp.id}">${esc(pp.name)}</a>`:''}${sub?` › <span>${esc(sub)}</span>`:''}</div>`}
function subjCards(page,ex,p){page=page||'lectures';const d=done(),q=`?e=${ex.id}${p?'&p='+p:''}&s=`,list=topicsOf(ex,p);
 const full=page=='mock'?[{id:'full',name:'Full-Length Mock Tests',icon:'📝',live:true}]:[];
 return `<div class="a-grid">`+(page=='material'||p?matExtra(ex,p):'')+full.concat(list).map(s=>{
  if(page=='mock'){const T=mockOf(ex,s.id,p);if(!T.length)return `<div class="a-card dim"><span class="ic">${s.icon}</span><h3>${s.name}</h3><small>Coming soon</small></div>`;
   return `<a class="a-card" href="mock.html${q}${s.id}"><span class="ic">${s.icon}</span><h3>${s.name}</h3><small>${T.length} test${T.length==1?'':'s'}</small></a>`}
  if(page=='material'){const M=D.material.filter(m=>m.s==s.id);if(!M.length)return `<div class="a-card dim"><span class="ic">${s.icon}</span><h3>${s.name}</h3><small>Coming soon</small></div>`;return `<a class="a-card" href="material.html${q}${s.id}"><span class="ic">${s.icon}</span><h3>${s.name}</h3><small>${M.length} PDF${M.length==1?'':'s'}</small></a>`}
  if(!s.live)return `<div class="a-card dim"><span class="ic">${s.icon}</span><h3>${s.name}</h3><small>Coming soon</small></div>`;
  const L=LECS(s.id),c=L.filter(l=>d[l.id]).length;return `<a class="a-card" href="lectures.html${q}${s.id}"><span class="ic">${s.icon}</span><h3>${s.name}</h3><small>${L.length} lectures · ${c}/${L.length} completed</small><div class="bar"><i style="width:${L.length?c/L.length*100:0}%"></i></div></a>`}).join('')+`</div>`}
function resolve(){const sid=P.get('s'),sub=sid=='full'?{id:'full',name:'Full-Length Mock Tests',icon:'📝',live:true}:S(sid);let ex=EX(P.get('e'));if(sub&&(!ex||(sid!='full'&&!ex.subjects.includes(sub.id))))ex=sid=='full'?ex:examOf(sub.id);let p=null;if(ex&&hasP(ex)){const ok=x=>ex.papers.includes(x)?x:ex.papers[0];if(sub&&sid!='full')p=ok(subP(sub));else{const q=P.get('p');p=ex.papers.includes(q)?q:(sub?ex.papers[0]:null)}}
 return {ex,sub:ex?sub:null,p}}
function stepView(page,ex,p){const hp=hasP(ex),c=`${cd(ex)} (${esc(ex.dateText)}, ${esc(ex.note)})`;
 if(hp&&!p)return `<section class="section"><div class="section-inner">${crumbs(page,ex)}<h1 class="a-h">${esc(ex.name)}</h1><p>Step 2 — choose your subject · ${c}</p>${paperCards(page,ex)}</div></section>`;
 const pp=hp?PAP(p):null;
 return `<section class="section"><div class="section-inner">${crumbs(page,ex,null,pp)}<h1 class="a-h">${pp?pp.icon+' '+esc(pp.name):esc(ex.name)}</h1><p>${pp?'Step 3 — choose Syllabus, PYQs or a topic':stepText[page]} · ${c}</p>${subjCards(page,ex,p)}</div></section>`}
function paperCards(page,ex){return `<div class="a-grid">`+papersOf(ex).map(pp=>{const T=topicsOf(ex,pp.id);let n;
  if(page=='lectures'){const k=T.reduce((a,s)=>a+LECS(s.id).length,0);n=k?k+' lectures':'Syllabus & PYQs · lectures coming soon'}
  else if(page=='material'){const k=T.reduce((a,s)=>a+D.material.filter(m=>m.s==s.id).length,0);n=k?k+' PDFs · Syllabus · PYQs':'Syllabus & PYQs'}
  else{const k=(D.mocks||[]).filter(m=>m.e==ex.id&&(m.s=='full'?(m.p||DEFP)==pp.id:T.some(s=>s.id==m.s))).length;n=k?k+' test'+(k==1?'':'s'):'Syllabus & PYQs · tests coming soon'}
  return `<a class="a-card" href="${page}.html?e=${ex.id}&p=${pp.id}"><span class="ic">${pp.icon}</span><h3>${esc(pp.name)}</h3><small>${n}</small></a>`}).join('')+`</div>`}
function lecRow(l){const d=done(),sv=saved(),e=P.get('e');return `<a class="a-row" href="watch.html?id=${l.id}${e?'&e='+encodeURIComponent(e):''}"><span class="num">${l.n}</span><span class="tt">${esc(l.t)}</span><span class="tag">${l.k=='P'?'Practice':'Theory'}</span><span>${d[l.id]?'✅':''}${sv[l.id]?'🔖':''}</span></a>`}
function matCard(m){const sv=saved();return `<div class="a-card"><h3>${esc(m.t)}</h3><small>${esc(m.d)}</small><div class="tags"><span class="tag">${m.k}</span><span class="tag">${S(m.s).name}</span></div>
 <div class="btns"><button onclick="ES.read('${m.id}')">📖 Read</button><a href="https://drive.google.com/uc?export=download&id=${m.drive}" target="_blank" rel="noopener">⬇ Download</a><button onclick="ES.save('${m.id}',this)">${sv[m.id]?'🔖 Saved':'🔖 Save'}</button></div></div>`}
/* ---- Syllabus + year-wise PYQs (data.js: syllabus, pyqs, pyqPortals) ---- */
const inP=(r,p)=>!p||(r.p||DEFP)==p, syEx=(id,p)=>(D.syllabus||[]).filter(r=>r.e==id&&inP(r,p)), pyEx=(id,p)=>(D.pyqs||[]).filter(r=>r.e==id&&inP(r,p)).sort((a,b)=>b.y-a.y), portal=(id,p)=>(D.pyqPortals||{})[p&&(D.pyqPortals||{})[id+'-'+p]?id+'-'+p:id];
const rng=a=>{const x=Math.min(...a),y=Math.max(...a);return x==y?''+x:x+'–'+y};
const href=u=>/^https?:\/\//i.test(u)?esc(u):'#';
const dlink=id=>esc('https://drive.google.com/uc?export=download&id='+encodeURIComponent(id));
function fbtn(lbl,url,drv,t){
 if(drv)return `<button data-t="${esc(t)}" onclick="ES.drv('${encodeURIComponent(drv)}',this.dataset.t)">${lbl}</button><a href="${dlink(drv)}" target="_blank" rel="noopener" title="Download">⬇</a>`;
 return url?`<a href="${href(url)}" target="_blank" rel="noopener noreferrer">${lbl} ↗</a>`:''}
function synCard(r){return `<div class="a-card"><h3>${esc(r.t)}</h3><small>${esc(r.src||'')}${r.n?(r.src?' · ':'')+esc(r.n):''}</small><div class="btns">${fbtn('📄 Open',r.url,r.drive,r.t)}</div></div>`}
function pyqCard(r){return `<div class="a-card"><h3>${esc(r.y)}${r.g?' · '+esc(r.g):''}</h3><small>${esc(r.t)}${r.n?' — '+esc(r.n):''}</small><div class="btns">${fbtn('📄 Paper',r.qp,r.qpDrive,r.t+' — Paper')}${fbtn('🔑 Key',r.key,r.keyDrive,r.t+' — Key')}</div></div>`}
function portalBox(id,pid){const p=portal(id,pid);if(!p)return '';
 return `<div class="a-card"><h3>🌐 Official source</h3><small>All years and the latest papers are always on the official page.</small><div class="btns"><a href="${href(p.url)}" target="_blank" rel="noopener noreferrer">${esc(p.label||'Official page')} ↗</a>${p.more?`<a href="${href(p.more)}" target="_blank" rel="noopener noreferrer">${esc(p.moreLabel||'More')} ↗</a>`:''}</div></div>`}
function matExtra(ex,p){const q=`?e=${ex.id}${p?'&p='+p:''}&s=`,sy=syEx(ex.id,p),py=pyEx(ex.id,p),pt=portal(ex.id,p),yr=py.map(r=>+r.y);
 return (sy.length?`<a class="a-card" href="material.html${q}syllabus"><span class="ic">📋</span><h3>Syllabus</h3><small>${sy.length} document${sy.length==1?'':'s'}</small></a>`:`<div class="a-card dim"><span class="ic">📋</span><h3>Syllabus</h3><small>Coming soon</small></div>`)
 +(py.length||pt?`<a class="a-card" href="material.html${q}pyqs"><span class="ic">🗂️</span><h3>PYQs · Year-wise</h3><small>${py.length?py.length+' paper'+(py.length==1?'':'s')+' · '+rng(yr):'Official papers page'}</small></a>`:`<div class="a-card dim"><span class="ic">🗂️</span><h3>PYQs · Year-wise</h3><small>Coming soon</small></div>`)}
function sylView(ex,p){const L=syEx(ex.id,p),pp=p?PAP(p):null;
 return `<section class="section"><div class="section-inner">${crumbs('material',ex,'Syllabus',pp)}<h1 class="a-h">📋 ${esc(ex.short)}${pp?' '+esc(pp.name):''} Syllabus</h1><p>${esc(ex.name)} · ${L.length} document${L.length==1?'':'s'}</p>
 <div class="a-grid">${L.map(synCard).join('')||'<p>Syllabus for this exam is coming soon.</p>'}</div></div></section>`}
function pyqView(ex,p){const pp=p?PAP(p):null,all=pyEx(ex.id,p),gs=[...new Set(all.map(r=>r.g).filter(Boolean))],g=P.get('g')||'all',L=all.filter(r=>g=='all'||r.g==g),yr=all.map(r=>+r.y);
 return `<section class="section"><div class="section-inner">${crumbs('material',ex,'PYQs',pp)}<h1 class="a-h">🗂️ ${esc(ex.short)}${pp?' '+esc(pp.name):''} · Year-wise PYQs</h1><p>${all.length?`${all.length} paper${all.length==1?'':'s'} · ${rng(yr)} · 📄 Paper, 🔑 Answer key`:'Year-wise PDFs for this exam are being added. Use the official page below meanwhile.'}</p>
 ${gs.length>1?`<div class="chips">${['all',...gs].map(a=>`<a class="${g==a?'on':''}" href="?e=${ex.id}${p?'&p='+p:''}&s=pyqs&g=${encodeURIComponent(a)}">${a=='all'?'All':esc(a)}</a>`).join('')}</div>`:''}
 <div class="a-grid">${L.map(pyqCard).join('')}</div>
 <div class="a-grid" style="margin-top:1.2rem">${portalBox(ex.id,p)}</div></div></section>`}
window.ES={
 drv(id,t){const o=document.createElement('div');o.className='modal';o.innerHTML=`<div class="mbar"><b>${esc(t)}</b><span><button onclick="this.closest('.modal').classList.toggle('night')">🌙 Night</button><button onclick="this.closest('.modal').remove()">✕</button></span></div><iframe src="https://drive.google.com/file/d/${id}/preview" allow="autoplay"></iframe>`;document.body.appendChild(o)},
 read(id){const m=D.material.find(x=>x.id==id);const o=document.createElement('div');o.className='modal';
  o.innerHTML=`<div class="mbar"><b>${esc(m.t)}</b><span><button onclick="this.closest('.modal').classList.toggle('night')">🌙 Night</button><button onclick="this.closest('.modal').remove()">✕</button></span></div><iframe src="https://drive.google.com/file/d/${m.drive}/preview" allow="autoplay"></iframe>`;document.body.appendChild(o)},
 save(id,b){const on=toggle('saved',id);b.textContent=on?'🔖 Saved':'🔖 Save'}};
const R={
home(el){el.innerHTML=`<section class="section"><div class="section-inner"><div id="dash" class="a-grid3"></div></div></section>`;dash();
 const xl=$('#exam-list');if(xl)xl.innerHTML=D.exams.map(examCard).join('')+`<div class="exam-card x-card"><div class="exam-icon" style="background:#9333EA22;color:#C084FC">MSc<br>+</div><div class="x-body"><div class="exam-name">Other MSc Entrances</div><div class="exam-desc">DU, BHU, JNU and many other central and state universities admit to M.Sc. programmes in Mathematics, Physics, Chemistry, Biotechnology and more through CUET PG or their own entrance tests — the CUET PG and IIT JAM content covers the core syllabus.</div><div class="x-btns"><a class="x-go" href="lectures.html?e=cuetpg">▶ Start with CUET PG</a></div></div></div>`},
lectures(el){const {ex,sub,p}=resolve();if(!ex){el.innerHTML=chooser('lectures');return}
 if(!sub||!sub.live){el.innerHTML=stepView('lectures',ex,p);return}
 const s=sub.id,L=LECS(s),c=L.filter(l=>done()[l.id]).length,f=P.get('f')||'all';
 el.innerHTML=`<section class="section"><div class="section-inner">${crumbs('lectures',ex,sub.name,hasP(ex)?PAP(p):null)}<h1 class="a-h">${sub.icon} ${sub.name}</h1><p>${c} of ${L.length} completed</p>
 <div class="chips">${[['all','All'],['T','Theory'],['P','Practice']].map(([k,n])=>`<a class="${f==k?'on':''}" href="?e=${ex.id}&s=${s}&f=${k}">${n}</a>`).join('')}</div>${L.filter(l=>f=='all'||l.k==f).map(lecRow).join('')}</div></section>`},
watch(el){const l=LEC(P.get('id'));if(!l){el.innerHTML=`<section class="section"><div class="section-inner">Lecture not found. <a href="lectures.html">All lectures</a></div></section>`;return}
 const L=LECS(l.s),i=L.indexOf(l),nx=L[i+1],auto=LS.g('auto',true);document.title=l.n+' '+l.t+' — Emerging Sciences';
 el.innerHTML=`<section class="section"><div class="section-inner"><a href="lectures.html?e=${(EX(P.get('e'))&&EX(P.get('e')).subjects.includes(l.s)?P.get('e'):(examOf(l.s)||{}).id)||''}&s=${l.s}">← ${S(l.s).name}</a><h1 class="a-h">${l.n} · ${esc(l.t)}</h1>
 <div class="vid"><div id="yt"></div></div><div class="btns"><button id="bDone"></button><button id="bSave"></button><button id="bShare">🔗 Share</button><a href="material.html?e=${(EX(P.get('e'))&&EX(P.get('e')).subjects.includes(l.s)?P.get('e'):(examOf(l.s)||{}).id)||''}&s=${l.s}">📄 Notes</a>
 <label><input type="checkbox" id="auto" ${auto?'checked':''}> Auto-play next</label></div><div class="chips" id="spd">${[.75,1,1.25,1.5,2].map(x=>`<a href="#" data-v="${x}">${x}x</a>`).join('')}</div>
 <h2 class="a-h">Up next</h2>${L.slice(i+1,i+6).map(lecRow).join('')||'<p>Last lecture of this subject 🎉</p>'}</div></section>`;
 const bd=$('#bDone'),bs=$('#bSave'),paint=()=>{bd.textContent=done()[l.id]?'✅ Completed':'☐ Mark complete';bs.textContent=saved()[l.id]?'🔖 Saved':'🔖 Save'};paint();
 bd.onclick=()=>{toggle('done',l.id);paint()};bs.onclick=()=>{toggle('saved',l.id);paint()};$('#auto').onchange=e=>LS.s('auto',e.target.checked);
 $('#bShare').onclick=()=>{const u=location.href;navigator.share?navigator.share({title:l.t,url:u}).catch(()=>{}):navigator.clipboard.writeText(u).then(()=>alert('Link copied'))};
 let pl;const mk=()=>{pl=new YT.Player('yt',{videoId:l.yt,width:'100%',height:'100%',playerVars:{rel:0,playsinline:1},events:{onStateChange:e=>{if(e.data==0){if(!done()[l.id]){toggle('done',l.id);paint()}if($('#auto').checked&&nx)location.href='watch.html?id='+nx.id}}}})};
 $('#spd').onclick=e=>{const v=e.target.dataset.v;if(v){e.preventDefault();pl&&pl.setPlaybackRate(+v)}};
 const s=document.createElement('script');s.src='https://www.youtube.com/iframe_api';document.head.appendChild(s);window.onYouTubeIframeAPIReady=mk;
 setInterval(()=>{if(pl&&pl.getPlayerState&&pl.getPlayerState()==1)addSec()},1000)},
material(el){const sp=P.get('s'),ex0=EX(P.get('e'));if(ex0&&(sp=='syllabus'||sp=='pyqs')){const p0=hasP(ex0)?(ex0.papers.includes(P.get('p'))?P.get('p'):ex0.papers[0]):null;el.innerHTML=sp=='syllabus'?sylView(ex0,p0):pyqView(ex0,p0);return}
 const {ex,sub,p}=resolve();if(!ex){el.innerHTML=chooser('material');return}
 if(!sub||!sub.live&&!D.material.some(m=>m.s==sub.id)){el.innerHTML=stepView('material',ex,p);return}
 const s=sub.id,all=D.material.filter(m=>m.s==s),kinds=[...new Set(all.map(m=>m.k))],k=P.get('k')||'all';
 el.innerHTML=`<section class="section"><div class="section-inner">${crumbs('material',ex,sub.name,hasP(ex)?PAP(p):null)}<h1 class="a-h">${sub.icon} ${sub.name}</h1><p>${all.length} PDF${all.length==1?'':'s'}</p>
 ${kinds.length>1?`<div class="chips">${['all',...kinds].map(a=>`<a class="${k==a?'on':''}" href="?e=${ex.id}&s=${s}&k=${encodeURIComponent(a)}">${a=='all'?'All':esc(a)}</a>`).join('')}</div>`:''}
 <div class="a-grid">${all.filter(m=>k=='all'||m.k==k).map(matCard).join('')||'<p>PDFs for this subject are coming soon.</p>'}</div></div></section>`},
mock(el){const {ex,sub,p}=resolve();if(!ex){el.innerHTML=chooser('mock');return}
 if(!sub){el.innerHTML=stepView('mock',ex,p);return}
 const T=mockOf(ex,sub.id,p);
 el.innerHTML=`<section class="section"><div class="section-inner">${crumbs('mock',ex,sub.name,hasP(ex)?PAP(p):null)}<h1 class="a-h">${sub.icon} ${sub.name}</h1><p>${T.length} test${T.length==1?'':'s'}</p>${T.map(m=>`<a class="a-row" href="test.html?t=${m.id}"><span class="num">▶</span><span class="tt">${esc(m.t)}</span><span class="tag">${m.q} Qs · ${m.min} min</span></a>`).join('')||'<p>Tests for this subject are coming soon.</p>'}</div></section>`},
search(el){el.innerHTML=`<section class="section"><div class="section-inner"><h1 class="a-h">Search</h1><input id="q" class="a-in" placeholder="Search lectures and notes…" value="${esc(P.get('q')||'')}"><div id="res"></div></div></section>`;
 const go=()=>{const q=$('#q').value.toLowerCase().trim();if(!q){$('#res').innerHTML='';return}
  const l=D.lectures.filter(x=>(x.t+' '+x.n+' '+S(x.s).name).toLowerCase().includes(q)),m=D.material.filter(x=>(x.t+' '+x.d+' '+x.k).toLowerCase().includes(q));
  $('#res').innerHTML=`<h3>Lectures (${l.length})</h3>${l.map(lecRow).join('')}<h3>Material (${m.length})</h3><div class="a-grid">${m.map(matCard).join('')}</div>`};$('#q').oninput=go;go()},
more(el){const sv=saved(),L=D.lectures.filter(l=>sv[l.id]),M=D.material.filter(m=>sv[m.id]);
 el.innerHTML=`<section class="section"><div class="section-inner"><h1 class="a-h">More</h1><h3>🔖 Saved</h3>${L.map(lecRow).join('')}<div class="a-grid">${M.map(matCard).join('')}</div>${L.length+M.length?'':'<p>Nothing saved yet.</p>'}
 <h3>📢 Updates</h3>${D.updates.map(u=>`<p><b>${u.date}</b> — ${esc(u.text)}</p>`).join('')}
 <h3>⚙ Settings</h3><p>Daily goal (minutes): <input id="g" type="number" min="5" max="600" value="${goal()/60}" class="a-in" style="width:90px"></p>
 <div class="btns"><a href="doubts.html">💬 Doubts</a><a href="index.html#about">About</a><a href="index.html#community">Community</a><a href="${D.links.telegram}" target="_blank">Telegram</a><a href="${D.links.youtube}" target="_blank">YouTube</a><a href="${D.links.x}" target="_blank">X</a>
 <button id="rst">Reset my progress</button></div><small>Progress is saved on this device only.</small></div></section>`;
 $('#g').onchange=e=>LS.s('goal',Math.max(5,+e.target.value||30));$('#rst').onclick=()=>{if(confirm('Delete progress, saved items and streak on this device?')){['done','saved','study'].forEach(k=>localStorage.removeItem('es_'+k));location.reload()}}}};


const af=document.getElementById('ask-form');
if(af){const subs=D.subjects.filter(s=>s.live).map(s=>s.name).concat(['Other / General']);
 af.innerHTML=`<div class="ask"><h1 class="a-h" style="margin-top:0">Ask a doubt</h1><p>Stuck on a problem? Send it to us — it's free.</p>
 <input id="dn" class="a-in" placeholder="Your name (optional)" maxlength="60">
 <select id="ds" class="a-in">${subs.map(x=>`<option>${esc(x)}</option>`).join('')}</select>
 <textarea id="dq" class="a-in" rows="5" placeholder="Write your question... e.g. How do I check if (2xy)dx + (x²)dy = 0 is exact?"></textarea>
 <label class="photo">🖼 <span id="pn">Add a photo of the problem (optional)</span><input id="dp" type="file" accept="image/*" hidden></label>
 <button id="dsend" class="send">✈ Send via Telegram</button><small>🔒 No login needed</small><small id="dmsg"></small></div>`;
 $('#dp').onchange=e=>{$('#pn').textContent=e.target.files[0]?e.target.files[0].name:'Add a photo of the problem (optional)'};
 $('#dsend').onclick=async()=>{const q=$('#dq').value.trim(),nm=$('#dn').value.trim(),sb=$('#ds').value,f=$('#dp').files[0];
  if(!q&&!f){$('#dmsg').textContent='Please write your question first.';return}
  const text=`Doubt${nm?' from '+nm:''}\nSubject: ${sb}\n\n${q}`;
  if(f&&navigator.canShare&&navigator.canShare({files:[f]})){try{await navigator.share({files:[f],text});return}catch(e){if(e.name==='AbortError')return}}
  try{navigator.clipboard.writeText(text)}catch(e){}
  window.open(D.links.telegram,'_blank','noopener');
  $('#dmsg').textContent='Your question has been copied. Paste it in Telegram to send it'+(f?' (attach the photo there)':'')+'.'}}
const fq=document.getElementById('faq');
if(fq&&D.faq&&D.faq.length)fq.innerHTML='<h3 class="a-h" style="margin-top:2.5rem">Frequently asked</h3><div class="faq">'+D.faq.map(f=>`<details><summary>${esc(f.q)}</summary><p>${esc(f.a)}</p></details>`).join('')+'</div>';
const dx=document.getElementById('doubt-extra');
if(dx&&D.doubtLinks&&D.doubtLinks.length)dx.innerHTML='<div style="margin-top:3rem;border-top:1px solid #ffffff22;padding-top:2rem"><div class="btns">'+D.doubtLinks.map(l=>`<a href="${l.url}" target="_blank" rel="noopener">${esc(l.label)}</a>`).join('')+'</div></div>';
const el=$('#app');if(el&&R[el.dataset.page])R[el.dataset.page](el);
})();
