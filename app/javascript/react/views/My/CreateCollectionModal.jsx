/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import Modal from '../../ui-components/Modal.jsx'
import loadXhr from '../../../lib/load-xhr.js'
import CreateCollection from './CreateCollection.jsx'

module.exports = createReactClass({
  displayName: 'CreateCollectionModal',

  getInitialState() {
    return {
      mounted: false,
      loading: false,
      get: null
    }
  },

  UNSAFE_componentWillMount() {
    return this.setState({ get: this.props.get, newCollectionUrl: this.props.newCollectionUrl })
  },

  componentDidMount() {
    this.setState({ mounted: true })

    if (!this.state.get) {
      this.setState({ loading: true })

      return loadXhr(
        {
          method: 'GET',
          url: this.state.newCollectionUrl
        },
        (result, json) => {
          if (!this.isMounted()) {
            return
          }
          if (result === 'success') {
            return this.setState({ loading: false, get: json })
          } else {
            console.error(`Cannot load dialog: ${JSON.stringify(json)}`)
            return this.setState({ loading: false })
          }
        }
      )
    }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, onClose } = param
    if (!this.state.get) {
      return <Modal loading={true} />
    }

    if (this.state.loading || (this.props.async && !this.state.mounted)) {
      return <Modal loading={true} />
    }

    return (
      <Modal loading={false}>
        <CreateCollection authToken={authToken} get={this.state.get} onClose={onClose} />
      </Modal>
    )
  }
})
