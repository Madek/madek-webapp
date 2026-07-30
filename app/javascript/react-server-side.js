//= depend_on 'translations.csv'
//= depend_on_asset 'translations.csv'
// NOTE: ↑ needed so that sprocket knows to recompile js if translations changed,
//         and to make the csv part of the asset manifest.
//
// // // // // // // // // // // // // // // // // // // // // // // // // // // //

// this file is NOT used in the webapp! server-side rendering only!
//
// use React from npm, not gem (also disabled in gem config)
import React from 'react'
import ReactDOMServer from 'react-dom/server'
import ReactDOM from 'react-dom'
import * as UI from './react/index.js'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

// Wrap every component in the UI namespace with a fresh QueryClientProvider
// so that hooks like useMutation work during server-side rendering.
function wrapWithQueryProvider(obj) {
  if (typeof obj === 'function') {
    var Inner = obj
    return function WrappedWithQuery(props) {
      var queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
      return React.createElement(
        QueryClientProvider,
        { client: queryClient },
        React.createElement(Inner, props)
      )
    }
  }
  if (obj && typeof obj === 'object' && !Array.isArray(obj)) {
    var wrapped = {}
    Object.keys(obj).forEach(function (key) {
      wrapped[key] = wrapWithQueryProvider(obj[key])
    })
    return wrapped
  }
  return obj
}

// the server-side renderer expects all components attached to `global`:
global.React = React
global.ReactDOMServer = ReactDOMServer
global.ReactDOM = ReactDOM
global.UI = wrapWithQueryProvider(UI)
