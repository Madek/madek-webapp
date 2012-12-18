####### VENDOR

#= require html5shiv-3.6.2pre/html5shiv

#= require jquery-1.8.2/jquery-1.8.2.min
#= require jquery.inview/jquery.inview
#= require jquery-ui-1.9.2/jquery-ui-1.9.2.position
#= require jquery-ui-1.9.2/jquery-ui-1.9.2.slider
#= require jquery_ujs
#= require jquery-tmpl

#= require bootstrap-2.2.1/bootstrap-transition
#= require bootstrap-2.2.1/bootstrap-modal
#= require bootstrap-2.2.1/bootstrap-dropdown
#= require bootstrap-2.2.1/bootstrap-tab
#= require bootstrap-2.2.1/bootstrap-tooltip
#= require bootstrap-2.2.1/bootstrap-popover
#= require bootstrap-2.2.1/bootstrap-typeahead

#= require underscore-1.3.3/underscore
#= require underscore.string-2.1.1/underscore.string
#= require moment-1.4.0/moment.min
 

#= require URI.js.1.8.1/URI.js

#= require plupload-1.5.4/plupload
#= require plupload-1.5.4/jquery.plupload.queue
#= require plupload-1.5.4/plupload.html5

#= require pickadate-1.3/pickadate

#= require mousewheel-3.0.6/jquery.mousewheel

####### APPLICATION

#= require_self
#= require_tree ./lib
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

window.App = {}
App.default_render_path = "views/"
window.Underscore = _ # make underscore available in jQuery Templates
