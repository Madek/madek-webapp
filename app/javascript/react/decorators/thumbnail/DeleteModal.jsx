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
import AskModal from '../../ui-components/AskModal.jsx'

module.exports = createReactClass({
  displayName: 'DeleteModal',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { resourceType, onModalOk, onModalCancel, modalTitle } = param
    const type = f.snakeCase(resourceType)

    return (
      <AskModal
        title={t(type + '_ask_delete_title')}
        onCancel={onModalCancel}
        onOk={onModalOk}
        okText={t('resource_ask_delete_ok')}
        cancelText={t('resource_ask_delete_cancel')}>
        <p className="pam by-center">
          {t(type + '_ask_delete_question_pre')}
          <strong>{modalTitle}</strong>
          {t('resource_ask_delete_question_post')}
        </p>
      </AskModal>
    )
  }
})
