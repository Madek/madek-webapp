global = require('global')

global.$ = require('jquery')
global.f = require('active-lodash')
global.React = require('react')
global.ReactDOM = require('react-dom')

global.App =
  UI: require('./react/index.coffee')
  Models: require('./models/index.coffee')
  t: require('./lib/string-translation.js')('en')

global.UI = App.UI
global.Models = App.Models
