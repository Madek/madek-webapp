// SSR bundle entry point for Vite.
// This bundle runs inside ExecJS, NOT in a browser.
// It attaches React and the full component tree to globalThis
// so the Ruby SsrRenderer can call renderComponent().

import React from 'react'
import ReactDOMServer from 'react-dom/server'
import ReactDOM from 'react-dom'
import UI from './react/index.js'

// Attach to global scope for ExecJS access
globalThis.React = React
globalThis.ReactDOMServer = ReactDOMServer
globalThis.ReactDOM = ReactDOM
globalThis.UI = UI
