// Emerging Sciences — per-lecture comments (Firebase Auth + Firestore, free Spark plan)
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.14.1/firebase-app.js";
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut, onAuthStateChanged }
  from "https://www.gstatic.com/firebasejs/10.14.1/firebase-auth.js";
import { getFirestore, collection, addDoc, query, orderBy, limit, onSnapshot, deleteDoc, doc, serverTimestamp, getDoc, setDoc, where, getCountFromServer, updateDoc, arrayUnion, arrayRemove }
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
// OWNER / TEACHER: apna Firebase UID yahan likho (Firebase console > Authentication > Users > "User UID").
// Is UID wale ke comments par "Teacher" tag lagta hai, wo kisi ka bhi comment delete kar sakta hai,
// aur students ke naye comments ki notification (🔔) isi ko aati hai. Khali rakhoge to ye teeno band rahenge.
// Same UID firestore.rules me bhi likhna hai.
export const ADMIN_UIDS = [ /* "PASTE_YOUR_UID_HERE" */ ];
const isAdmin = (u) => !!u && ADMIN_UIDS.includes(u.uid);
export { app, auth, db };

function addStyle() {
  if (document.getElementById("cm-style")) return;
  const s = document.createElement("style");
  s.id = "cm-style";
  s.textContent = `
  .cm-box{margin:18px 0}
  .cm-vote{display:flex;gap:10px;margin:0 0 14px}
  .cm-vote button{cursor:pointer;border:1px solid rgba(255,255,255,.25);background:rgba(255,255,255,.08);color:inherit;border-radius:999px;padding:8px 16px;font:inherit}
  .cm-vote button.on{background:rgba(110,140,255,.35);border-color:rgba(110,140,255,.9)}
  .cm-bar{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:10px;font-size:14px}
  .cm-bar button,.cm-form button{cursor:pointer;border:1px solid rgba(255,255,255,.25);background:rgba(255,255,255,.08);color:inherit;border-radius:8px;padding:8px 14px;font:inherit}
  .cm-form textarea{width:100%;min-height:70px;box-sizing:border-box;border-radius:8px;border:1px solid rgba(255,255,255,.25);background:rgba(255,255,255,.05);color:inherit;padding:10px;font:inherit;resize:vertical}
  .cm-form .cm-row{display:flex;justify-content:space-between;align-items:center;margin-top:6px;font-size:12px;opacity:.8}
  .cm-item{display:flex;gap:10px;padding:12px 0;border-top:1px solid rgba(255,255,255,.12)}
  .cm-item img,.cm-av{width:32px;height:32px;border-radius:50%;flex:none;background:rgba(255,255,255,.2)}
  .cm-meta{font-size:12px;opacity:.7;margin-bottom:2px}
  .cm-txt{white-space:pre-wrap;word-break:break-word;font-size:14px}
  .cm-like{margin-top:6px;cursor:pointer;border:1px solid rgba(255,255,255,.2);background:none;color:inherit;border-radius:999px;padding:3px 10px;font:inherit;font-size:12px}
  .cm-like.on{background:rgba(110,140,255,.35);border-color:rgba(110,140,255,.9)}
  .cm-replies{margin-left:42px}
  .cm-rbox{margin-top:8px}
  .cm-rbox textarea{width:100%;min-height:54px;box-sizing:border-box;border-radius:8px;border:1px solid rgba(255,255,255,.25);background:rgba(255,255,255,.05);color:inherit;padding:8px;font:inherit}
  .cm-rbox button{margin-top:6px;cursor:pointer;border:1px solid rgba(255,255,255,.25);background:rgba(255,255,255,.08);color:inherit;border-radius:8px;padding:6px 12px;font:inherit}
  .cm-gone{font-style:italic;opacity:.6;font-size:13px}
  .cm-del{margin-left:8px;cursor:pointer;background:none;border:0;color:inherit;opacity:.7;font-size:12px}
  `;
  document.head.appendChild(s);
}

let unsub = null;

// Small message at the bottom of the screen (does not block the page).
function toast(msg) {
  const t = document.createElement("div");
  t.textContent = msg;
  t.style.cssText =
    "position:fixed;left:50%;transform:translateX(-50%);bottom:90px;max-width:90vw;z-index:10000;padding:10px 16px;border-radius:10px;background:#c62828;color:#fff;font-size:13px;box-shadow:0 6px 20px rgba(0,0,0,.4)";
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 7000);
}

// Writes "X replied to your comment" into the other user's inbox: users/{uid}/notifs.
// Returns null on success, or the Firebase error code (for example "permission-denied") on failure.
// (Before, a failure here was swallowed silently, so nobody ever knew why a notification did not arrive.)
async function pushNotif(toUid, notifId, data) {
  for (let i = 0; i < 2; i++) {
    try {
      await setDoc(doc(db, "users", toUid, "notifs", notifId), { ...data, ts: serverTimestamp(), read: false });
      return null;
    } catch (e) {
      console.error("Emerging Sciences: notification could not be saved", e);
      if (e && e.code === "permission-denied") return e.code; // retrying cannot help: Firestore rules block it
      if (i === 1) return (e && e.code) || "error";
      await new Promise((r) => setTimeout(r, 800));
    }
  }
  return "error";
}

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
  const vbar = document.createElement("div");
  vbar.className = "cm-vote";
  box.append(vbar, h, bar, formWrap, list);
  host.appendChild(box);

  const col = collection(db, "lectures", lectureId, "comments");

  // ---- like / dislike (ek user ka ek vote) ----
  const votes = collection(db, "lectures", lectureId, "votes");
  let up = 0, down = 0, mine = 0;
  function paintVotes() {
    vbar.innerHTML = "";
    [["👍", 1, up], ["👎", -1, down]].forEach(([icon, val, n]) => {
      const b = document.createElement("button");
      b.textContent = icon + " " + n;
      if (mine === val) b.className = "on";
      b.onclick = () => castVote(val);
      vbar.appendChild(b);
    });
  }
  async function loadVotes() {
    try {
      const [a, b] = await Promise.all([
        getCountFromServer(query(votes, where("v", "==", 1))),
        getCountFromServer(query(votes, where("v", "==", -1)))
      ]);
      up = a.data().count;
      down = b.data().count;
      const u = auth.currentUser;
      mine = 0;
      if (u) {
        const m = await getDoc(doc(votes, u.uid));
        mine = m.exists() ? m.data().v : 0;
      }
    } catch (e) {}
    paintVotes();
  }
  async function castVote(val) {
    const u = auth.currentUser;
    if (!u) {
      signInWithPopup(auth, new GoogleAuthProvider()).catch((e) => alert("Vote ke liye Google sign-in zaruri hai. (" + ((e && e.code) || "error") + ")"));
      return;
    }
    try {
      if (mine === val) await deleteDoc(doc(votes, u.uid));
      else await setDoc(doc(votes, u.uid), { v: val });
    } catch (e) {
      alert("Vote save nahi hua. Thodi der baad try karo.");
      return;
    }
    loadVotes();
  }
  paintVotes();

  // ---- login state ----
  let lastSnap = null;
  let draw = () => {};
  onAuthStateChanged(auth, (user) => {
    loadVotes();
    if (lastSnap) draw(lastSnap);
    bar.innerHTML = "";
    formWrap.innerHTML = "";
    if (!user) {
      const b = document.createElement("button");
      b.textContent = "Sign in with Google to comment";
      b.onclick = () => signInWithPopup(auth, new GoogleAuthProvider()).catch((e) => alert("Sign-in nahi ho paya. Dobara try karo. (" + ((e && e.code) || "error") + ")"));
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
        const nref = doc(col);
        await setDoc(nref, {
          uid: user.uid,
          name: (user.displayName || "Student").slice(0, 60),
          photo: user.photoURL || "",
          text: text.slice(0, MAX),
          likedBy: [],
          ts: serverTimestamp()
        });
        if (ADMIN_UIDS[0] && !isAdmin(user)) {
          pushNotif(ADMIN_UIDS[0], nref.id, {
            kind: "new",
            fromUid: user.uid,
            fromName: (user.displayName || "Student").slice(0, 60),
            text: text.slice(0, 120),
            lectureId: lectureId
          });
        }
        ta.value = "";
        cnt.textContent = "0/" + MAX;
      } catch (e) {
        alert("Comment post nahi hua. Thodi der baad try karo.");
      }
      send.disabled = false;
    };
  });

  // ---- live comment list (comments + replies) ----
  function signIn(msg) {
    signInWithPopup(auth, new GoogleAuthProvider()).catch((e) => alert(msg + " (" + ((e && e.code) || "error") + ")"));
  }

  // Delete: root comment with replies -> tombstone (replies stay); otherwise real delete + remove the related 🔔.
  async function removeComment(d, c, hasReplies) {
    const ref = doc(db, "lectures", lectureId, "comments", d.id);
    const isRoot = !c.parentId;
    try {
      if (isRoot && hasReplies) {
        await updateDoc(ref, { deleted: true, text: "", name: "", photo: "" });
      } else {
        await deleteDoc(ref);
      }
      if (!isRoot && c.replyToUid) deleteDoc(doc(db, "users", c.replyToUid, "notifs", d.id)).catch(() => {});
      if (isRoot && ADMIN_UIDS[0]) deleteDoc(doc(db, "users", ADMIN_UIDS[0], "notifs", d.id)).catch(() => {});
    } catch (e) {
      alert("Delete nahi ho paya. Thodi der baad try karo.");
    }
  }

  function mkItem(d, rootId, hasReplies) {
    const c = d.data();
    if (c.deleted) {
      const g = document.createElement("div");
      g.className = "cm-item cm-gone";
      g.textContent = "🗑 Ye comment delete kar diya gaya.";
      return g;
    }
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
    body.style.flex = "1";
    const meta = document.createElement("div");
    meta.className = "cm-meta";
    const when = c.ts && c.ts.toDate ? c.ts.toDate().toLocaleString() : "just now";
    meta.textContent = (c.name || "Student") + (ADMIN_UIDS.includes(c.uid) ? " ✔ Teacher" : "") + " \u00b7 " + when;
    if (auth.currentUser && (auth.currentUser.uid === c.uid || isAdmin(auth.currentUser))) {
      const del = document.createElement("button");
      del.className = "cm-del";
      del.textContent = "\ud83d\uddd1 Delete";
      del.onclick = () => confirm("Ye comment delete karein?") && removeComment(d, c, hasReplies);
      meta.appendChild(del);
    }
    const txt = document.createElement("div");
    txt.className = "cm-txt";
    txt.textContent = c.text || "";

    // like
    const likedBy = Array.isArray(c.likedBy) ? c.likedBy : [];
    const me = auth.currentUser;
    const lk = document.createElement("button");
    lk.className = "cm-like" + (me && likedBy.includes(me.uid) ? " on" : "");
    lk.textContent = "\ud83d\udc4d " + likedBy.length;
    lk.onclick = () => {
      const u = auth.currentUser;
      if (!u) return signIn("Like ke liye Google sign-in zaruri hai.");
      updateDoc(doc(db, "lectures", lectureId, "comments", d.id), {
        likedBy: likedBy.includes(u.uid) ? arrayRemove(u.uid) : arrayUnion(u.uid)
      }).catch(() => alert("Like save nahi hua. Thodi der baad try karo."));
    };

    // reply
    const rb = document.createElement("button");
    rb.className = "cm-like";
    rb.style.marginLeft = "6px";
    rb.textContent = "\u21a9 Reply";
    const rbox = document.createElement("div");
    rbox.className = "cm-rbox";
    rb.onclick = () => {
      const u = auth.currentUser;
      if (!u) return signIn("Reply ke liye Google sign-in zaruri hai.");
      if (rbox.firstChild) {
        rbox.innerHTML = "";
        return;
      }
      const ta = document.createElement("textarea");
      ta.maxLength = MAX;
      ta.value = "@" + (c.name || "Student") + " ";
      const send = document.createElement("button");
      send.textContent = "Post reply";
      send.onclick = async () => {
        const text = ta.value.trim();
        if (!text) return;
        send.disabled = true;
        const myName = (u.displayName || "Student").slice(0, 60);
        try {
          const rref = doc(col);
          await setDoc(rref, {
            uid: u.uid,
            name: myName,
            photo: u.photoURL || "",
            text: text.slice(0, MAX),
            likedBy: [],
            parentId: rootId,
            replyToUid: c.uid,
            ts: serverTimestamp()
          });
          if (c.uid && c.uid !== u.uid) {
            const bad = await pushNotif(c.uid, rref.id, {
              kind: "reply",
              fromUid: u.uid,
              fromName: myName,
              text: text.slice(0, 120),
              lectureId: lectureId
            });
            if (bad) toast("Reply post ho gaya, par unko notification nahi ja paya (" + bad + ").");
          }
          rbox.innerHTML = "";
        } catch (e) {
          alert("Reply post nahi hua. Thodi der baad try karo.");
          send.disabled = false;
        }
      };
      rbox.append(ta, send);
      ta.focus();
    };

    body.append(meta, txt, lk, rb, rbox);
    item.append(av, body);
    return item;
  }

  draw = (snap) => {
    list.innerHTML = "";
    const tops = [];
    const kids = {};
    const topIds = {};
    snap.forEach((d) => {
      const pid = d.data().parentId;
      if (pid) (kids[pid] = kids[pid] || []).push(d);
      else {
        tops.push(d);
        topIds[d.id] = 1;
      }
    });
    // deleted comment with no replies left = nothing to show
    const live = tops.filter((d) => !d.data().deleted || (kids[d.id] || []).length);
    // replies whose parent is missing (old data / parent not in the latest 200): keep them visible
    const orphans = Object.keys(kids).filter((id) => !topIds[id]);
    if (!live.length && !orphans.length) {
      list.textContent = "Abhi koi comment nahi. Pehla comment aap karo!";
      return;
    }
    const addReplies = (wrap, rs, rootId) => {
      if (!rs.length) return;
      const rw = document.createElement("div");
      rw.className = "cm-replies";
      rs.slice().reverse().forEach((r) => rw.appendChild(mkItem(r, rootId, false))); // purane reply pehle
      wrap.appendChild(rw);
    };
    live.forEach((d) => {
      const wrap = document.createElement("div");
      const rs = kids[d.id] || [];
      wrap.appendChild(mkItem(d, d.id, rs.length > 0));
      addReplies(wrap, rs, d.id);
      list.appendChild(wrap);
    });
    orphans.forEach((pid) => {
      const wrap = document.createElement("div");
      const g = document.createElement("div");
      g.className = "cm-item cm-gone";
      g.textContent = "↪ Original comment dikh nahi raha (delete ho gaya ya bahut purana hai).";
      wrap.appendChild(g);
      addReplies(wrap, kids[pid], pid);
      list.appendChild(wrap);
    });
  };

  if (unsub) unsub();
  unsub = onSnapshot(
    query(col, orderBy("ts", "desc"), limit(200)),
    (snap) => {
      lastSnap = snap;
      draw(snap);
    },
    () => (list.textContent = "Comments abhi load nahi ho paye.")
  );
}
