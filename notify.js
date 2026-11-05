// Emerging Sciences — in-app notifications (🔔): "kisi ne aapke comment par reply kiya"
import { auth, db } from "./comments.js";
import { onAuthStateChanged } from "https://www.gstatic.com/firebasejs/10.14.1/firebase-auth.js";
import { collection, query, orderBy, limit, onSnapshot, updateDoc, doc }
  from "https://www.gstatic.com/firebasejs/10.14.1/firebase-firestore.js";

const css = document.createElement("style");
css.textContent = `
#esBell{position:fixed;left:14px;bottom:14px;z-index:9998;width:48px;height:48px;border-radius:50%;border:1px solid rgba(255,255,255,.3);background:#14172a;color:#fff;font-size:22px;cursor:pointer;display:none;align-items:center;justify-content:center}
#esBell b{position:absolute;top:-4px;right:-4px;min-width:20px;height:20px;border-radius:10px;background:#e53935;color:#fff;font-size:12px;line-height:20px;text-align:center;padding:0 4px}
#esPanel{position:fixed;left:14px;bottom:70px;z-index:9998;width:min(340px,calc(100vw - 28px));max-height:60vh;overflow:auto;border-radius:12px;border:1px solid rgba(255,255,255,.25);background:#0d1020;color:#fff;display:none;font-size:14px}
#esPanel .ph{display:flex;justify-content:space-between;align-items:center;padding:10px 12px;border-bottom:1px solid rgba(255,255,255,.15)}
#esPanel .ph button{background:none;border:0;color:#9db1ff;cursor:pointer;font:inherit;font-size:12px}
#esPanel .ni{padding:10px 12px;border-bottom:1px solid rgba(255,255,255,.1);cursor:pointer}
#esPanel .ni.new{background:rgba(110,140,255,.18)}
#esPanel .ni small{opacity:.7;display:block;margin-top:2px}
#esPanel .em{padding:16px 12px;opacity:.7}
`;
document.head.appendChild(css);

const bell = document.createElement("button");
bell.id = "esBell";
bell.setAttribute("aria-label", "Notifications");
bell.textContent = "🔔";
const badge = document.createElement("b");
badge.style.display = "none";
bell.appendChild(badge);
const panel = document.createElement("div");
panel.id = "esPanel";
document.body.append(bell, panel);

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
    a.textContent = (n.fromName || "Koi") + " ne aapke comment par reply kiya";
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
  panel.style.display = panel.style.display === "block" ? "none" : "block";
};

onAuthStateChanged(auth, (user) => {
  if (unsub) {
    unsub();
    unsub = null;
  }
  items = [];
  panel.style.display = "none";
  if (!user) {
    bell.style.display = "none";
    return;
  }
  bell.style.display = "flex";
  unsub = onSnapshot(
    query(collection(db, "users", user.uid, "notifs"), orderBy("ts", "desc"), limit(30)),
    (snap) => {
      items = snap.docs;
      paint();
    },
    () => {}
  );
});
