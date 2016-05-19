React = require('react')
ReactDOM = require('react-dom')
t = require('../../lib/string-translation')('de')
Button = require('./Button.cjsx')
Modal = require('./Modal.cjsx')

module.exports = React.createClass
  displayName: 'AskModal'

  render: ({title, onOk, onCancel} = @props) ->

    <Modal widthInPixel='400'>

      <div className='ui-modal-head'>
        <a onClick={onCancel} aria-hidden='true'
          className='ui-modal-close' data-dismiss='modal'
          title='Close' type='button'
            style={{position: 'static', float: 'right', paddingTop: '5px'}}>
          <i className='icon-close'></i>
        </a>
        <h3 className='title-l'>{title}</h3>
      </div>

      <div className='ui-modal-body' style={{maxHeight: 'none'}}>
        <p className="pam by-center">
          {@props.children}
        </p>
      </div>

      <div className="ui-modal-footer">
        <div className="ui-actions">
          <a onClick={onCancel} aria-hidden="true" className="link weak"
            data-dismiss="modal">{t('resource_ask_delete_cancel')}</a>
          <Button onClick={onOk} className="primary-button" type='submit'>{t('resource_ask_delete_ok')}</Button>
        </div>
      </div>

    </Modal>
