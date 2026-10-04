const CACHE = "emerging-sciences-v3";

// Core pages and assets to keep available offline
const CORE = [
  "./index.html",
  "./lectures.html",
  "./material.html",
  "./about.html",
  "./contact.html",
  "./doubts.html",
  "./watch.html",
  "./search.html",
  "./more.html",
  "./style.css",
  "./app.css",
  "./app.js",
  "./data.js",
  "./main.js",
  "./logo-icon.png",
  "./icon-192.png",
  "./icon-512.png"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE).then((cache) => cache.addAll(CORE)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

// Network first (so students always get your latest content), cache as fallback
self.addEventListener("fetch", (event) => {
  const req = event.request;
  const url = new URL(req.url);

  // Only handle GET requests from your own site; skip big videos
  if (req.method !== "GET" || url.origin !== location.origin || url.pathname.endsWith(".mp4")) {
    return;
  }

  event.respondWith(
    fetch(req)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((cache) => cache.put(req, copy));
        return res;
      })
      .catch(() => caches.match(req).then((hit) => hit || caches.match("./index.html")))
  );
});
