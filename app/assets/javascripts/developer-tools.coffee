global = require('global')

global.$ = require('jquery')
global.f = require('active-lodash')
global.React = require('react')
global.ReactDOM = require('react-dom')

global.App =
  UI: require('./react/index.coffee')
  Models: require('./models/index.coffee')
  t: require('./lib/i18n-translate.js')

global.UI = App.UI
global.Models = App.Models
