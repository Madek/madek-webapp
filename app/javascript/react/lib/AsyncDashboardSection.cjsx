# Proof of Concept: AsyncView - only works for my/dashboard!
# Tries to fetch the props needed to display the component before rendering it.
# If it fails, a retry icon is shown, with a fallback link
# If fetching is retryed 5 times only use fallback link (sync, for browser error)

React = require('react')
PropTypes = React.PropTypes
ReactDOM = require('react-dom')
f = require('active-lodash')
appRequest = require('../../lib/app-request.coffee')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')

SuperBoxDashboard = require('../decorators/SuperBoxDashboard.jsx')

Icon = require('../ui-components/Icon.cjsx')
Preloader = require('../ui-components/Preloader.cjsx')

module.exports = React.createClass
  displayName: 'AsyncDashboardSection'
  propTypes:
    url: PropTypes.string.isRequired
    json_path: PropTypes.string
    initial_props: PropTypes.object

  _isMounted: false

  getInitialState: ()-> { isClient: false, fetchedProps: null }

  componentDidMount: ()->
    @_isMounted = true
    @setState(isClient: true)
    @_fetchProps()

  _fetchProps: ()->
    @setState(fetching: true)
    @_getPropsAsync((err, props)=>
      return if !@_isMounted
      @setState(fetching: false)
      if err
        console.error('Error while fetching data!\n\n', err)
        if @props.callback
          @props.callback('error')
      else
        @setState(fetchedProps: props)
        if @props.callback
          if props.get.resources.length > 0
            @props.callback('resources')
          else
            @props.callback('empty')
    )

  _retryFetchProps: (event)->
    @_retryCount = (@_retryCount || 0) + 1
    unless @_retryCount > 5
      event.preventDefault()
      @_fetchProps()

  _getPropsAsync: (callback)->
    @_runningRequest = appRequest({url: @props.url, retries: 5}, (err, res, data) =>
      if err or res.statusCode >= 400
        return callback(err or data)
      # this mirros what the react ui_helper does in Rails:
      props = @props.initial_props
      props.get = if @props.json_path then f.get(data, @props.json_path) else data
      props.authToken = getRailsCSRFToken()
      callback(null, props))

  componentWillUnmount: ()->
    if @_runningRequest then @_runningRequest.abort()
    @_isMounted = false
    # NOTE: Self-implemented `isMounted` to suppress the React warning, but still an anti-pattern.
    # The correct solution would be @_runningRequest.abort().
    # However this does not work, because `appRequest()` returns undefined when retries are enabled.

  render: ({props} = @)->
    {fallback_url} = props

    if @props.renderEmpty
      return <div></div>

    <div className='ui_async-view'>
      {if !@state.isClient or @state.fetching
        <div style={{height: '250px'}}>
          <div className='pvh mtm'><Preloader/></div>
        </div>
      else if f.present(@state.fetchedProps)
        <SuperBoxDashboard
          authToken={@state.fetchedProps.authToken}
          resources={@state.fetchedProps.get.resources}
        />
      else
        <div style={{height: '250px'}}>
          <div className='pvh mth mbl by-center'>
            <a
              className='title-l'
              href={fallback_url}
              onClick={@_retryFetchProps}
            >
              <Icon i='undo' />
            </a>
          </div>
        </div>
      }
    </div>
