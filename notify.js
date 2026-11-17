// Emerging Sciences — in-app notifications (🔔): reply to my comment; (teacher only) new student comments
import { auth, db, ADMIN_UIDS } from "./comments.js";
import { onAuthStateChanged, GoogleAuthProvider, signInWithPopup } from "https://www.gstatic.com/firebasejs/10.14.1/firebase-auth.js";
import { collection, query, orderBy, limit, onSnapshot, updateDoc, doc }
  from "https://www.gstatic.com/firebasejs/10.14.1/firebase-firestore.js";

const css = document.createElement("style");
css.textContent = `
#esBell{position:relative;background:none;border:0;cursor:pointer;color:var(--text,#fff);padding:8px;border-radius:10px;display:none;align-items:center;justify-content:center;min-width:36px;min-height:36px;font:inherit}
#esBell:hover{background:var(--blue-light,rgba(79,140,255,.12))}
#esBell svg{display:block}
#esBell b{position:absolute;top:0;right:0;min-width:18px;height:18px;border-radius:9px;background:#e53935;color:#fff;font-size:11px;font-weight:700;line-height:18px;text-align:center;padding:0 4px}
#esBell.fl{position:fixed;left:14px;bottom:14px;z-index:9998;width:48px;height:48px;border-radius:50%;border:1px solid var(--border-strong,rgba(255,255,255,.3));background:var(--surface,#14172a)}
#esPanel{position:fixed;z-index:9998;overflow:auto;border-radius:12px;border:1px solid var(--border-strong,rgba(255,255,255,.25));background:var(--surface,#0d1020);color:var(--text,#fff);display:none;font-size:14px;box-shadow:0 10px 30px rgba(0,0,0,.45)}
#esPanel .ph{display:flex;justify-content:space-between;align-items:center;padding:10px 12px;border-bottom:1px solid var(--border,rgba(255,255,255,.15))}
#esPanel .ph button{background:none;border:0;color:var(--blue,#9db1ff);cursor:pointer;font:inherit;font-size:12px}
#esPanel .ni{padding:10px 12px;border-bottom:1px solid var(--border,rgba(255,255,255,.1));cursor:pointer}
#esPanel .ni.new{background:var(--blue-light,rgba(110,140,255,.18))}
#esPanel .ni small{opacity:.7;display:block;margin-top:2px}
#esPanel .em{padding:16px 12px;opacity:.7}
`;
document.head.appendChild(css);

// The bell lives in the site header (next to Search / theme), so it can never cover the bottom bar's Home button.
// If the header is hidden (e.g. inside the mobile app) it floats just above the bottom bar instead.
const bell = document.createElement("button");
bell.id = "esBell";
bell.type = "button";
bell.setAttribute("aria-label", "Notifications");
bell.innerHTML =
  '<svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
  '<path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 01-3.4 0"/></svg>';
const badge = document.createElement("b");
badge.style.display = "none";
bell.appendChild(badge);
const panel = document.createElement("div");
panel.id = "esPanel";
document.body.appendChild(panel);

function mountBell() {
  const hdr = document.querySelector(".hdr");
  const hr = document.querySelector(".hdr-r");
  const inHeader = hdr && hr && getComputedStyle(hdr).display !== "none";
  if (inHeader) {
    bell.classList.remove("fl");
    bell.style.bottom = "";
    if (bell.parentNode !== hr) hr.insertBefore(bell, hr.querySelector(".th-toggle"));
  } else {
    bell.classList.add("fl");
    if (bell.parentNode !== document.body) document.body.appendChild(bell);
    let off = 14;
    const nb = document.querySelector(".bnav");
    if (nb && getComputedStyle(nb).display !== "none") {
      const r = nb.getBoundingClientRect();
      if (r.height > 0) off = Math.round(window.innerHeight - r.top) + 12;
    }
    bell.style.bottom = off + "px";
  }
}

// true when the bell sits in the site header (always visible); false = floating fallback (header hidden, e.g. in the app)
function headerShown() {
  const hdr = document.querySelector(".hdr");
  return !!(hdr && document.querySelector(".hdr-r") && getComputedStyle(hdr).display !== "none");
}

function paintLoggedOut() {
  badge.style.display = "none";
  panel.innerHTML = "";
  const head = document.createElement("div");
  head.className = "ph";
  const t = document.createElement("b");
  t.textContent = "Notifications";
  head.appendChild(t);
  const em = document.createElement("div");
  em.className = "em";
  em.textContent = "Koi aapke comment par reply kare to yahan dikhega. Iske liye Google se sign in karo.";
  const go = document.createElement("button");
  go.type = "button";
  go.textContent = "Sign in with Google";
  go.style.cssText = "display:block;margin:10px 12px 14px;padding:9px 14px;border:0;border-radius:10px;background:#4F8CFF;color:#fff;font:inherit;font-weight:600;cursor:pointer";
  go.onclick = () => signInWithPopup(auth, new GoogleAuthProvider()).catch((e) => alert("Sign-in nahi ho paya. Dobara try karo. (" + ((e && e.code) || "error") + ")"));
  panel.append(head, em, go);
}

function paintError(err) {
  badge.style.display = "none";
  panel.innerHTML = "";
  const head = document.createElement("div");
  head.className = "ph";
  const t = document.createElement("b");
  t.textContent = "Notifications";
  head.appendChild(t);
  const em = document.createElement("div");
  em.className = "em";
  em.textContent = "Notifications load nahi ho paye (" + ((err && err.code) || "error") + "). Page refresh karo; na ho to sign out karke dobara sign in karo.";
  panel.append(head, em);
}

function placePanel() {
  const r = bell.getBoundingClientRect();
  const w = Math.min(340, window.innerWidth - 16);
  panel.style.width = w + "px";
  if (bell.classList.contains("fl")) {
    panel.style.top = "auto";
    panel.style.bottom = window.innerHeight - r.top + 8 + "px";
    panel.style.left = Math.max(8, Math.min(r.left, window.innerWidth - w - 8)) + "px";
    panel.style.maxHeight = Math.max(160, r.top - 20) + "px";
  } else {
    panel.style.bottom = "auto";
    panel.style.top = r.bottom + 8 + "px";
    panel.style.left = Math.max(8, Math.min(r.right - w, window.innerWidth - w - 8)) + "px";
    panel.style.maxHeight = Math.max(160, window.innerHeight - r.bottom - 100) + "px";
  }
}

let items = [];
let unsub = null;

function lectureTitle(id) {
  try {
    const l = (window.ES_DATA.lectures || []).find((x) => x.id == id);
    return l ? l.n + " " + l.t : "";
  } catch (e) {
    return "";
  }
}

function markRead(ds) {
  const u = auth.currentUser;
  if (!u) return;
  return Promise.all(
    ds.filter((d) => !d.data().read).map((d) =>
      updateDoc(doc(db, "users", u.uid, "notifs", d.id), { read: true }).catch(() => {})
    )
  );
}

function paint() {
  const unread = items.filter((d) => !d.data().read).length;
  badge.textContent = unread > 9 ? "9+" : String(unread);
  badge.style.display = unread ? "block" : "none";

  panel.innerHTML = "";
  const head = document.createElement("div");
  head.className = "ph";
  const t = document.createElement("b");
  t.textContent = "Notifications";
  const all = document.createElement("button");
  all.textContent = "Mark all read";
  all.onclick = () => markRead(items);
  head.append(t, all);
  panel.appendChild(head);

  if (!items.length) {
    const em = document.createElement("div");
    em.className = "em";
    em.textContent = "Abhi koi notification nahi.";
    panel.appendChild(em);
    return;
  }
  items.forEach((d) => {
    const n = d.data();
    const row = document.createElement("div");
    row.className = "ni" + (n.read ? "" : " new");
    const a = document.createElement("div");
    const who = n.fromName || "Koi";
    a.textContent = n.kind === "new"
      ? who + " ne naya comment kiya"
      : (ADMIN_UIDS.includes(n.fromUid) ? "👨‍🏫 Teacher" : who) + " ne aapke comment par reply kiya";
    const b = document.createElement("small");
    b.textContent = "“" + (n.text || "") + "”";
    const c = document.createElement("small");
    c.textContent = lectureTitle(n.lectureId);
    row.append(a, b, c);
    row.onclick = async () => {
      await markRead([d]);
      location.href = "watch.html?id=" + encodeURIComponent(n.lectureId) + "#cmts";
    };
    panel.appendChild(row);
  });
}

bell.onclick = () => {
  const open = panel.style.display === "block";
  if (!open) {
    mountBell();
    placePanel();
  }
  panel.style.display = open ? "none" : "block";
};
window.addEventListener("resize", () => {
  if (bell.style.display === "none") return;
  mountBell();
  if (panel.style.display === "block") placePanel();
});

// Bell is always visible in the header (every page). Logged out -> it explains how to get notifications.
if (headerShown()) {
  mountBell();
  bell.style.display = "flex";
  paintLoggedOut();
}

onAuthStateChanged(auth, (user) => {
  if (unsub) {
    unsub();
    unsub = null;
  }
  items = [];
  panel.style.display = "none";
  mountBell();
  if (!user) {
    paintLoggedOut();
    // floating fallback (header hidden, e.g. inside the app) only appears for signed-in users
    bell.style.display = headerShown() ? "flex" : "none";
    return;
  }
  bell.style.display = "flex";
  unsub = onSnapshot(
    query(collection(db, "users", user.uid, "notifs"), orderBy("ts", "desc"), limit(30)),
    (snap) => {
      items = snap.docs;
      paint();
    },
    (err) => {
      // Before this was silent: the bell just stayed empty. Now the panel says what went wrong.
      console.error("Emerging Sciences: notifications could not be loaded", err);
      paintError(err);
    }
  );
});
