/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const ampersandReactMixin = require('ampersand-react-mixin')
const f = require('active-lodash')
const t = require('../../../lib/i18n-translate.js')
const RailsForm = require('../../lib/forms/rails-form.cjsx')
const FormButton = require('../../ui-components/FormButton.cjsx')
const ToggableLink = require('../../ui-components/ToggableLink.cjsx')
const Modal = require('../../ui-components/Modal.cjsx')
const xhr = require('xhr')
const formXhr = require('../../../lib/form-xhr.js')
const loadXhr = require('../../../lib/load-xhr.js')
const Preloader = require('../../ui-components/Preloader.cjsx')
const Button = require('../../ui-components/Button.cjsx')
const Icon = require('../../ui-components/Icon.cjsx')

module.exports = React.createClass({
  displayName: 'SelectCollectionDialog',

  _onCancel(event) {
    if (this.props.onCancel) {
      event.preventDefault()
      this.props.onCancel()
      return false
    } else {
      return true
    }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const {
      children,
      onCancel,
      cancelUrl,
      title,
      toolbar,
      action,
      authToken,
      content,
      method,
      showSave
    } = param
    return (
      <div>
        <SelectCollectionHeader onCancel={this._onCancel} cancelUrl={cancelUrl} title={title} />
        <SelectCollectionToolbar>{toolbar}</SelectCollectionToolbar>
        <SelectCollectionForm
          showAddToClipboard={this.props.showAddToClipboard}
          action={action}
          authToken={authToken}
          cancelUrl={cancelUrl}
          onCancel={this._onCancel}
          method={method}
          showSave={showSave}>
          <SelectCollectionBody>{content}</SelectCollectionBody>
        </SelectCollectionForm>
      </div>
    )
  }
})

var SelectCollectionHeader = React.createClass({
  displayName: 'SelectCollectionHeader',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { cancelUrl, title, onCancel } = param
    return (
      <div className="ui-modal-head">
        <a
          href={cancelUrl}
          aria-hidden="true"
          className="ui-modal-close"
          data-dismiss="modal"
          title="Close"
          type="button"
          style={{ position: 'static', float: 'right', paddingTop: '5px' }}
          onClick={onCancel}>
          <i className="icon-close" />
        </a>
        <h3 className="title-l">{title}</h3>
      </div>
    )
  }
})

const SelectCollectionFooter = React.createClass({
  displayName: 'SelectCollectionFooter',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { cancelUrl, onCancel, showSave } = param
    const className = showSave ? 'line weak' : 'primary-button'
    return (
      <div className="ui-modal-footer body-lower-limit">
        {this.props.showAddToClipboard ? (
          <div>
            <div style={{ textAlign: 'center', paddingTop: '0px', paddingBottom: '10px' }}>
              <input type="checkbox" name="add_to_clipboard" />
              {t('clipboard_add_hint')}
            </div>
            <hr className="separator" style={{ marginBottom: '20px' }} />
          </div>
        ) : (
          undefined
        )}
        <div className="ui-actions">
          <a href={cancelUrl} className={className} onClick={onCancel}>
            {t('resource_select_collection_cancel')}
          </a>
          {showSave ? (
            <Button className="primary-button" type="submit">
              {t('resource_select_collection_save')}
            </Button>
          ) : (
            undefined
          )}
        </div>
      </div>
    )
  }
})

var SelectCollectionBody = React.createClass({
  displayName: 'SelectCollectionBody',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { children } = param
    return (
      <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
        {children}
      </div>
    )
  }
})

var SelectCollectionForm = React.createClass({
  displayName: 'SelectCollectionForm',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { children, action, authToken, cancelUrl, onCancel, method, showSave } = param
    return (
      <RailsForm
        name="select_collections"
        action={action}
        method={method}
        authToken={authToken}
        className="dummy"
        className="save-arcs">
        {children}
        <SelectCollectionFooter
          showAddToClipboard={this.props.showAddToClipboard}
          cancelUrl={cancelUrl}
          onCancel={onCancel}
          showSave={showSave}
        />
      </RailsForm>
    )
  }
})

var SelectCollectionToolbar = React.createClass({
  displayName: 'SelectCollectionToolbar',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { children } = param
    return <div className="ui-modal-toolbar top">{children}</div>
  }
})
