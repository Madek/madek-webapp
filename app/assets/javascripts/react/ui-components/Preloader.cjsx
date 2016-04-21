React = require('react')
ui = require('../lib/ui.coffee')

module.exports = React.createClass
  displayName: 'Button'
  # propTypes:
  #   mods:

  render: ({mods} = @props)->
    <div className={ui.cx(ui.parseMods(@props), 'ui-preloader')}/>
