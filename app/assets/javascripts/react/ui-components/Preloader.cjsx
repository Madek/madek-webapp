React = require('react')
ui = require('../lib/ui.coffee')

module.exports = React.createClass
  displayName: 'Preloader'

  render: ({mods} = @props)->
    <div {...@props} className={ui.cx(ui.parseMods(@props), 'ui-preloader')}/>
