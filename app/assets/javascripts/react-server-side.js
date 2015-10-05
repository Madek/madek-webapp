// this file is NOT used in the webapp! server-side rendering only!
//
// use React from npm, not gem (also disabled in gem config)
var React = require('react')
var UI = require('./react/index.coffee')

// the server-side renderer expects all components attached to `global`:
global.React = React
global.UI = UI
