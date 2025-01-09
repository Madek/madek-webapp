/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')

module.exports = React.createClass({
  displayName: 'ToggableLink',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { active } = param
    const restProps = f.omit(this.props, ['active'])
    const onClick = active ? this.props.onClick : null
    const href = active ? this.props.href : null

    let style = active ? {} : { pointerEvents: 'none', cursor: 'default' }
    style = f.merge(this.props.style, style)

    return (
      <a {...Object.assign({}, restProps, { onClick: onClick, style: style })}>
        {this.props.children}
      </a>
    )
  }
})
