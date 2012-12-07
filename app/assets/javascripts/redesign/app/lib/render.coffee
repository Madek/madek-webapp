###

App.render

This script sets the default path for view templates

###
window.App.render = (template, data, options)=>
  $.tmpl "#{App.default_render_path}#{template}", data, options

window.App.renderPath = (template)=>
  "#{App.default_render_path}#{template}"