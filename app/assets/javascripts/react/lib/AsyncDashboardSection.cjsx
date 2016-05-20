# Proof of Concept: AsyncView - only works for my/dashboard!

React = require('react')
PropTypes = React.PropTypes
ReactDOM = require('react-dom')
f = require('active-lodash')
xhr = require('xhr')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')

# HACK: get components by name. only 1 is supported for now.
UILibrary =
  Deco:
    MediaResourcesBox: require('../decorators/MediaResourcesBox.cjsx')

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
    @setState(isClient: true, fetching: true)
    @_getPropsAsync((err, props)=>
      @setState(fetching: false)
      if err
        console.error('Error while fetching data!\n\n', err)
        @setState(fetchError: err)
      else
        @setState(fetchedProps: props))

  _getPropsAsync: (callback)->
    xhr({url: @props.url, json: true}, (err, res, data)=>
      if err or res.statusCode >= 400
        return callback(err or data)
      # this mirros what the react ui_helper does in Rails:
      props = @props.initial_props
      props.get = if @props.json_path then f.get(data, @props.json_path) else data
      props.authToken = getRailsCSRFToken()
      callback(null, props))

  render: ()->
    unless (UIComponent = f.get(UILibrary, @props.component))
      throw new Error('Invalid UI Component! ' + @props.component)

    errorMessage =

    <div className='ui_async-view'>
      {if !@state.isClient or @state.fetching
        <div style={{height: '250px'}}>
          <div className='pvh mtm'><Preloader/></div>
        </div>
      else if f.present(@state.fetchedProps)
        React.createElement(UIComponent, @state.fetchedProps)
      else
        <div style={{height: '250px'}}>
          <div className='pvh mth mbl'>
            <div className='title-l by-center'>Error!</div></div>
        </div>
      }
    </div>
