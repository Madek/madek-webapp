const global = require('global')

global.$ = require('jquery')
global.f = require('active-lodash')
global.React = require('react')
global.ReactDOM = require('react-dom')

global.App = {
  UI: require('./react/index.js'),
  Models: require('./models/index.js'),
  t: require('./lib/i18n-translate.js')
}

global.UI = global.App.UI
global.Models = global.App.Models
