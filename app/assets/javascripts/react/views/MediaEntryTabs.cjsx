React = require('react')
ReactDOM = require('react-dom')
cx = require('classnames')
f = require('lodash')
Icon = require('../ui-components/Icon.cjsx')
MediaEntryPrivacyStatusIcon = require('./MediaEntryPrivacyStatusIcon.cjsx')


parseUrl = require('url').parse



parseUrlState = (location) ->
  urlParts = f.slice(parseUrl(location).pathname.split('/'), 1)
  if urlParts.length < 3
    { action: 'show', argument: null }
  else
    {
      action: urlParts[2]
      argument: urlParts[3] if urlParts.length > 3
    }

activeTabId = (urlState) ->
  urlState.action





module.exports = React.createClass
  displayName: 'MediaEntryTabs'

  getInitialState: () -> {
    urlState: parseUrlState(@props.for_url)
  }

  componentWillReceiveProps: (nextProps)->
    return if nextProps.for_url is @props.for_url
    @setState(urlState: parseUrlState(@props.for_url))




  render: ({get} = @props, {urlState} = @state) ->

    media_entry_path = get.url

    tabs = f.fromPairs(f.map(
      get.tabs,
      (tab) ->
        path = if tab.action then media_entry_path + '/' + tab.action else media_entry_path

        icon = if tab.icon_type == 'privacy_status_icon'
          <MediaEntryPrivacyStatusIcon get={get} />

        [path, f.merge(tab, {icon: icon})]
    ))

    <ul className='ui-tabs large'>
      {
        f.map(
          tabs,
          (tab, path) ->

            active = tab.id == activeTabId(urlState)

            classes = cx('ui-tabs-item', {'active': active})

            <li key={tab.id} className={classes}>
              <a href={path}>
                {tab.icon}
                {' ' + tab.title + ' '}
              </a>
            </li>
        )
      }
    </ul>
