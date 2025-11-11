import React from 'react'
import Modal from '../../ui-components/Modal.jsx'
import loadXhr from '../../../lib/load-xhr.js'

class AsyncModal extends React.Component {
  constructor(props) {
    super(props)
    const initialGet = props.get
    this.state = {
      mounted: false,
      loading: false,
      errors: null,
      get: initialGet || null,
      searching: false,
      searchTerm: '',
      newSets: [],
      children: initialGet ? props.contentForGet(initialGet) : null
    }
    this.lastRequest = null
    this._isMounted = false
  }

  componentDidMount() {
    this._isMounted = true
    this.setState({ ready: true, mounted: true, loading: true })

    return loadXhr(
      {
        method: 'GET',
        url: this.props.getUrl
      },
      (result, json) => {
        if (!this._isMounted) {
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
  }

  componentWillUnmount() {
    this._isMounted = false
  }

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
}

export default AsyncModal
