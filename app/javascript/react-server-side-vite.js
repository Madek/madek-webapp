// SSR bundle entry point for Vite.
// This bundle runs inside ExecJS, NOT in a browser or Node.js.
// It attaches React and the full component tree to globalThis
// so the Ruby SsrRenderer can call renderComponent().

// ============================================================================
// POLYFILLS FOR SSR ENVIRONMENT (ExecJS / V8)
// ============================================================================

// Provide minimal window object for libraries that check for browser APIs
// typeahead.jquery checks for window.setImmediate to decide async scheduling
// ExecJS doesn't have window, but does have setTimeout/clearTimeout/setInterval
if (typeof window === 'undefined') {
  globalThis.window = {
    // setImmediate is not available in ExecJS, but typeahead checks for it
    // and falls back to setTimeout (which IS available)
    setImmediate: undefined,

    // ExecJS (V8) provides these timing functions globally
    setTimeout: globalThis.setTimeout,
    clearTimeout: globalThis.clearTimeout,
    setInterval: globalThis.setInterval,
    clearInterval: globalThis.clearInterval,

    // navigator is checked by typeahead for IE detection (_.isMsie)
    // Provide minimal navigator that makes typeahead skip IE-specific code
    navigator: {
      userAgent: 'SSR/ExecJS'
    }
  }
}

// ============================================================================
// REACT & COMPONENTS
// ============================================================================

import React from 'react'
// Use browser build of ReactDOMServer to avoid Node.js stream dependencies
// ExecJS doesn't have Node.js built-ins like 'stream', so we need the browser-compatible build
import ReactDOMServer from 'react-dom/server.browser'
import ReactDOM from 'react-dom'
import UI from './react/index.js'

// Attach to global scope for ExecJS access
globalThis.React = React
globalThis.ReactDOMServer = ReactDOMServer
globalThis.ReactDOM = ReactDOM
globalThis.UI = UI
