React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')
parseMods = ui.parseMods
cx = ui.classnames
UiPropTypes = require('./propTypes.coffee')

Button = require('./Button.cjsx')
ButtonGroup = require('./ButtonGroup.cjsx')
Icon = require('./Icon.cjsx')
Link = require('./Link.cjsx')

module.exports = React.createClass
  displayName: 'FilterBar'
  propTypes:
    filter: React.PropTypes.shape
      toggle: UiPropTypes.Clickable
      reset: React.PropTypes.node
    toggles: React.PropTypes.arrayOf(UiPropTypes.Clickable)
    select: UiPropTypes.Toggleable

  render: ({filter, toggles, select} = @props)->
    classes = cx('ui-container separated', parseMods(@props), 'ui-filterbar')

    filterReset = filter.reset

    filterToggle = if filter.toggle
      <Button {...filter.toggle}>
        <Icon i='filter' mods='small'/> {filter.toggle.name}
      </Button>

    toggleButtons = if toggles
      <ToggleButtonGroup actions={toggles}/>

    selectionMenu = if select
      <SelectionToggle select={select}/>

    # set grid size for last section
    lastColClass = cx 'by-right',
      'col4of6': !toggleButtons,
      'col2of6': toggleButtons

    <div className={classes}>
      <div className='col2of6 left'>{filterToggle} {filterReset}</div>
      <div className='col2of6 by-center'>{toggleButtons}</div>
      <div className={lastColClass}>{selectionMenu}</div>
    </div>

ToggleButtonGroup = ({actions} = @props)->
  return unless f.present(actions)
  <ButtonGroup>
    {actions.map (btn)->
      <Button {...btn} key={btn.name}
        mods={if btn.isActive then 'active'}>{btn.name}</Button>}
  </ButtonGroup>

SelectionToggle = ({select} = @props)->
  labelText = if select.isActive then select.active else select.inactive
  selectClass = cx('weak', parseMods(select), 'ui-filterbar-select')
  checkboxMods = cx({'active': select.isActive, 'mid': select.isDirty})

  <div>
    <label className={selectClass} {...select}>
      <span className='js-only'>
        <span>{labelText} </span>
        <Icon i='checkbox' mods={checkboxMods}/>
      </span>
    </label>
  </div>
