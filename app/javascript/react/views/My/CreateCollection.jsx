/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import t from '../../../lib/i18n-translate.js'
import RailsForm from '../../lib/forms/rails-form.jsx'
import InputFieldText from '../../lib/forms/input-field-text.jsx'
import FormButton from '../../ui-components/FormButton.jsx'
import ToggableLink from '../../ui-components/ToggableLink.jsx'
import formXhr from '../../../lib/form-xhr.js'
import Preloader from '../../ui-components/Preloader.jsx'

module.exports = createReactClass({
  displayName: 'CreateCollection',

  getInitialState() {
    return {
      mounted: false,
      saving: false,
      errors: null
    }
  },

  _onCancel(event) {
    event.preventDefault()
    if (this.props.onClose) {
      this.props.onClose()
    }
    return false
  },

  _onOk(event) {
    event.preventDefault()
    this.setState({ saving: true, error: null })

    formXhr(
      {
        method: 'POST',
        url: this.props.get.submit_url,
        form: this.refs.form
      },
      (result, json) => {
        if (!this.isMounted()) {
          return
        }
        if (result === 'failure') {
          this.setState({ saving: false })
          if (json.headers.length > 0) {
            return this.setState({ error: json.headers[0] })
          } else if (json.fields.title_mandatory) {
            return this.setState({ error: json.fields.title_mandatory })
          } else {
            return this.setState({ error: 'Unknown error.' })
          }
        } else {
          if (this.props.onClose) {
            this.props.onClose()
          }
          const forward_url = json['forward_url']
          return (window.location = forward_url)
        }
      }
    )

    return false
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    const error = this.state.error || get.error

    const alerts = error ? (
      <div className="ui-alerts" key="alerts">
        <p className="ui-alert error">{error}</p>
      </div>
    ) : undefined

    return (
      <RailsForm
        ref="form"
        name="resource_meta_data"
        action={get.submit_url}
        method="post"
        authToken={authToken}>
        <div className="ui-modal-head">
          <ToggableLink
            active={!this.state.saving || !this.state.mounted}
            href={get.cancel_url}
            aria-hidden="true"
            className="ui-modal-close"
            data-dismiss="modal"
            title="Close"
            type="button"
            style={{ position: 'static', float: 'right', paddingTop: '5px' }}
            onClick={this._onCancel}>
            <i className="icon-close" />
          </ToggableLink>
          <h3 className="title-l">{t('collection_new_dialog_title')}</h3>
        </div>
        <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
          {get.parent_collection_title ? (
            <div className="ui-alert warning mbx">
              {t('collection_new_dialog_parent_warning')}
              <code style={{ display: 'block' }}>{get.parent_collection_title}</code>
            </div>
          ) : undefined}
          {this.state.saving ? (
            <Preloader />
          ) : (
            [
              alerts,
              <div className="form-body" key="form-body">
                <div className="ui-form-group rowed compact">
                  <label className="form-label">{t('collection_new_label_title')}</label>
                  <div className="form-item">
                    <InputFieldText
                      autocomplete="off"
                      autoFocus="autofocus"
                      name="collection_title"
                      value=""
                    />
                  </div>
                </div>
              </div>
            ]
          )}
        </div>
        <div className="ui-modal-footer">
          <div className="ui-actions">
            <ToggableLink
              active={!this.state.saving || !this.state.mounted}
              href={get.cancel_url}
              aria-hidden="true"
              className="link weak"
              data-dismiss="modal"
              onClick={this._onCancel}>
              {t('collection_new_cancel')}
            </ToggableLink>
            <FormButton
              onClick={this._onOk}
              disabled={this.state.saving}
              text={t('collection_new_create_set')}
            />
          </div>
        </div>
      </RailsForm>
    )
  }
})
