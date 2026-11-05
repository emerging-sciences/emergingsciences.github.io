// Emerging Sciences — per-lecture comments (Firebase Auth + Firestore, free Spark plan)
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.14.1/firebase-app.js";
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut, onAuthStateChanged }
  from "https://www.gstatic.com/firebasejs/10.14.1/firebase-auth.js";
import { getFirestore, collection, addDoc, query, orderBy, limit, onSnapshot, deleteDoc, doc, serverTimestamp }
  from "https://www.gstatic.com/firebasejs/10.14.1/firebase-firestore.js";

// ====== STEP: yahan apni Firebase config paste karo (Firebase console > Project settings > Your apps > Web) ======
const firebaseConfig = {
  apiKey: "AIzaSyD_YYVetPkf6jOO4VfBetw0q-NaWUptYtk",
  authDomain: "emerging-sciences-ece22.firebaseapp.com",
  projectId: "emerging-sciences-ece22",
  storageBucket: "emerging-sciences-ece22.firebasestorage.app",
  messagingSenderId: "915855745802",
  appId: "1:915855745802:web:a9e3dab10ad94dc08310f3"
};
// ==========================================================================================================

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const MAX = 500;

function addStyle() {
  if (document.getElementById("cm-style")) return;
  const s = document.createElement("style");
  s.id = "cm-style";
  s.textContent = `
  .cm-box{margin:18px 0}
  .cm-bar{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:10px;font-size:14px}
  .cm-bar button,.cm-form button{cursor:pointer;border:1px solid rgba(255,255,255,.25);background:rgba(255,255,255,.08);color:inherit;border-radius:8px;padding:8px 14px;font:inherit}
  .cm-form textarea{width:100%;min-height:70px;box-sizing:border-box;border-radius:8px;border:1px solid rgba(255,255,255,.25);background:rgba(255,255,255,.05);color:inherit;padding:10px;font:inherit;resize:vertical}
  .cm-form .cm-row{display:flex;justify-content:space-between;align-items:center;margin-top:6px;font-size:12px;opacity:.8}
  .cm-item{display:flex;gap:10px;padding:12px 0;border-top:1px solid rgba(255,255,255,.12)}
  .cm-item img,.cm-av{width:32px;height:32px;border-radius:50%;flex:none;background:rgba(255,255,255,.2)}
  .cm-meta{font-size:12px;opacity:.7;margin-bottom:2px}
  .cm-txt{white-space:pre-wrap;word-break:break-word;font-size:14px}
  .cm-del{margin-left:8px;cursor:pointer;background:none;border:0;color:inherit;opacity:.7;font-size:12px}
  `;
  document.head.appendChild(s);
}

let unsub = null;

export function mount(lectureId, host) {
  if (!host || !lectureId) return;
  addStyle();
  host.innerHTML = "";
  const box = document.createElement("div");
  box.className = "cm-box";
  const h = document.createElement("h2");
  h.className = "a-h";
  h.textContent = "💬 Comments";
  const bar = document.createElement("div");
  bar.className = "cm-bar";
  const formWrap = document.createElement("div");
  const list = document.createElement("div");
  list.textContent = "Loading…";
  box.append(h, bar, formWrap, list);
  host.appendChild(box);

  const col = collection(db, "lectures", lectureId, "comments");

  // ---- login state ----
  onAuthStateChanged(auth, (user) => {
    bar.innerHTML = "";
    formWrap.innerHTML = "";
    if (!user) {
      const b = document.createElement("button");
      b.textContent = "Sign in with Google to comment";
      b.onclick = () => signInWithPopup(auth, new GoogleAuthProvider()).catch(() => alert("Sign-in nahi ho paya. Dobara try karo."));
      bar.appendChild(b);
      return;
    }
    const who = document.createElement("span");
    who.textContent = "Signed in as " + (user.displayName || "Student");
    const out = document.createElement("button");
    out.textContent = "Sign out";
    out.onclick = () => signOut(auth);
    bar.append(who, out);

    const form = document.createElement("div");
    form.className = "cm-form";
    const ta = document.createElement("textarea");
    ta.maxLength = MAX;
    ta.placeholder = "Apna doubt ya comment likho…";
    const row = document.createElement("div");
    row.className = "cm-row";
    const cnt = document.createElement("span");
    cnt.textContent = "0/" + MAX;
    const send = document.createElement("button");
    send.textContent = "Post";
    row.append(cnt, send);
    form.append(ta, row);
    formWrap.appendChild(form);
    ta.oninput = () => (cnt.textContent = ta.value.length + "/" + MAX);
    send.onclick = async () => {
      const text = ta.value.trim();
      if (!text) return;
      send.disabled = true;
      try {
        await addDoc(col, {
          uid: user.uid,
          name: (user.displayName || "Student").slice(0, 60),
          photo: user.photoURL || "",
          text: text.slice(0, MAX),
          ts: serverTimestamp()
        });
        ta.value = "";
        cnt.textContent = "0/" + MAX;
      } catch (e) {
        alert("Comment post nahi hua. Thodi der baad try karo.");
      }
      send.disabled = false;
    };
  });

  // ---- live comment list ----
  if (unsub) unsub();
  unsub = onSnapshot(
    query(col, orderBy("ts", "desc"), limit(100)),
    (snap) => {
      list.innerHTML = "";
      if (snap.empty) {
        list.textContent = "Abhi koi comment nahi. Pehla comment aap karo!";
        return;
      }
      snap.forEach((d) => {
        const c = d.data();
        const item = document.createElement("div");
        item.className = "cm-item";
        let av;
        if (c.photo && /^https:\/\//.test(c.photo)) {
          av = document.createElement("img");
          av.src = c.photo;
          av.alt = "";
          av.referrerPolicy = "no-referrer";
        } else {
          av = document.createElement("div");
          av.className = "cm-av";
        }
        const body = document.createElement("div");
        const meta = document.createElement("div");
        meta.className = "cm-meta";
        const when = c.ts && c.ts.toDate ? c.ts.toDate().toLocaleString() : "just now";
        meta.textContent = (c.name || "Student") + " · " + when;
        if (auth.currentUser && auth.currentUser.uid === c.uid) {
          const del = document.createElement("button");
          del.className = "cm-del";
          del.textContent = "🗑 Delete";
          del.onclick = () => confirm("Ye comment delete karein?") && deleteDoc(doc(db, "lectures", lectureId, "comments", d.id));
          meta.appendChild(del);
        }
        const txt = document.createElement("div");
        txt.className = "cm-txt";
        txt.textContent = c.text || "";
        body.append(meta, txt);
        item.append(av, body);
        list.appendChild(item);
      });
    },
    () => (list.textContent = "Comments abhi load nahi ho paye.")
  );
}
