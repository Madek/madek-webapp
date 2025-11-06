import React from 'react'
import t from '../../../lib/i18n-translate.js'
import RailsForm from '../../lib/forms/rails-form.jsx'
import Button from '../../ui-components/Button.jsx'

class SelectCollectionDialog extends React.Component {
  _onCancel = event => {
    if (this.props.onCancel) {
      event.preventDefault()
      this.props.onCancel()
      return false
    } else {
      return true
    }
  }

  render() {
    const { cancelUrl, title, toolbar, action, authToken, content, method, showSave } = this.props
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
}

class SelectCollectionHeader extends React.Component {
  render() {
    const { cancelUrl, title, onCancel } = this.props
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
}

class SelectCollectionFooter extends React.Component {
  render() {
    const { cancelUrl, onCancel, showSave } = this.props
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
        ) : undefined}
        <div className="ui-actions">
          <a href={cancelUrl} className={className} onClick={onCancel}>
            {t('resource_select_collection_cancel')}
          </a>
          {showSave ? (
            <Button className="primary-button" type="submit">
              {t('resource_select_collection_save')}
            </Button>
          ) : undefined}
        </div>
      </div>
    )
  }
}

class SelectCollectionBody extends React.Component {
  render() {
    const { children } = this.props
    return (
      <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
        {children}
      </div>
    )
  }
}

class SelectCollectionForm extends React.Component {
  render() {
    const { children, action, authToken, cancelUrl, onCancel, method, showSave } = this.props
    return (
      <RailsForm
        name="select_collections"
        action={action}
        method={method}
        authToken={authToken}
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
}

class SelectCollectionToolbar extends React.Component {
  render() {
    const { children } = this.props
    return <div className="ui-modal-toolbar top">{children}</div>
  }
}

export default SelectCollectionDialog
