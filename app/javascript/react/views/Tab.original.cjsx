React = require('react')
ReactDOM = require('react-dom')
classnames = require('classnames')

module.exports = React.createClass
  displayName: 'Tab'
  render: ({privacyStatus, label, href, iconType, active} = @props) ->
    classes = classnames({ active: active}, 'ui-tabs-item')
    icon = if iconType == 'privacy_status_icon'
      if privacyStatus
        icon_map = {
          public: 'open',
          shared: 'group',
          private: 'private'
        }
        <i className={'icon-privacy-' + icon_map[privacyStatus]}/>

    <li className={classes} data-test-id={@props.testId}>
      <a href={href} onClick={@props.onClick}>
        {if icon
          <span>{icon} {label}</span>
        else
          label
        }
      </a>
    </li>
