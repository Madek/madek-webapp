import React from 'react'
import t from '../../lib/i18n-translate.js'
import RailsForm from '../lib/forms/rails-form.jsx'
import setUrlParams from '../../lib/set-params-for-url.js'
import FormButton from '../ui-components/FormButton.jsx'

const BatchRemoveFromSet = ({ get, authToken }) => {
  const requestUrl = setUrlParams(get.batch_remove_from_set_url, {
    resource_id: get.resource_ids,
    return_to: get.return_to,
    parent_collection_id: get.parent_collection_id
  })

  return (
    <RailsForm name="resource_meta_data" action={requestUrl} method="patch" authToken={authToken}>
      <input type="hidden" name="return_to" value={get.return_to} />
      <input type="hidden" name="parent_collection_id" value={get.parent_collection_id} />
      <div className="ui-modal-head">
        <a
          href={get.return_to}
          aria-hidden="true"
          className="ui-modal-close"
          data-dismiss="modal"
          title="Close"
          type="button"
          style={{ position: 'static', float: 'right', paddingTop: '5px' }}>
          <i className="icon-close" />
        </a>
        <h3 className="title-l">{t('batch_remove_from_collection_title')}</h3>
      </div>
      <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
        <p className="pam by-center">
          {t('batch_remove_from_collection_question_part_1')}
          <strong>{get.media_entries_count}</strong>
          {t('batch_remove_from_collection_question_part_2')}
          <strong>{get.collections_count}</strong>
          {t('batch_remove_from_collection_question_part_3')}
        </p>
      </div>
      <div className="ui-modal-footer">
        <div className="ui-actions">
          <a href={get.return_to} aria-hidden="true" className="link weak" data-dismiss="modal">
            {t('batch_remove_from_collection_cancel')}
          </a>
          <FormButton text={t('batch_remove_from_collection_remove')} />
        </div>
      </div>
    </RailsForm>
  )
}

export default BatchRemoveFromSet
module.exports = BatchRemoveFromSet
