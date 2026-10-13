import React, { useState } from 'react'
import t from '../../../lib/i18n-translate.js'
import RailsForm from '../../lib/forms/rails-form.jsx'
import FormButton from '../../ui-components/FormButton.jsx'
import Modal from '../../ui-components/Modal.jsx'

const XmpImport = ({ action, authToken, onClose }) => {
  const [hasFile, setHasFile] = useState(false)

  const close = event => {
    event.preventDefault()
    onClose()
  }

  return (
    <Modal widthInPixel="500">
      <RailsForm
        name="xmp_import"
        action={action}
        method="post"
        encType="multipart/form-data"
        authToken={authToken}>
        <div className="ui-modal-head">
          <a
            href="#"
            aria-hidden="true"
            onClick={close}
            className="ui-modal-close"
            title="Close"
            style={{ position: 'static', float: 'right', paddingTop: '5px' }}>
            <i className="icon-close" />
          </a>
          <h3 className="title-l">{t('media_entry_xmp_import_title')}</h3>
        </div>
        <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
          <p className="mbm">{t('media_entry_xmp_import_hint')}</p>
          <input
            type="file"
            name="xmp_file"
            accept=".xmp"
            onChange={e => setHasFile(e.target.files.length > 0)}
          />
        </div>
        <div className="ui-modal-footer">
          <div className="ui-actions">
            <a href="#" aria-hidden="true" className="link weak" onClick={close}>
              {t('media_entry_xmp_import_cancel')}
            </a>
            <FormButton text={t('media_entry_xmp_import_submit')} disabled={!hasFile} />
          </div>
        </div>
      </RailsForm>
    </Modal>
  )
}

export default XmpImport
