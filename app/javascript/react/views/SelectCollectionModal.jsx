/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// NOTE: it's not only used for collections, but for media entries as well

const React = require('react')
const ampersandReactMixin = require('ampersand-react-mixin')
const f = require('active-lodash')
const t = require('../../lib/i18n-translate.js')
const RailsForm = require('../lib/forms/rails-form.jsx')
const FormButton = require('../ui-components/FormButton.jsx')
const Modal = require('../ui-components/Modal.jsx')
const SelectCollection = require('./Collection/SelectCollection.jsx')

module.exports = React.createClass({
  displayName: 'SelectCollectionModal',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    const type = f.snakeCase(get.type)

    return (
      <Modal>
        <SelectCollection get={get} authToken={authToken} />
      </Modal>
    )
  }
})
