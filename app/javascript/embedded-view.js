//= depend_on 'translations.csv'
//= depend_on_asset 'translations.csv'
// # NOTE: ↑ needed so that sprocket knows to recompile js if translations changed,
// #         and to make the csv part of the asset manifest.
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

// local requires
const { present } = require('./lib/present.js')
const React = require('react')
const ReactDOM = require('react-dom')
const { QueryClientProvider } = require('@tanstack/react-query')
const queryClient = require('./lib/query-client.js').default
const MediaEntryEmbedded = require('./react/views/MediaEntry/MediaEntryEmbedded.jsx').default

// see: `frontend_app_config.rb`
if (!present(APP_CONFIG)) throw new Error('No `APP_CONFIG`!')

function main() {
  const rootEl = document.querySelector(
    '[data-react-class="UI.Views.MediaEntry.MediaEntryEmbedded"]'
  )
  if (!rootEl || !rootEl.dataset || !rootEl.dataset.reactProps) return false
  const props = JSON.parse(rootEl.dataset.reactProps)
  const view = React.createElement(
    QueryClientProvider,
    { client: queryClient },
    React.createElement(MediaEntryEmbedded, props)
  )
  ReactDOM.render(view, rootEl)
}

// init
main()
