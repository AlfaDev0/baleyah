// Kill-switch service worker: purges stale Flutter caches from previous
// deployments, unregisters itself, then reloads open clients from network.
self.addEventListener('install', function () {
  self.skipWaiting();
});

self.addEventListener('activate', function (e) {
  e.waitUntil(
    caches
      .keys()
      .then(function (keys) {
        return Promise.all(keys.map(function (k) { return caches.delete(k); }));
      })
      .then(function () { return self.registration.unregister(); })
      .then(function () { return self.clients.matchAll(); })
      .then(function (clients) {
        clients.forEach(function (c) { return c.navigate(c.url); });
      })
  );
});
