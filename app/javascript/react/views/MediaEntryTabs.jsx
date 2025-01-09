/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const cx = require('classnames')
const f = require('lodash')
const Icon = require('../ui-components/Icon.jsx')
const MediaEntryPrivacyStatusIcon = require('./MediaEntryPrivacyStatusIcon.jsx')

const parseUrl = require('url').parse

const parseUrlState = function(location) {
  const urlParts = f.slice(parseUrl(location).pathname.split('/'), 1)
  if (urlParts.length < 3) {
    return { action: 'show', argument: null }
  } else {
    return {
      action: urlParts[2],
      argument: urlParts.length > 3 ? urlParts[3] : undefined
    }
  }
}

const activeTabId = urlState => urlState.action

module.exports = React.createClass({
  displayName: 'MediaEntryTabs',

  getInitialState() {
    return {
      urlState: parseUrlState(this.props.for_url)
    }
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.for_url === this.props.for_url) {
      return
    }
    return this.setState({ urlState: parseUrlState(this.props.for_url) })
  },

  render(param, param1) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    if (param1 == null) {
      param1 = this.state
    }
    const { urlState } = param1
    const media_entry_path = get.url

    const tabs = f.fromPairs(
      f.map(get.tabs, function(tab) {
        const path = tab.href ? tab.href : media_entry_path

        const icon =
          tab.icon_type === 'privacy_status_icon' ? (
            <MediaEntryPrivacyStatusIcon get={get} />
          ) : (
            undefined
          )

        return [path, f.merge(tab, { icon })]
      })
    )

    return (
      <ul className="ui-tabs large">
        {f.map(tabs, function(tab, path) {
          const active = tab.id === activeTabId(urlState)

          const classes = cx('ui-tabs-item', { active: active })

          return (
            <li key={tab.id} className={classes}>
              <a href={path}>
                {tab.icon}
                {` ${tab.title} `}
              </a>
            </li>
          )
        })}
      </ul>
    )
  }
})
