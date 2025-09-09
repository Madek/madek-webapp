/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import BatchRemoveFromSet from './BatchRemoveFromSet.jsx'
import AsyncModal from '../views/Collection/AsyncModal.jsx'
import setUrlParams from '../../lib/set-params-for-url.js'

module.exports = createReactClass({
  displayName: 'BatchRemoveFromSetModal',

  getInitialState() {
    return {
      mounted: false
    }
  },

  UNSAFE_componentWillMount() {},

  _contentForGet(get) {
    return (
      <BatchRemoveFromSet
        returnTo={this.props.returnTo}
        get={get}
        async={true}
        authToken={this.props.authToken}
        onClose={this.props.onClose}
      />
    )
  },

  _extractGet(json) {
    return json
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    const getUrl = setUrlParams('/batch_ask_remove_from_set', {
      parent_collection_id: this.props.collectionUuid,
      resource_id: this.props.resourceIds,
      return_to: this.props.returnTo
    })
    return (
      <AsyncModal
        get={get}
        getUrl={getUrl}
        contentForGet={this._contentForGet}
        extractGet={this._extractGet}
      />
    )
  }
})
