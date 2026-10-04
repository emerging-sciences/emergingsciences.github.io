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
function dash(){const el=$('#dash');if(!el)return;const t=study()[day()]||0,g=goal(),pct=Math.min(100,t/g*100);
 const dl=Math.max(0,Math.ceil((new Date(D.exam.date)-new Date())/864e5));
 el.innerHTML=`<div class="a-card"><b>Daily goal</b><div class="bar"><i style="width:${pct}%"></i></div><small>${Math.floor(t/60)} / ${g/60} min · counts while a lecture plays</small></div>
 <div class="a-card"><b>🔥 ${streak()} days</b><small>Study streak</small></div>
 <div class="a-card"><b>${dl} days</b><small>to ${esc(D.exam.name)} (${D.exam.note})</small></div>`}
function subjCards(){const d=done();return `<div class="a-grid">`+D.subjects.map(s=>{if(!s.live)return `<div class="a-card dim"><span class="ic">${s.icon}</span><h3>${s.name}</h3><small>Coming soon</small></div>`;
 const L=LECS(s.id),c=L.filter(l=>d[l.id]).length;return `<a class="a-card" href="lectures.html?s=${s.id}"><span class="ic">${s.icon}</span><h3>${s.name}</h3><small>${L.length} lectures · ${c}/${L.length} completed</small><div class="bar"><i style="width:${c/L.length*100}%"></i></div></a>`}).join('')+`</div>`}
function lecRow(l){const d=done(),sv=saved();return `<a class="a-row" href="watch.html?id=${l.id}"><span class="num">${l.n}</span><span class="tt">${esc(l.t)}</span><span class="tag">${l.k=='P'?'Practice':'Theory'}</span><span>${d[l.id]?'✅':''}${sv[l.id]?'🔖':''}</span></a>`}
function matCard(m){const sv=saved();return `<div class="a-card"><h3>${esc(m.t)}</h3><small>${esc(m.d)}</small><div class="tags"><span class="tag">${m.k}</span><span class="tag">${S(m.s).name}</span></div>
 <div class="btns"><button onclick="ES.read('${m.id}')">📖 Read</button><a href="https://drive.google.com/uc?export=download&id=${m.drive}" target="_blank" rel="noopener">⬇ Download</a><button onclick="ES.save('${m.id}',this)">${sv[m.id]?'🔖 Saved':'🔖 Save'}</button></div></div>`}
window.ES={
 read(id){const m=D.material.find(x=>x.id==id);const o=document.createElement('div');o.className='modal';
  o.innerHTML=`<div class="mbar"><b>${esc(m.t)}</b><span><button onclick="this.closest('.modal').classList.toggle('night')">🌙 Night</button><button onclick="this.closest('.modal').remove()">✕</button></span></div><iframe src="https://drive.google.com/file/d/${m.drive}/preview" allow="autoplay"></iframe>`;document.body.appendChild(o)},
 save(id,b){const on=toggle('saved',id);b.textContent=on?'🔖 Saved':'🔖 Save'}};
const R={
home(el){el.innerHTML=`<section class="section"><div class="section-inner"><div id="dash" class="a-grid3"></div><h2 class="a-h">Subjects</h2>${subjCards()}</div></section>`;dash()},
lectures(el){const s=P.get('s'),sub=S(s);if(!sub||!sub.live){el.innerHTML=`<section class="section"><div class="section-inner"><h1 class="a-h">Lectures</h1>${subjCards()}</div></section>`;return}
 const L=LECS(s),c=L.filter(l=>done()[l.id]).length,f=P.get('f')||'all';
 el.innerHTML=`<section class="section"><div class="section-inner"><a href="lectures.html">← Lectures</a><h1 class="a-h">${sub.icon} ${sub.name}</h1><p>${c} of ${L.length} completed</p>
 <div class="chips">${[['all','All'],['T','Theory'],['P','Practice']].map(([k,n])=>`<a class="${f==k?'on':''}" href="?s=${s}&f=${k}">${n}</a>`).join('')}</div>${L.filter(l=>f=='all'||l.k==f).map(lecRow).join('')}</div></section>`},
watch(el){const l=LEC(P.get('id'));if(!l){el.innerHTML=`<section class="section"><div class="section-inner">Lecture not found. <a href="lectures.html">All lectures</a></div></section>`;return}
 const L=LECS(l.s),i=L.indexOf(l),nx=L[i+1],auto=LS.g('auto',true);document.title=l.n+' '+l.t+' — Emerging Sciences';
 el.innerHTML=`<section class="section"><div class="section-inner"><a href="lectures.html?s=${l.s}">← ${S(l.s).name}</a><h1 class="a-h">${l.n} · ${esc(l.t)}</h1>
 <div class="vid"><div id="yt"></div></div><div class="btns"><button id="bDone"></button><button id="bSave"></button><button id="bShare">🔗 Share</button><a href="material.html?s=${l.s}">📄 Notes</a>
 <label><input type="checkbox" id="auto" ${auto?'checked':''}> Auto-play next</label></div><div class="chips" id="spd">${[.75,1,1.25,1.5,2].map(x=>`<a href="#" data-v="${x}">${x}x</a>`).join('')}</div>
 <h2 class="a-h">Up next</h2>${L.slice(i+1,i+6).map(lecRow).join('')||'<p>Last lecture of this subject 🎉</p>'}</div></section>`;
 const bd=$('#bDone'),bs=$('#bSave'),paint=()=>{bd.textContent=done()[l.id]?'✅ Completed':'☐ Mark complete';bs.textContent=saved()[l.id]?'🔖 Saved':'🔖 Save'};paint();
 bd.onclick=()=>{toggle('done',l.id);paint()};bs.onclick=()=>{toggle('saved',l.id);paint()};$('#auto').onchange=e=>LS.s('auto',e.target.checked);
 $('#bShare').onclick=()=>{const u=location.href;navigator.share?navigator.share({title:l.t,url:u}).catch(()=>{}):navigator.clipboard.writeText(u).then(()=>alert('Link copied'))};
 let pl;const mk=()=>{pl=new YT.Player('yt',{videoId:l.yt,width:'100%',height:'100%',playerVars:{rel:0,playsinline:1},events:{onStateChange:e=>{if(e.data==0){if(!done()[l.id]){toggle('done',l.id);paint()}if($('#auto').checked&&nx)location.href='watch.html?id='+nx.id}}}})};
 $('#spd').onclick=e=>{const v=e.target.dataset.v;if(v){e.preventDefault();pl&&pl.setPlaybackRate(+v)}};
 const s=document.createElement('script');s.src='https://www.youtube.com/iframe_api';document.head.appendChild(s);window.onYouTubeIframeAPIReady=mk;
 setInterval(()=>{if(pl&&pl.getPlayerState&&pl.getPlayerState()==1)addSec()},1000)},
material(el){const s=P.get('s')||'all',k=P.get('k')||'all',q=(a,b)=>`?s=${a}&k=${b}`;
 el.innerHTML=`<section class="section"><div class="section-inner"><h1 class="a-h">Study Material</h1><p>Watch the lecture → read the notes → practice</p>
 <div class="chips">${[['all','All subjects'],...D.subjects.filter(x=>x.live).map(x=>[x.id,x.name])].map(([a,n])=>`<a class="${s==a?'on':''}" href="${q(a,k)}">${n}</a>`).join('')}</div>
 <div class="chips">${['all','Notes','PYQ','Practice'].map(a=>`<a class="${k==a?'on':''}" href="${q(s,a)}">${a=='all'?'All':a}</a>`).join('')}</div>
 <div class="a-grid">${D.material.filter(m=>(s=='all'||m.s==s)&&(k=='all'||m.k==k)).map(matCard).join('')}</div></div></section>`},
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

const fq=document.getElementById('faq');
if(fq&&D.faq&&D.faq.length)fq.innerHTML='<h3 class="a-h" style="margin-top:3rem">❓ FAQ</h3><div class="faq">'+D.faq.map(f=>`<details><summary>${esc(f.q)}</summary><p>${esc(f.a)}</p></details>`).join('')+'</div>';
const dx=document.getElementById('doubt-extra');
if(dx&&D.doubtLinks&&D.doubtLinks.length)dx.innerHTML='<div style="margin-top:3rem;border-top:1px solid #ffffff22;padding-top:2rem"><div class="btns">'+D.doubtLinks.map(l=>`<a href="${l.url}" target="_blank" rel="noopener">${esc(l.label)}</a>`).join('')+'</div></div>';
const el=$('#app');if(el&&R[el.dataset.page])R[el.dataset.page](el);
})();
