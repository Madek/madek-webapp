# A single icon (from styleguide) by name

React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')

# The following icons come from 'fontawesome' (all others from 'madek-icon-font'):
FONT_AWESOME_ICONS = [
  'cloud',
  'clock-o',
  'flask'
]
# Aliases
ICON_NAME_ALIASES = {
  'madek-workflow': 'flask'
}

module.exports = React.createClass
  displayName: 'Icon'
  propTypes:
    i: React.PropTypes.string.isRequired

  render: ({i} = @props)->
    restProps = f.omit(@props, ['i', 'mods'])
    i = ICON_NAME_ALIASES[i] || i
    iconClass = if f.includes(FONT_AWESOME_ICONS, i)
      "fa fa-#{i}"
    else
      "icon-#{i}"
    classes = ui.cx(ui.parseMods(@props), iconClass)

    <i {...restProps} className={classes}/>
