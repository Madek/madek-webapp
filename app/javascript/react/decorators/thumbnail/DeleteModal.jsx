import React from 'react'
import t from '../../../lib/i18n-translate.js'
import AskModal from '../../ui-components/AskModal.jsx'
import { snakeCase } from '../../../lib/utils.js'

const DeleteModal = ({ resourceType, onModalOk, onModalCancel, modalTitle }) => {
  const type = snakeCase(resourceType)

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

export default DeleteModal
module.exports = DeleteModal
