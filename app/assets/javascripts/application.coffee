#= depend_on 'translations.csv'
#= depend_on_asset 'translations.csv'
# NOTE: ↑ needed so that sprocket knows to recompile js if translations changed,
#         and to make the csv part of the asset manifest.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# global jquery. needed for jquery plugins.
window.jQuery = window.$ = require('jquery')

# local requires
each = require('active-lodash').each
present = require('active-lodash').present


# setup APP ############################################################
# "global" singleton (returns same object no matter where it's required)
app = require('ampersand-app')
# validate and set the "global" config - see frontend_app_config.rb
throw new Error 'No `APP_CONFIG`!' unless present(APP_CONFIG)
app.extend({
  config: require('global').APP_CONFIG
})

# init UJS #############################################################

# already in global boostrap:
# - tabs

# our library:
ujs = [
  require('./ujs/hashviz.coffee'),
  require('./ujs/react.coffee')
]

# initialize them all when DOM is ready:
$(document).ready -> each ujs, (init)-> do init

# DEV:
# require('./developer-tools.coffee')
