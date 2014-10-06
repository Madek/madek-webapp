####### VENDOR

#= require html5shiv/html5shiv

#= require jquery/jquery-1.11.1
#= require jquery/jquery-migrate-1.2.1.min
#= require jquery.inview/jquery.inview
#= require jquery-ui/jquery-ui.custom
#= require jquery_ujs
#= require jquery-tmpl
#= require mousewheel/jquery.mousewheel

#= require bootstrap32/transition
#= require bootstrap32/modal
#= require bootstrap32/dropdown
#= require bootstrap32/tab
#= require bootstrap32/tooltip
#= require bootstrap32/popover

#= require underscore/underscore
#= require underscore.string/underscore.string
#= require moment/moment.min
 
#= require URI.js/URI.js

#= require fixed-header-table/fixed-header-table

#= require progressive
#= require jed/jed
#= require i18n/i18n

####### APPLICATION

#= require_self
#= require_tree ./lib
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

#= require vocabulary

window.App = {}
App.default_render_path = "views/"
window.Underscore = _ # make underscore available in jQuery Templates
