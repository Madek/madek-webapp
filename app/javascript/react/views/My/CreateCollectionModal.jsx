/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const Modal = require('../../ui-components/Modal.jsx')
const loadXhr = require('../../../lib/load-xhr.js')
const CreateCollection = require('./CreateCollection.jsx')

module.exports = React.createClass({
  displayName: 'CreateCollectionModal',

  getInitialState() {
    return {
      mounted: false,
      loading: false,
      get: null
    }
  },

  componentWillMount() {
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
    const { authToken, get, onClose } = param
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
