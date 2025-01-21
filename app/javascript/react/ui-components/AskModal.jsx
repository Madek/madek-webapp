/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import FormButton from './FormButton.jsx'
import Modal from './Modal.jsx'
import Preloader from './Preloader.jsx'

module.exports = createReactClass({
  displayName: 'AskModal',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { title, error, onOk, onCancel, okText, cancelText, loading } = param
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
          {loading ? <Preloader /> : undefined}
          {error && !loading ? (
            <div className="ui-alerts">
              <div className="error ui-alert">{error}</div>
            </div>
          ) : (
            undefined
          )}
          {!loading ? this.props.children : undefined}
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
})
