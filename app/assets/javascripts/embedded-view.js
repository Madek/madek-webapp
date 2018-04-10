/* global APP_CONFIG */
require('./env')

//= depend_on 'translations.csv'
//= depend_on_asset 'translations.csv'
// # NOTE: ↑ needed so that sprocket knows to recompile js if translations changed,
// #         and to make the csv part of the asset manifest.
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

// local requires
const present = require('active-lodash').present
const React = require('react')
const ReactDOM = require('react-dom')
const MediaEntryEmbedded = require('./react/views/MediaEntry/MediaEntryEmbedded.jsx')

// see: `frontend_app_config.rb`
if (!present(APP_CONFIG)) throw new Error('No `APP_CONFIG`!')
const app = require('ampersand-app')
app.extend({ config: require('global').APP_CONFIG })

function main() {
  const element = document.querySelector(
    '[data-react-class="UI.Views.MediaEntry.MediaEntryEmbedded"]'
  )
  const props = JSON.parse(element.dataset.reactProps)
  const view = React.createElement(MediaEntryEmbedded, props)
  ReactDOM.render(view, element)
}

// init
main()
