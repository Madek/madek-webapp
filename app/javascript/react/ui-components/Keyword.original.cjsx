React = require('react')

module.exports = React.createClass
  displayName: 'Keyword'
  render: ({label, count, hrefUrl} = @props)->
    <li className="ui-tag-cloud-item">
      <a className="ui-tag-button" href={hrefUrl} title={label}>
        <i className="icon-tag-mini ui-tag-icon"></i>
        {label}
        <small className="ui-tag-counter">{count}</small>
      </a>
    </li>
