# global jquery. needed for jquery plugins.
window.jQuery = window.$ = require('jquery')

# jquery plugins:
require('jquery-ujs')
require('bootstrap')

# local requires
each = require('lodash/collection/each')

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
