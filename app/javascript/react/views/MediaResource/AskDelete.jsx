/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import t from '../../../lib/i18n-translate.js'
import RailsForm from '../../lib/forms/rails-form.jsx'
import FormButton from '../../ui-components/FormButton.jsx'
import Modal from '../../ui-components/Modal.jsx'

module.exports = createReactClass({
  displayName: 'MediaResource.AskDelete',

  getInitialState() {
    return { active: false }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    const type = f.snakeCase(get.type)

    return (
      <Modal widthInPixel="400">
        <RailsForm
          name="resource_meta_data"
          action={get.submit_url}
          method="delete"
          authToken={authToken}>
          <div className="ui-modal-head">
            <a
              href={get.cancel_url}
              aria-hidden="true"
              className="ui-modal-close"
              data-dismiss="modal"
              title="Close"
              type="button"
              style={{ position: 'static', float: 'right', paddingTop: '5px' }}>
              <i className="icon-close" />
            </a>
            <h3 className="title-l">{t(type + '_ask_delete_title')}</h3>
          </div>
          <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
            <p className="pam by-center">
              {t(type + '_ask_delete_question_pre')}
              <strong>{get.title}</strong>
              {t('resource_ask_delete_question_post')}
            </p>
          </div>
          <div className="ui-modal-footer">
            <div className="ui-actions">
              <a
                href={get.cancel_url}
                aria-hidden="true"
                className="link weak"
                data-dismiss="modal">
                {t('resource_ask_delete_cancel')}
              </a>
              <FormButton text={t('resource_ask_delete_ok')} />
            </div>
          </div>
        </RailsForm>
      </Modal>
    )
  }
})
