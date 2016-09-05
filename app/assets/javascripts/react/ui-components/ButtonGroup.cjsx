# ButtonGroup - give buttons as children or props.list

React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')
UiPropTypes = require('./propTypes.coffee')
Button = require('./Button.cjsx')

module.exports = React.createClass
  displayName: 'ButtonGroup'
  proptypes:
    list: React.PropTypes.arrayOf(UiPropTypes.Clickable)
    # list: React.PropTypes.arrayOf(Button.propTypes)

  render: ({list, children} = @props)->
    classes = ui.cx(ui.parseMods(@props), 'button-group')

    # build <Button/>s from given list of props
    # buttons = f(list)
    #   .map((v,k)-> f.assign(v, key: k) if f.present(v))
    #   .sortBy('position')
    #   .map((i)-> f.omit(i, 'position'))
    #   .select((i)-> f(i).omit('key').present())
    #   .map((btn)-> <Button {...btn}/>)
    #   .presence()
    #
    # return unless content = buttons or children

    return unless children

    <div className={classes}>
      {children}
    </div>
