React = require('react')

module.exports = React.createClass
  displayName: 'Keyword'
  render: ({label, count, hrefUrl, hideIcon} = @props)->
    icon = <i className="icon-tag-mini ui-tag-icon"></i> unless hideIcon
    <li className="ui-tag-cloud-item">
      <a className="ui-tag-button" href={hrefUrl} title="Fotografie">
        {icon}
        {label}
        <small className="ui-tag-counter">{count}</small>
      </a>
    </li>
