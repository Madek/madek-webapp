/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const RailsForm = require('../lib/forms/rails-form.jsx')

module.exports = React.createClass({
  displayName: 'HeaderButton',

  _onClick(event) {
    event.preventDefault()
    if (this.props.onClick) {
      this.props.onClick(event)
    }
    return false
  },

  render(param) {
    let authToken, fa, href, method, name, onClick, title
    let icon
    if (param == null) {
      param = this.props
    }
    ;({ authToken, href, method, icon, fa, title, name } = param)
    if (!method) {
      method = 'post'
    }
    if (this.props.onClick) {
      onClick = this._onClick
    }
    return (
      <RailsForm className="button_to" name="" method={method} action={href} authToken={authToken}>
        <button className="button" type="submit" title={title} onClick={onClick}>
          {(() => {
            if (icon) {
              icon = `icon-${icon}`
              return <i className={icon} />
            } else if (fa) {
              return <span className={fa} />
            }
          })()}
        </button>
        {this.props.children}
      </RailsForm>
    )
  }
})
