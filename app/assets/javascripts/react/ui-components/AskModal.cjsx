React = require('react')
ReactDOM = require('react-dom')
t = require('../../lib/string-translation')('de')
FormButton = require('./FormButton.cjsx')
Modal = require('./Modal.cjsx')
Preloader = require('./Preloader.cjsx')

module.exports = React.createClass
  displayName: 'AskModal'

  render: ({title, error, onOk, onCancel, okText, cancelText, loading} = @props) ->

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
        {
          if loading
            <Preloader />
        }
        {
          if error and not loading
            <div className="ui-alerts">
              <div className="error ui-alert">
                {error}
              </div>
            </div>
        }
        {
          if not loading
            @props.children
        }
      </div>

      <div className="ui-modal-footer">
        <div className="ui-actions">
          <a onClick={onCancel} aria-hidden="true" className="link weak"
            data-dismiss="modal">{cancelText}</a>
          <FormButton onClick={onOk} text={okText}/>
        </div>
      </div>

    </Modal>
