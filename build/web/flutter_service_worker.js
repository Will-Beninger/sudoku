'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "065d860d3e113393f705ba93e6b68f38",
".git/config": "6b5df27e31358797843c96d72badbe8a",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "ea587b0fae70333bce92257152996e70",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "37e9a8bb2383c76ad60186f6cd1e306f",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "bd73524325262b96eeff26a9387d70de",
".git/logs/refs/heads/gh-pages": "fe2723d1c856043f05504504e415e341",
".git/logs/refs/heads/main": "dd95a3b1a6ce034849844a37f67b2f6f",
".git/logs/refs/remotes/origin/gh-pages": "f4eb12e78ddc337491f0fa2ace589afc",
".git/objects/03/ea885ad3ff94cc462a2f5515d25adec377abc8": "be5ad13516c7f4d62d7fa3f6d2f8bd52",
".git/objects/05/7cdc988410ef28f39f3f3ffd2d570cd2c1a008": "3a309d17827c234ecfc4da8cf7f4959d",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/17/90f6ee7b18be890e0c68009454b7ccf4b7ada0": "226bf7dd8912d292bb2ae4b9750a3a01",
".git/objects/28/9a77dbf997ed6f44c85ce6db3ed1979ae5b04b": "be874a911f600d8eba7e01971663161b",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/3a/fa38439ddc7050fd7385350fba81fc6f46bf71": "38a0fb8b76e37a696ee9c8540c64ff3f",
".git/objects/3d/1e6d7678fd23440fc5f0307e6a91e09a2d0b94": "869df7299ca727f1655b5d9a17130a91",
".git/objects/3f/6fb531a04ded32ab8a5292ceb702c62dfc65f9": "68b4a96187a52044c498dc89a5536c7e",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/49/254a8494d8d8cc46f1cde6fa0e1a59f5aa95dc": "a4a64de81bbcb636107f5c5fc7011009",
".git/objects/4a/1c766fa268e92817856b7d609cb882df013704": "d38dd84a2b017504aa5d6137d80065e8",
".git/objects/4f/45a0d22ce2b8a3abdad40a620d42d616bf066e": "4ee0399e6a58b70697017da11e1bdfd4",
".git/objects/50/936ee4de204887dd917edae530218eb39ebee4": "aeb4369a0872aef064ccfb4230466b85",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/53/59f941301945ef627af91ca39d617d1ddb5e3a": "0312ba94cd1b58b637b93a2263ea0e68",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/7c/bc79cf48007581efb75bf0e104e67fa6b1c3ca": "14ff69b3bb92bc0536b84827e64fd9fc",
".git/objects/82/7dc5bc617449779f85aa75b53da27821a5ec2f": "d3b445e8751be83d94c60153284cb401",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/objects/8d/3979bd1fb749fb43fda2c0f16f72c36beca3a4": "68ec990739b7eb8011203450d14d2c82",
".git/objects/8e/21753cdb204192a414b235db41da6a8446c8b4": "1e467e19cabb5d3d38b8fe200c37479e",
".git/objects/8f/bf8143d0bc43e8010b7c79033a12d891830222": "a5a131cb9ba06dc07290f0e15a570780",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/97/9c6586564e30eddc8ec1a4c494c1f8701ca08b": "03f02517f11d783bb4b1b4934233b51d",
".git/objects/a0/fd3ff9d307067260c5bf66382505c68ff1faa1": "063246581b5a95d218a84c1e69e7b407",
".git/objects/a3/7db37bbf4f120594e5940c77741e6540d26e65": "c5cfd6c7a7ad191e79c93c9258860c28",
".git/objects/a7/3f4b23dde68ce5a05ce4c658ccd690c7f707ec": "ee275830276a88bac752feff80ed6470",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/b6/9601e64877e96e8dae93b588dd37324b3477a4": "b31b4a055e1293490023eb66c4bf6557",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d4/79a941f506e4afa9dfb8b6b5b84020c462e64d": "11c4cf9b4a3f102351ffe971c739540c",
".git/objects/d6/986c4a322c4c044f73a62a6fad505f93b03fbd": "16839f3a517921d00dc54715b95545db",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d7/b3fc6141bbf88d722d8cdfa401281ff2e002d7": "25c10610c051900e1550317e02749a0d",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/df/5fe905ae09d811522151a19bcb37011ea4ef67": "58e7014a93abe0a5bad5349ee2e69bce",
".git/objects/e5/02c59ad4e4276c7e1adf67137e8bd96e7f2098": "026181a1bfa1e1b0cb3800d6d6868207",
".git/objects/e5/e07c085302eee21dd5bf27a9cad2cd16120036": "57883ea66e11736f4ef682da9ebc1375",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f5/80e740f545839320c69eb8575870377c35426a": "75837f32b64c6c7f15e321ff5950a8f8",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/f7/e5e2eb4450fbcb56b2fab6aff57bf5287cddea": "833773515da8e1a1893437c295d6de08",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/refs/heads/gh-pages": "e11534e232f5bd2443c815a1f84d63ee",
".git/refs/heads/main": "e11534e232f5bd2443c815a1f84d63ee",
".git/refs/remotes/origin/gh-pages": "e11534e232f5bd2443c815a1f84d63ee",
"assets/AssetManifest.bin": "e0722d8e13cefb5a0814a677e6f06f57",
"assets/AssetManifest.bin.json": "166decb7613ad0d18528ca7a021a7851",
"assets/assets/icon/app_icon.png": "f605b9e553268f1aa0d2bd39fdec2c64",
"assets/assets/puzzles/easy_pack.json": "8c167886e8e6b821568b1651bd978763",
"assets/assets/puzzles/hard_pack.json": "0a6acc2211931da537945208f4a77e0f",
"assets/assets/puzzles/medium_pack.json": "b82bb854890542f60ab1517d326e436f",
"assets/assets/splash/splash_branding.png": "6fb926c010f78a9cb9c564419535d9fe",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "1454885bbc57187725b5ed01857b2ed9",
"assets/NOTICES": "d36c7831040d3172623071a5d3e71faf",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "6e5d54711dd4ee48cf696e127dba1143",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "d27fc77e5e2cd9d1ea40948e95938bee",
"icons/Icon-192.png": "1d76b4db137d45c03f6cf91b49734db9",
"icons/Icon-512.png": "08de5fd3b64cbb5056ca17638a90ab2b",
"icons/Icon-maskable-192.png": "1d76b4db137d45c03f6cf91b49734db9",
"icons/Icon-maskable-512.png": "08de5fd3b64cbb5056ca17638a90ab2b",
"index.html": "38b92bd2089f9f3fb1912c588762bb76",
"/": "38b92bd2089f9f3fb1912c588762bb76",
"main.dart.js": "b38033ee4bbee8a4640375e7efae2bb1",
"manifest.json": "b35a6eb6d7e9082a4e6e39f33484637a",
"version.json": "8c637d868f1f76cd3120c28c889fe093"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
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
