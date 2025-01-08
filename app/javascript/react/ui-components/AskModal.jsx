/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const t = require('../../lib/i18n-translate.js')
const FormButton = require('./FormButton.jsx')
const Modal = require('./Modal.jsx')
const Preloader = require('./Preloader.jsx')

module.exports = React.createClass({
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
