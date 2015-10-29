// this file is NOT used in the webapp! server-side rendering only!
//
// use React from npm, not gem (also disabled in gem config)
var React = require('react')
var ReactDOMServer = require('react-dom/server')
var ReactDOM = require('react-dom')
var UI = require('./react/index.coffee')

// the server-side renderer expects all components attached to `global`:
global.React = React
global.ReactDOMServer = ReactDOMServer
global.ReactDOM = ReactDOM
global.UI = UI
