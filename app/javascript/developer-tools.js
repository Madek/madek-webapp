// Developer tools - exposes key modules on window for REPL debugging

import $ from 'jquery'
import f from 'active-lodash'
import React from 'react'
import ReactDOM from 'react-dom'
import UI from './react/index.js'
import Models from './models/index.js'
import t from './lib/i18n-translate.js'

window.$ = $
window.f = f
window.React = React
window.ReactDOM = ReactDOM
window.App = { UI, Models, t }
window.UI = UI
window.Models = Models
