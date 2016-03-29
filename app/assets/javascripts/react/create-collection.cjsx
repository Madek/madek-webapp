React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../lib/string-translation.coffee')('de')
RailsForm = require('./lib/forms/rails-form.cjsx')
InputFieldText = require('./lib/forms/input-field-text.cjsx')
Button = require('./ui-components/Button.cjsx')
Modal = require('./ui-components/Modal.cjsx')

module.exports = React.createClass
  displayName: 'CreateCollection'

  getInitialState: () -> { active: false }

  render: ({authToken, get} = @props) ->

    alerts = if @props.get.error then do () =>
      <div className="ui-alerts">
        <p className="ui-alert error">{@props.get.error}</p>
      </div>

    <Modal>

      <RailsForm name='resource_meta_data' action={get.submit_url}
            method='post' authToken={authToken}>

        <div className='ui-modal-head'>
          <a href={get.cancel_url} aria-hidden='true'
            className='ui-modal-close' data-dismiss='modal'
            title='Close' type='button'>
            <i className='icon-close'></i>
          </a>
          <h3 className='title-l'>{t('collection_new_dialog_title')}</h3>
        </div>

        <div className='ui-modal-body'>
          {alerts}
          <div className="form-body">
            <div className="ui-form-group rowed compact">
              <label className="form-label">{t('collection_new_label_title')}</label>
              <div className="form-item">
                <InputFieldText autocomplete='off' autofocus='autofocus' name='collection_title' value='' />
              </div>
            </div>
          </div>
        </div>

        <div className="ui-modal-footer">
          <div className="ui-actions">
            <a href={get.cancel_url} aria-hidden="true" className="link weak"
              data-dismiss="modal">{t('collection_new_cancel')}</a>
            <Button className="primary-button" type='submit'>{t('collection_new_create_set')}</Button>
          </div>
        </div>

      </RailsForm>

    </Modal>
