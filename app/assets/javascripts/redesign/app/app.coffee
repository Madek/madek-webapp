#= require jquery-tmpl
#= require ./../vendor/underscore-1.3.3/underscore
#= require ./../vendor/underscore.string-2.1.1/underscore.string
#= require ./../vendor/moment-1.4.0/moment.min
#= require ./../vendor/jquery.inview/jquery.inview
#= require ./../vendor/jquery-ui-1.9.2.position/jquery-ui-1.9.2.position
#= require ./../vendor/URI.js.1.8.1/URI.js
#
#= require_self
#= require_directory ./lib
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

window.App = {}
App.default_render_path = "redesign/app/views/"
window.Underscore = _ # make underscore available in jQuery Templates
