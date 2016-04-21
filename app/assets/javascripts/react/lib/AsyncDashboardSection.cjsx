# Proof of Concept: AsyncView - only works for my/dashboard!

React = require('react')
PropTypes = React.PropTypes
ReactDOM = require('react-dom')
f = require('active-lodash')
xhr = require('xhr')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
UILibrary = {
  UI: require('../ui-components/index.coffee'),
  Deco: require('../decorators/index.coffee')
} # only used to get components by name

Preloader = require('../ui-components/Preloader.cjsx')

module.exports = React.createClass
  displayName: 'AsyncDashboardSection'
  propTypes:
    url: PropTypes.string.isRequired
    component: PropTypes.string.isRequired
    json_path: PropTypes.string
    initial_props: PropTypes.object

  getInitialState: ()-> { isClient: false, fetchedProps: null }

  componentDidMount: ()->
    @setState(isClient: true)
    @_getPropsAsync((props)=> @setState(fetchedProps: props))

  _getPropsAsync: (callback)->
    xhr({url: @props.url, json: true}, (err, res, data)=>
      # this mirros what the react ui_helper does in Rails:
      props = @props.initial_props
      props.get = if @props.json_path then f.get(data, @props.json_path) else data
      props.authToken = getRailsCSRFToken()
      callback(props))

  render: ()->
    UIComponent = f.get(UILibrary, @props.component)
    <div className='ui_async-view'>
      {if !@state.isClient or !f.present(@state.fetchedProps)
        <div style={{height: '250px'}}>
          <div className='pvh mtm'><Preloader/></div>
        </div>
      else if UIComponent
        React.createElement(UIComponent, @state.fetchedProps)
      }
    </div>
