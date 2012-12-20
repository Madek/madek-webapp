####### VENDOR

#= require html5shiv/html5shiv

#= require jquery/jquery.min
#= require jquery.inview/jquery.inview
#= require jquery-ui/jquery-ui.custom
#= require jquery_ujs
#= require jquery-tmpl
#= require mousewheel/jquery.mousewheel

#= require bootstrap/bootstrap-transition
#= require bootstrap/bootstrap-modal
#= require bootstrap/bootstrap-dropdown
#= require bootstrap/bootstrap-tab
#= require bootstrap/bootstrap-tooltip
#= require bootstrap/bootstrap-popover

#= require underscore/underscore
#= require underscore.string/underscore.string
#= require moment/moment.min
 
#= require URI.js/URI.js

#= require plupload/plupload
#= require plupload/jquery.plupload.queue
#= require plupload/plupload.html5

#= require fixed-header-table/fixed-header-table

####### APPLICATION

#= require_self
#= require_tree ./lib
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

window.App = {}
App.default_render_path = "views/"
window.Underscore = _ # make underscore available in jQuery Templates
