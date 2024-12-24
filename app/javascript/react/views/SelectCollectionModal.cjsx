# NOTE: it's not only used for collections, but for media entries as well

React = require('react')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')
RailsForm = require('../lib/forms/rails-form.cjsx')
FormButton = require('../ui-components/FormButton.cjsx')
Modal = require('../ui-components/Modal.cjsx')
SelectCollection = require('./Collection/SelectCollection.cjsx')

module.exports = React.createClass
  displayName: 'SelectCollectionModal'

  render: ({authToken, get} = @props) ->
    type = f.snakeCase(get.type)

    <Modal>
      <SelectCollection get={get} authToken={authToken} />
    </Modal>
