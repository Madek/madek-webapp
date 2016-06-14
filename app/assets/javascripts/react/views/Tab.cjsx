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

    <li className={classes}>
      <a href={href} onClick={@props.onClick}>
        {
          # if @props.validity == 'invalid'
          #   <i className='icon-bang' style={{color: '#d9534f', paddingTop: '7px', paddingRight: '5px'}} />
          # else if @props.validity == 'valid'
          #   <i className='icon-checkmark' style={{color: '#5cb85c', paddingTop: '7px', paddingRight: '5px'}} />
          null
        }
        {
          if @props.hasChanges and false
            <span style={{color: '#ff0000'}}>! </span>
        }
        {if icon
          <span>{icon} {label}</span>
        else
          label
        }
      </a>
    </li>
