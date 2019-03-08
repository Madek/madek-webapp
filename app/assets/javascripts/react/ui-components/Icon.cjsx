# A single icon (from styleguide) by name

React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')

# TODO: list of all supported icons.
# For now, only the list of 'fontawesome' icons to differentiate:
FONT_AWESOME_ICONS = [
  'cloud',
  'clock-o'
]

module.exports = React.createClass
  displayName: 'Icon'
  propTypes:
    i: React.PropTypes.string.isRequired

  render: ({i} = @props)->
    restProps = f.omit(@props, ['i', 'mods'])
    iconClass = if f.includes(FONT_AWESOME_ICONS, i)
      "fa fa-#{i}"
    else
      "icon-#{i}"
    classes = ui.cx(ui.parseMods(@props), iconClass)

    <i {...restProps} className={classes}/>
