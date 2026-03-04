// SSR bundle entry point for Vite.
// This bundle runs inside ExecJS, NOT in a browser or Node.js.
// It attaches React and the full component tree to globalThis
// so the Ruby SsrRenderer can call renderComponent().

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
