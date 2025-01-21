/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Wrap this around anything for bootstrap-style tooltips

import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import Tooltip from 'react-bootstrap/lib/Tooltip'
import Overlay from 'react-bootstrap/lib/Overlay'

module.exports = createReactClass({
  displayName: 'Tooltipped',
  propTypes: {
    text: PropTypes.string.isRequired,
    link: PropTypes.element,
    id: PropTypes.string.isRequired,
    children: PropTypes.node.isRequired
  },

  getInitialState() {
    return { showTooltip: false }
  },

  showTooltip() {
    if (this._timer) {
      clearTimeout(this._timer)
    }
    return this.setState({ showTooltip: true })
  },

  hideTooltip() {
    return (this._timer = setTimeout(() => this.setState({ showTooltip: false }), 30))
  },

  getTriggerEl(children) {
    const child = React.Children.toArray(children)[0]

    return React.cloneElement(child, {
      onMouseEnter: this.showTooltip,
      onMouseLeave: this.hideTooltip,
      ref: el => {
        return (this._target = el)
      }
    })
  },

  componentWillUnmount() {
    if (this._timer) {
      return clearTimeout(this._timer)
    }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { text, link, id, children } = param
    const { showTooltip } = this.state

    return (
      <span>
        {this.getTriggerEl(children)}
        <Overlay show={showTooltip} target={this._target} placement="top">
          <Tooltip id={id} onMouseEnter={this.showTooltip} onMouseLeave={this.hideTooltip}>
            {text}
            {link ? <div>({link})</div> : undefined}
          </Tooltip>
        </Overlay>
      </span>
    )
  }
})
