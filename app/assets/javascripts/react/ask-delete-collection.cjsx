React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../lib/string-translation')('de')
RailsForm = require('./lib/forms/rails-form.cjsx')
InputFieldText = require('./lib/forms/input-field-text.cjsx')
Button = require('./ui-components/Button.cjsx')
Modal = require('./ui-components/Modal.cjsx')

module.exports = React.createClass
  displayName: 'AskDeleteCollection'

  getInitialState: () -> { active: false }

  render: ({authToken, get} = @props) ->

    <Modal widthInPixel='400'>

      <RailsForm name='resource_meta_data' action={get.submit_url}
            method='delete' authToken={authToken}>

        <div className='ui-modal-head'>
          <a href={get.cancel_url} aria-hidden='true'
            className='ui-modal-close' data-dismiss='modal'
            title='Close' type='button'>
            <i className='icon-close'></i>
          </a>
          <h3 className='title-l'>{t('collection_ask_delete_title')}</h3>
        </div>

        <div className='ui-modal-body'>
          <p className="pam by-center">
            {t('collection_ask_delete_question_pre')}
            <strong>{get.title}</strong>
            {t('collection_ask_delete_question_post')}
          </p>
        </div>

        <div className="ui-modal-footer">
          <div className="ui-actions">
            <a href={get.cancel_url} aria-hidden="true" className="link weak"
              data-dismiss="modal">{t('collection_ask_delete_cancel')}</a>
            <Button className="primary-button" type='submit'>{t('collection_ask_delete_ok')}</Button>
          </div>
        </div>

      </RailsForm>

    </Modal>
