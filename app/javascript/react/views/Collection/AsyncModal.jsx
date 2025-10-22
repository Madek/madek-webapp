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

module.exports = createReactClass({
  displayName: 'AsyncModal',

  getInitialState() {
    return {
      mounted: false,
      loading: false,
      errors: null,
      get: null,
      searching: false,
      searchTerm: '',
      newSets: [],
      children: null
    }
  },

  lastRequest: null,

  UNSAFE_componentWillMount() {
    if (this.props.get) {
      return this.setState({
        get: this.props.get,
        children: this.props.contentForGet(this.props.get)
      })
    }
  },

  componentDidMount() {
    this.setState({ ready: true, mounted: true, loading: true })

    return loadXhr(
      {
        method: 'GET',
        url: this.props.getUrl
      },
      (result, json) => {
        if (!this.isMounted()) {
          return
        }
        if (result === 'success') {
          const get = this.props.extractGet(json)
          return this.setState({ loading: false, get, children: this.props.contentForGet(get) })
        } else {
          console.error(`Cannot load dialog: ${JSON.stringify(json)}`)
          return this.setState({ loading: false })
        }
      }
    )
  },

  render() {
    if (!this.state.get) {
      return <Modal loading={true} widthInPixel={this.props.widthInPixel} />
    } else {
      return (
        <Modal loading={false} widthInPixel={this.props.widthInPixel}>
          {this.state.children}
        </Modal>
      )
    }
  }
})
