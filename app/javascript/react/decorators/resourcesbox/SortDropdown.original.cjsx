React = require('react')
f = require('active-lodash')
cx = require('classnames')
Dropdown = require('../../ui-components/Dropdown.cjsx')
MenuItem = Dropdown.MenuItem

module.exports = React.createClass
  displayName: 'SortDropdown'

  _onItemClick: (event, itemKey) ->
    # event.preventDefault()
    @props.onItemClick(event, itemKey) if @props.onItemClick

  render: () ->

    selectedKey = @props.selectedKey
    selectedItem = f.find(@props.items, {key: selectedKey})
    unless selectedItem
      selectedKey = @props.items[0].key
      selectedItem = f.find(@props.items, {key: selectedKey})

    <Dropdown mods='stick-right' toggle={selectedItem.label}>

      <Dropdown.Menu className='ui-drop-menu'>
        {
          f.map @props.items, (item) =>
            return if item.key == selectedKey
            <MenuItem key={item.key} onClick={(event) => @_onItemClick(event, item.key)} href={item.href}>
              {item.label}
            </MenuItem>
        }
      </Dropdown.Menu>
    </Dropdown>
