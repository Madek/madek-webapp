import React from 'react'
import FormButton from './FormButton.jsx'
import Modal from './Modal.jsx'
import Preloader from './Preloader.jsx'

const AskModal = ({ title, error, onOk, onCancel, okText, cancelText, loading, children }) => {
  return (
    <Modal widthInPixel="400">
      <div className="ui-modal-head">
        <a
          onClick={onCancel}
          aria-hidden="true"
          className="ui-modal-close"
          data-dismiss="modal"
          title="Close"
          type="button"
          style={{ position: 'static', float: 'right', paddingTop: '5px' }}>
          <i className="icon-close" />
        </a>
        <h3 className="title-l">{title}</h3>
      </div>
      <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
        {loading && <Preloader />}
        {error && !loading && (
          <div className="ui-alerts">
            <div className="error ui-alert">{error}</div>
          </div>
        )}
        {!loading && children}
      </div>
      <div className="ui-modal-footer">
        <div className="ui-actions">
          <a onClick={onCancel} aria-hidden="true" className="link weak" data-dismiss="modal">
            {cancelText}
          </a>
          <FormButton onClick={onOk} text={okText} />
        </div>
      </div>
    </Modal>
  )
}

export default AskModal
module.exports = AskModal
