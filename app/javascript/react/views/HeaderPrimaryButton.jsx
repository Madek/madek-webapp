/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')

module.exports = React.createClass({
  displayName: 'HeaderPrimaryButton',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { href, text, icon, onClick } = param
    return (
      <a className="button-primary primary-button" href={href} onClick={onClick}>
        {icon ? (
          <span>
            <i className={`icon-${icon}`} />{' '}
          </span>
        ) : (
          undefined
        )}
        {text}
      </a>
    )
  }
})
