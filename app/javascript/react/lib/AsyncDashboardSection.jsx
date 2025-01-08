/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Proof of Concept: AsyncView - only works for my/dashboard!
// Tries to fetch the props needed to display the component before rendering it.
// If it fails, a retry icon is shown, with a fallback link
// If fetching is retryed 5 times only use fallback link (sync, for browser error)

const React = require('react')
const { PropTypes } = React
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const appRequest = require('../../lib/app-request.js')
const getRailsCSRFToken = require('../../lib/rails-csrf-token.js')

const SuperBoxDashboard = require('../decorators/SuperBoxDashboard.jsx')

const Icon = require('../ui-components/Icon.jsx')
const Preloader = require('../ui-components/Preloader.jsx')

module.exports = React.createClass({
  displayName: 'AsyncDashboardSection',
  propTypes: {
    url: PropTypes.string.isRequired,
    json_path: PropTypes.string,
    initial_props: PropTypes.object
  },

  _isMounted: false,

  getInitialState() {
    return { isClient: false, fetchedProps: null }
  },

  componentDidMount() {
    this._isMounted = true
    this.setState({ isClient: true })
    return this._fetchProps()
  },

  _fetchProps() {
    this.setState({ fetching: true })
    return this._getPropsAsync((err, props) => {
      if (!this._isMounted) {
        return
      }
      this.setState({ fetching: false })
      if (err) {
        console.error('Error while fetching data!\n\n', err)
        if (this.props.callback) {
          return this.props.callback('error')
        }
      } else {
        this.setState({ fetchedProps: props })
        if (this.props.callback) {
          if (props.get.resources.length > 0) {
            return this.props.callback('resources')
          } else {
            return this.props.callback('empty')
          }
        }
      }
    })
  },

  _retryFetchProps(event) {
    this._retryCount = (this._retryCount || 0) + 1
    if (!(this._retryCount > 5)) {
      event.preventDefault()
      return this._fetchProps()
    }
  },

  _getPropsAsync(callback) {
    return (this._runningRequest = appRequest(
      { url: this.props.url, retries: 5 },
      (err, res, data) => {
        if (err || res.statusCode >= 400) {
          return callback(err || data)
        }
        // this mirros what the react ui_helper does in Rails:
        const props = this.props.initial_props
        props.get = this.props.json_path ? f.get(data, this.props.json_path) : data
        props.authToken = getRailsCSRFToken()
        return callback(null, props)
      }
    ))
  },

  componentWillUnmount() {
    if (this._runningRequest) {
      this._runningRequest.abort()
    }
    return (this._isMounted = false)
  },
  // NOTE: Self-implemented `isMounted` to suppress the React warning, but still an anti-pattern.
  // The correct solution would be @_runningRequest.abort().
  // However this does not work, because `appRequest()` returns undefined when retries are enabled.

  render(param) {
    if (param == null) {
      param = this
    }
    const { props } = param
    const { fallback_url } = props

    if (this.props.renderEmpty) {
      return <div />
    }

    return (
      <div className="ui_async-view">
        {!this.state.isClient || this.state.fetching ? (
          <div style={{ height: '250px' }}>
            <div className="pvh mtm">
              <Preloader />
            </div>
          </div>
        ) : f.present(this.state.fetchedProps) ? (
          <SuperBoxDashboard
            authToken={this.state.fetchedProps.authToken}
            resources={this.state.fetchedProps.get.resources}
          />
        ) : (
          <div style={{ height: '250px' }}>
            <div className="pvh mth mbl by-center">
              <a className="title-l" href={fallback_url} onClick={this._retryFetchProps}>
                <Icon i="undo" />
              </a>
            </div>
          </div>
        )}
      </div>
    )
  }
})
