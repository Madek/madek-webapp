React = require('react')
parseMods = require('../lib/parse-mods.coffee').fromProps
UiPropTypes = require('./propTypes.coffee')

Button = require('./Button.cjsx')
ButtonGroup = require('./ButtonGroup.cjsx')
Icon = require('./Icon.cjsx')
Link = require('./Link.cjsx')
FilterBar = require('./FilterBar.cjsx')

module.exports = React.createClass
  displayName: 'FilterBar'
  propTypes:
    filter: React.PropTypes.shape
      toggle: UiPropTypes.Clickable
      reset: UiPropTypes.Clickable
    toggles: React.PropTypes.arrayOf(UiPropTypes.Clickable)
    select: UiPropTypes.Toggleable

  render: ({filter, toggles, select} = @props)->
    classes = "ui-filterbar separated ui-container #{parseMods(@props)}"

    filterToggle = if filter.toggle
      <Button {...filter.toggle}>
        <Icon i='filter' mods='small'/> {filter.toggle.name}
      </Button>

    filterReset = if filter.reset
      <Link mods='mlx weak' {...filter.reset}>
        <Icon i='undo'/> {filter.reset.name}</Link>

    toggleButtons = if toggles
      <ButtonGroup>
        {toggles.map (btn)->
          <Button {...btn} key={btn.name}
            mods={if btn.isActive then 'active'}>{btn.name}</Button>}
      </ButtonGroup>

    selection = if select
      <label className='weak ui-filterbar-select' {...select}>
        <span>{if select.isActive then select.active else select.inactive} </span>
        <Icon i='checkbox' mods={if select.isActive then 'active'}/>
      </label>

    <div className={classes}>
      <div className='col2of6 left'>{filterToggle} {filterReset}</div>
      <div className='col2of6 by-center'>{toggleButtons}</div>
      <div className='col2of6 by-right'>{selection}</div>
    </div>
