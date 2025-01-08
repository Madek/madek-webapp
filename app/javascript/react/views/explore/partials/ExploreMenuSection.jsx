/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const cx = require('classnames')

module.exports = React.createClass({
  displayName: 'ExploreMenuSection',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { label, hrefUrl, active } = param
    return (
      <li className={cx('ui-side-navigation-item', { active: active })}>
        <a className="strong" href={hrefUrl}>
          {label}
        </a>
        {this.props.children}
      </li>
    )
  }
})
