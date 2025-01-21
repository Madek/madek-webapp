/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// NOTE: it's not only used for collections, but for media entries as well

import React from 'react'
import createReactClass from 'create-react-class'
import Modal from '../ui-components/Modal.jsx'
import SelectCollection from './Collection/SelectCollection.jsx'

module.exports = createReactClass({
  displayName: 'SelectCollectionModal',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param

    return (
      <Modal>
        <SelectCollection get={get} authToken={authToken} />
      </Modal>
    )
  }
})
