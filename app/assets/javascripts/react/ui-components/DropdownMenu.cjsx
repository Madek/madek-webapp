# TMP: static example for layout/style testing

React = require('react')
ui = require('../lib/ui.coffee')

Icon = require('./Icon.cjsx')

module.exports = React.createClass
  displayName: 'DropdownMenu'
  # propTypes:
  #   href: React.PropTypes.string

  render: ({href, onClick, type, mod, disabled, children, className} = @props)->
    baseClass = if className then className else if mod then "#{mod}-button" else 'button'
    disabled = true if not (href or onClick or type) # force disabled if no target

    classes = ui.cx(ui.parseMods(@props), disabled: disabled, baseClass)

    <ul aria-labelledby='dLabel' className='dropdown-menu ui-drop-menu' role='menu'>
      <li className='ui-drop-item'>
        <a href='#edit'>
          <Icon i='pen' mods='mid'/> Bearbeiten</a>
        <a href='#permissions'>
          <Icon i='lock' mods='mid'/> Berechtigungen und Verantwortlichkeit</a>
      </li>

      <li className='separator'>
      </li>

      <li className='ui-drop-item'>
        <a title='Löschen'><i className='icon-trash mid'></i> Löschen</a>
      </li>

    </ul>
