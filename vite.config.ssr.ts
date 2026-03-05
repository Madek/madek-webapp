import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'
import { nodePolyfills } from 'vite-plugin-node-polyfills'

export default defineConfig({
  plugins: [
    react(),
    nodePolyfills({
      // Polyfill all Node.js built-ins (Option B - comprehensive approach)
      // This prevents issues with any dependency that might use Node.js APIs
      globals: {
        Buffer: true,
        global: true,
        process: true
      },
      // Exclude net and tls so our custom stubs are used instead
      // The default empty polyfill returns null, which causes errors
      exclude: ['net', 'tls']
    })
  ],
  publicDir: false, // Disable public folder copying for SSR bundle
  resolve: {
    alias: {
      '~': path.resolve(__dirname, 'app/javascript'),
      // Use jQuery stub for SSR to avoid "jQuery requires a window with a document" error
      // Real jQuery will be used in client-side builds (vite.config.mts)
      jquery: path.resolve(__dirname, 'app/javascript/lib/jquery-ssr-stub.js'),
      // Use net stub for SSR to avoid "Cannot read properties of null" errors
      // forever-agent (used by request, used by ampersand-sync) tries to use net.createConnection
      net: path.resolve(__dirname, 'app/javascript/lib/net-ssr-stub.js'),
      tls: path.resolve(__dirname, 'app/javascript/lib/net-ssr-stub.js')
    },
    // Prefer browser builds over Node.js builds for SSR in ExecJS
    // ExecJS doesn't have Node.js built-ins, so we need browser-compatible code
    conditions: ['browser', 'module', 'import', 'default']
  },
  build: {
    ssr: true,
    rollupOptions: {
      input: path.resolve(__dirname, 'app/javascript/react-server-side-vite.js'),
      output: {
        // ExecJS needs a self-contained script, NOT ESM modules.
        // IIFE wraps everything in an immediately-invoked function.
        format: 'iife',
        name: 'SSRBundle',
        // Output different filenames for dev vs production
        entryFileNames:
          process.env.NODE_ENV === 'production'
            ? 'bundle-react-server-side.js'
            : 'dev-bundle-react-server-side.js',
        // Inline everything (ExecJS can't import/require external modules)
        inlineDynamicImports: true,
        // Inject window polyfill at the very beginning of the bundle
        // This MUST run before any modules that check for window (e.g., typeahead.jquery)
        banner: `
// ============================================================================
// SSR Environment Polyfills for ExecJS
// ============================================================================
// This code runs BEFORE any modules load to ensure browser APIs are available
// when libraries check for them during initialization.

// console polyfill - ExecJS doesn't provide console but code uses console.warn/log
if (typeof console === 'undefined') {
  globalThis.console = {
    log: function() {},
    warn: function() {},
    error: function() {},
    info: function() {},
    debug: function() {}
  };
}

// IMPORTANT: Disable all timers during bundle initialization to prevent infinite loops
// React Scheduler and other code might try to schedule work during module init
// We'll re-enable them after the bundle loads
var __originalSetTimeout = globalThis.setTimeout;
var __originalSetInterval = globalThis.setInterval;
var __timerCallCount = 0;
globalThis.setTimeout = function(fn, delay) {
  __timerCallCount++;
  if (__timerCallCount > 100) {
    throw new Error('[SSR] Too many setTimeout calls during bundle init - possible infinite loop');
  }
  // Don't actually schedule anything during init
  return 0;
};
globalThis.setInterval = function(fn, delay) {
  throw new Error('[SSR] setInterval called during bundle init - this will cause infinite loops');
};

if (typeof window === 'undefined') {
  globalThis.window = {
    // typeahead.jquery checks for setImmediate and falls back to setTimeout
    setImmediate: undefined,
    // ExecJS (V8) provides these timing functions globally
    setTimeout: globalThis.setTimeout,
    clearTimeout: globalThis.clearTimeout,
    setInterval: globalThis.setInterval,
    clearInterval: globalThis.clearInterval,
    // navigator.userAgent is checked by typeahead for IE detection
    navigator: {
      userAgent: 'SSR/ExecJS'
    },
    // React Scheduler accesses window.Date
    Date: Date,
    // React Scheduler accesses window.performance (also set globally below)
    performance: undefined,  // Will be set after this block
    // APP_CONFIG is injected by Rails but needed during SSR
    // Default to empty object with sensible defaults
    APP_CONFIG: {
      userLanguage: 'en'  // Default language for SSR
    },
    // React Router's createBrowserHistory needs location and history
    location: {
      pathname: '/',
      search: '',
      hash: '',
      href: 'http://localhost/',
      origin: 'http://localhost',
      protocol: 'http:',
      host: 'localhost',
      hostname: 'localhost',
      port: ''
    },
    history: {
      pushState: function() {},
      replaceState: function() {},
      go: function() {},
      back: function() {},
      forward: function() {}
    },
    // Minimal document stub for DOM checks
    document: {
      createElement: function() {
        return {
          setAttribute: function() {},
          getAttribute: function() {},
          removeAttribute: function() {},
          appendChild: function() {},
          removeChild: function() {},
          addEventListener: function() {},
          removeEventListener: function() {},
          style: {},
          classList: {
            add: function() {},
            remove: function() {},
            contains: function() { return false; }
          }
        };
      },
      querySelector: function() { return null; },
      querySelectorAll: function() { return []; },
      getElementById: function() { return null; },
      getElementsByTagName: function() { return []; },
      getElementsByClassName: function() { return []; },
      addEventListener: function() {},
      removeEventListener: function() {},
      createTextNode: function(text) { return { nodeValue: text }; },
      body: {
        appendChild: function() {},
        removeChild: function() {}
      },
      head: {
        appendChild: function() {},
        removeChild: function() {}
      }
    }
  };
}

// Also set APP_CONFIG globally (some code accesses it directly, not via window)
if (typeof APP_CONFIG === 'undefined') {
  globalThis.APP_CONFIG = globalThis.window ? globalThis.window.APP_CONFIG : { userLanguage: 'en' };
}

// Also set DOM and browser APIs globally (some code accesses them directly)
if (typeof document === 'undefined') {
  globalThis.document = globalThis.window.document;
}
if (typeof location === 'undefined') {
  globalThis.location = globalThis.window.location;
}
if (typeof history === 'undefined') {
  globalThis.history = globalThis.window.history;
}
if (typeof navigator === 'undefined') {
  globalThis.navigator = globalThis.window.navigator;
}

// performance.now() polyfill for React Scheduler
// React's scheduler uses performance.now() for timing and expects relative timestamps
if (typeof performance === 'undefined') {
  // Store start time to return relative timestamps (not absolute)
  // React Scheduler compares timestamps and calculates deltas - absolute timestamps
  // from Date.now() (e.g., 1709628459000) can cause overflow or infinite loops
  var startTime = Date.now();
  globalThis.performance = {
    now: function() {
      // Return milliseconds since bundle initialization (relative time)
      return Date.now() - startTime;
    }
  };
  // Also add to window object for window.performance access
  if (typeof window !== 'undefined') {
    globalThis.window.performance = globalThis.performance;
  }
}

// requestAnimationFrame / cancelAnimationFrame polyfills
// React warns about these but doesn't actually need them for SSR
if (typeof requestAnimationFrame === 'undefined') {
  globalThis.requestAnimationFrame = function(callback) {
    // Use setTimeout as fallback (React's polyfill suggestion)
    return globalThis.setTimeout(callback, 16);  // ~60fps
  };
}
if (typeof cancelAnimationFrame === 'undefined') {
  globalThis.cancelAnimationFrame = function(id) {
    return globalThis.clearTimeout(id);
  };
}
// Also add to window
if (typeof window !== 'undefined') {
  globalThis.window.requestAnimationFrame = globalThis.requestAnimationFrame;
  globalThis.window.cancelAnimationFrame = globalThis.cancelAnimationFrame;
}
`
      },
      // No external modules - all Node.js built-ins are polyfilled by vite-plugin-node-polyfills
      external: []
    },
    // Don't externalize anything - ExecJS needs everything bundled
    commonjsOptions: {
      include: [/node_modules/],
      transformMixedEsModules: true
    },
    outDir: path.resolve(__dirname, 'public/assets/bundles'),
    emptyOutDir: false, // Don't delete other files in the bundles directory
    sourcemap: false // ExecJS doesn't support source maps
  },
  // Force Vite to bundle all dependencies instead of treating them as external
  ssr: {
    noExternal: true
  }
})
