'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"sql-wasm.js": "abe5911756c78d17a8b67a113f4a62b2",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"manifest.json": "ef07df3aa1d4ed731275e94c342f49d0",
"icons/icon-512-maskable.png": "5dfc0467cd07ff038be448630de92e0c",
"icons/apple-touch-icon.png": "63f09bb289288b89645486caeaca32b4",
"icons/Icon-192.png": "1d7f1ea18445b84b71816fc0b2efa4a6",
"icons/icon-192-maskable.png": "dd8f9f3568da0c5dd04298a4aab7410b",
"icons/favicon.ico": "a50c07ac9292ce030e14d0b2638f17eb",
"icons/Icon-512.png": "fde4c3533c88d3b55fa2bc5ecfc197ba",
"main.dart.js": "f39bfe4ab2002968952ed86d86209254",
"version.json": "05d9139ee86bf6f38b108d310ae8f6ff",
"sql-wasm.wasm": "9c67691cdfea004dda62090e49940eac",
"assets/NOTICES": "1dd9d0a6fe3d325638c216a23899c6e1",
"assets/fonts/MaterialIcons-Regular.otf": "b41972939169f69427408303a13eba24",
"assets/AssetManifest.json": "70c02e7942e9b54f8099808fd09f3300",
"assets/assets/onboard/money.png": "ccc74837b3a5edb167304d22b6e98470",
"assets/assets/onboard/floating-piggy.png": "a535c5bf0fb2005cbc51e5df7b2f09f0",
"assets/assets/onboard/coins.png": "3fc8862506e45674e7e660f32d2e22a6",
"assets/assets/onboard/hourglass.png": "7b49fa9776c5b3194a8e64701a296710",
"assets/assets/onboard/piggy-bank.png": "e3833e96c3171d0fcebd1e58d12e4da1",
"assets/assets/icons/cupcake.png": "963b8ea96f1b0a0d906779951a238feb",
"assets/assets/icons/coffee-cup.png": "886b39d17247ffa0f47c3ade75830252",
"assets/assets/icons/salad.png": "d1678bcc876fc1441c2a37a9dc496525",
"assets/assets/translations/translationsAppKeyed.json": "f0fb84604ca4714927bcd0146a320b2c",
"assets/assets/cashew-promo/CashewPromoDark.png": "288670783097c8be86eb53f309d3b2fa",
"assets/assets/cashew-promo/CashewPromoLightAll.png": "96671bdffd073c284dd0d8cf533aa9d6",
"assets/assets/cashew-promo/CashewPromoDarkAll.png": "d240441420093a9d3c6da70d8e7002af",
"assets/assets/cashew-promo/CashewPromoLight.png": "ae471285b39d38b5882b6ad1d6293b7e",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin.json": "d817eeae33db3db6981a501838711353",
"assets/AssetManifest.bin": "a8b4528cc6dd215528e26c458eb17a3d",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"favicon.ico": "a50c07ac9292ce030e14d0b2638f17eb",
"worker.sql-wasm.js": "4005701fc5e429b58ee5fea627c48449",
"index.html": "5c4adb0f3279737f1a5e7e691fe8a3a6",
"/": "5c4adb0f3279737f1a5e7e691fe8a3a6"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
