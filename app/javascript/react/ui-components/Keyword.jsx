/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')

module.exports = React.createClass({
  displayName: 'Keyword',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { label, count, hrefUrl } = param
    return (
      <li className="ui-tag-cloud-item">
        <a className="ui-tag-button" href={hrefUrl} title={label}>
          <i className="icon-tag-mini ui-tag-icon" />
          {label}
          <small className="ui-tag-counter">{count}</small>
        </a>
      </li>
    )
  }
})
