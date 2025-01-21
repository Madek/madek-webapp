/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'

module.exports = createReactClass({
  displayName: 'ToggableLink',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { active } = param
    const restProps = f.omit(this.props, ['active'])
    const onClick = active ? this.props.onClick : null

    let style = active ? {} : { pointerEvents: 'none', cursor: 'default' }
    style = f.merge(this.props.style, style)

    return (
      <a {...Object.assign({}, restProps, { onClick: onClick, style: style })}>
        {this.props.children}
      </a>
    )
  }
})
