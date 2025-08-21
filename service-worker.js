// Hundreds Workout Tracker - Service Worker
const CACHE_NAME = 'hundreds-v1.0.0';
const urlsToCache = [
  './',
  './index.html',
  './styles.css',
  './script.js',
  './manifest.json'
];

// Install event - cache resources
self.addEventListener('install', (event) => {
  console.log('Service Worker: Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Service Worker: Caching files');
        return cache.addAll(urlsToCache);
      })
      .then(() => {
        console.log('Service Worker: Installation complete');
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('Service Worker: Installation failed', error);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('Service Worker: Activating...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Deleting old cache', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('Service Worker: Activation complete');
      return self.clients.claim();
    })
  );
});

// Fetch event - serve cached content when offline
self.addEventListener('fetch', (event) => {
  // Only handle GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  // Skip cross-origin requests
  if (!event.request.url.startsWith(self.location.origin)) {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version if available
        if (response) {
          console.log('Service Worker: Serving from cache', event.request.url);
          return response;
        }

        // Otherwise, fetch from network
        console.log('Service Worker: Fetching from network', event.request.url);
        return fetch(event.request).then((response) => {
          // Don't cache if not a valid response
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response;
          }

          // Clone the response
          const responseToCache = response.clone();

          // Add to cache for future use
          caches.open(CACHE_NAME)
            .then((cache) => {
              cache.put(event.request, responseToCache);
            });

          return response;
        }).catch((error) => {
          console.error('Service Worker: Fetch failed', error);
          
          // Return offline page for navigation requests
          if (event.request.destination === 'document') {
            return caches.match('./index.html');
          }
          
          // For other requests, just fail
          throw error;
        });
      })
  );
});

// Background sync for data persistence (if supported)
self.addEventListener('sync', (event) => {
  console.log('Service Worker: Background sync triggered', event.tag);
  
  if (event.tag === 'workout-data-sync') {
    event.waitUntil(
      // This would sync data with a server if we had one
      // For now, we just ensure localStorage is working
      Promise.resolve()
    );
  }
});

// Push notifications (for future enhancement)
self.addEventListener('push', (event) => {
  console.log('Service Worker: Push message received', event);
  
  const options = {
    body: event.data ? event.data.text() : 'Time for your workout! 💪',
    icon: './manifest.json', // Would use actual icon in production
    badge: './manifest.json', // Would use actual badge in production
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'open',
        title: 'Open App',
        icon: './manifest.json'
      },
      {
        action: 'close',
        title: 'Close',
        icon: './manifest.json'
      }
    ]
  };

  event.waitUntil(
    self.registration.showNotification('Hundreds Workout', options)
  );
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  console.log('Service Worker: Notification clicked', event);
  
  event.notification.close();

  if (event.action === 'open') {
    event.waitUntil(
      clients.openWindow('./')
    );
  }
});

// Handle app installation prompt
self.addEventListener('beforeinstallprompt', (event) => {
  console.log('Service Worker: Before install prompt');
  // This would be handled by the main app
});

// Handle app installation
self.addEventListener('appinstalled', (event) => {
  console.log('Service Worker: App installed');
});

// Periodic background sync (if supported)
self.addEventListener('periodicsync', (event) => {
  console.log('Service Worker: Periodic sync triggered', event.tag);
  
  if (event.tag === 'workout-reminder') {
    event.waitUntil(
      // Could check if user hasn't worked out today and send reminder
      Promise.resolve()
    );
  }
});

// Handle messages from main thread
self.addEventListener('message', (event) => {
  console.log('Service Worker: Message received', event.data);
  
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage({ version: CACHE_NAME });
  }
  
  if (event.data && event.data.type === 'CLEAR_CACHE') {
    event.waitUntil(
      caches.delete(CACHE_NAME).then(() => {
        event.ports[0].postMessage({ success: true });
      })
    );
  }
});

// Error handling
self.addEventListener('error', (event) => {
  console.error('Service Worker: Error occurred', event.error);
});

self.addEventListener('unhandledrejection', (event) => {
  console.error('Service Worker: Unhandled promise rejection', event.reason);
});

// Utility functions for cache management
async function cleanupOldCaches() {
  const cacheNames = await caches.keys();
  const oldCaches = cacheNames.filter(name => name !== CACHE_NAME);
  
  return Promise.all(
    oldCaches.map(name => caches.delete(name))
  );
}

async function updateCache() {
  const cache = await caches.open(CACHE_NAME);
  return cache.addAll(urlsToCache);
}

// Export utility functions for testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    CACHE_NAME,
    urlsToCache,
    cleanupOldCaches,
    updateCache
  };
}