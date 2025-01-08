/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ampersandReactMixin = require('ampersand-react-mixin')
const f = require('active-lodash')
const t = require('../../../lib/i18n-translate.js')
const FormButton = require('../../ui-components/FormButton.jsx')
const ToggableLink = require('../../ui-components/ToggableLink.jsx')
const Modal = require('../../ui-components/Modal.jsx')
const xhr = require('xhr')
const formXhr = require('../../../lib/form-xhr.js')
const loadXhr = require('../../../lib/load-xhr.js')
const Preloader = require('../../ui-components/Preloader.jsx')
const Button = require('../../ui-components/Button.jsx')
const Icon = require('../../ui-components/Icon.jsx')

module.exports = React.createClass({
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

  componentWillMount() {
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

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get, onClose } = param
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
