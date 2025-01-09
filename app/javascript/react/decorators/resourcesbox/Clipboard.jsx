/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const ui = require('../../lib/ui.js')
const { t } = ui
const Modal = require('../../ui-components/Modal.jsx')
const setUrlParams = require('../../../lib/set-params-for-url.js')
const railsFormPut = require('../../../lib/form-put-with-errors.js')
const xhr = require('xhr')

module.exports = React.createClass({
  displayName: 'Clipboard',

  getInitialState() {
    return {
      step: 'initial'
    }
  },

  componentDidMount() {
    switch (this.props.type) {
      case 'add_all':
        return this._fetchForAddAll()
      case 'add_selected':
        return this._addSelected()
      case 'remove_all':
        return this._removeAll()
      case 'remove_selected':
        return this._removeSelected()
      default:
        throw `Unexpected type: ${this.props.type}`
    }
  },

  _selectedResourceIdsWithTypes() {
    return this.props.selectedResources.map(model => ({
      uuid: model.uuid,
      type: model.type
    }))
  },

  fetchAllResourceIds(resources, pagination, jsonPath, callback) {
    const nextUrl = setUrlParams(
      this.props.forUrl,
      { list: { page: 1, per_page: pagination.total_count } },
      { ___sparse: JSON.stringify(f.set({}, jsonPath, [{ uuid: {}, type: {} }])) }
    )

    return xhr.get({ url: nextUrl, json: true }, (err, res, body) => {
      if (err || res.statusCode > 400) {
        return callback({ result: 'error' })
      } else {
        return callback({
          result: 'success',
          data: f.get(body, jsonPath)
        })
      }
    })
  },

  _fetchForAddAll() {
    this.setState({ step: 'fetching' })

    this.fetchAllResourceIds(
      this.props.resources,
      this.props.pagination,
      this.props.jsonPath,
      result => {
        if (result.result === 'error') {
          window.scrollTo(0, 0)
          return this.setState({
            step: 'fetching-error',
            error: 'There was an error. Please try again.'
          })
        } else {
          return this.setState({
            step: 'dialog',
            fetchedResources: f.map(result.data, entry => ({
              uuid: entry.uuid,
              type: entry.type
            }))
          })
        }
      }
    )
    return false
  },

  _addSelected() {
    this.setState({ step: 'adding-selected' })
    const resourceIds = this._selectedResourceIdsWithTypes()
    const url = setUrlParams('/batch_add_to_clipboard', {})
    railsFormPut.byData({ resource_id: resourceIds }, url, result => {
      if (result.result === 'error') {
        window.scrollTo(0, 0)
        return this.setState({ step: 'adding-error', error: result.message })
      } else {
        return location.reload()
      }
    })
    return false
  },

  _cancelBatchAddToClipboard(event) {
    event.preventDefault()
    if (this.props.onClose) {
      return this.props.onClose()
    }
  },

  _processChunks() {
    if (this.state.step !== 'adding-all') {
      return
    } else {
      const { chunks } = this.state

      const chunk = f.first(f.filter(chunks, { state: 'pending' }))

      if (chunk) {
        chunk.state = 'loading'
        this.setState({ chunks })

        const url = setUrlParams('/batch_add_to_clipboard', {})
        return railsFormPut.byData({ resource_id: chunk.ids }, url, result => {
          chunk.state = 'loaded'
          this.setState({ chunks })
          if (result.result === 'error') {
            window.scrollTo(0, 0)
            return this.setState({ step: 'adding-all-error', error: result.message })
          } else {
            return this._processChunks()
          }
        })
      } else {
        this.setState({ step: this.state.step })
        return setTimeout(() => location.reload(), 100)
      }
    }
  },

  _okBatchAddToClipboard(event) {
    event.preventDefault()
    const resourceIds = this.state.fetchedResources
    this.setState({ step: 'adding-all' })

    const chunks = f.map(f.chunk(resourceIds, 1000), ids => ({
      state: 'pending',
      ids
    }))

    return this.setState({ chunks }, () => {
      return this._processChunks()
    })
  },

  _cancelAddingAll() {
    window.scrollTo(0, 0)
    return this.setState({ step: 'adding-all-cancelled' })
  },

  _removeAll() {
    this.setState({ step: 'removing' })

    const url = setUrlParams('/batch_remove_all_from_clipboard', {})
    railsFormPut.byData({}, url, result => {
      if (result.result === 'error') {
        window.scrollTo(0, 0)
        return this.setState({ step: 'removing-error', error: result.message })
      } else {
        return location.reload()
      }
    })

    return false
  },

  _removeSelected() {
    this.setState({ step: 'removing' })
    const resourceIds = this._selectedResourceIdsWithTypes()
    const url = setUrlParams('/batch_remove_from_clipboard', {})
    railsFormPut.byData({ resource_id: resourceIds }, url, result => {
      if (result.result === 'error') {
        window.scrollTo(0, 0)
        return this.setState({ step: 'removing-error', error: result.message })
      } else if (result.type === 'data' && result.data.result === 'clipboard_deleted') {
        // location.href = '/my'
        return location.reload()
      } else {
        return location.reload()
      }
    })
    return false
  },

  _infoText(text) {
    return <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>{text}</div>
  },

  _errorBox(error) {
    return (
      <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>
        <div className="ui-alerts" style={{ marginBottom: '20px' }}>
          <div className="error ui-alert">{this.state.error}</div>
        </div>
      </div>
    )
  },

  _okCloseAction() {
    return (
      <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>
        <div className="ui-actions">
          <a href={null} className="primary-button" onClick={this.props.onClose}>
            {t('clipboard_ask_add_all_ok')}
          </a>
        </div>
      </div>
    )
  },

  render() {
    switch (this.state.step) {
      case 'initial':
        return <Modal widthInPixel={400} />

      case 'fetching':
        return <Modal widthInPixel={400}>{this._infoText(t('clipboard_fetching_resources'))}</Modal>

      case 'fetching-error':
        return (
          <Modal widthInPixel={400}>
            {this._errorBox(this.state.error)}
            {this._infoText(t('clipboard_fetching_resources'))}
            {this._okCloseAction()}
          </Modal>
        )

      case 'adding-selected':
        return <Modal widthInPixel={400}>{this._infoText(t('clipboard_adding_resources'))}</Modal>

      case 'adding-all':
        var { chunks } = this.state
        var pending = f.filter(chunks, chunk => chunk.state !== 'loaded')
        var done = f.filter(chunks, { state: 'loaded' })

        var pendingCount = f.reduce(pending, (sum, chunk) => sum + f.size(chunk.ids), 0)
        var doneCount = f.reduce(done, (sum, chunk) => sum + f.size(chunk.ids), 0)

        var counter = f.size(chunks) > 1 ? doneCount + ' / ' + (pendingCount + doneCount) : ''

        return (
          <Modal widthInPixel={400}>
            {this._infoText(t('clipboard_adding_resources') + ' ' + counter)}
            <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>
              <div className="ui-actions">
                <a onClick={this._cancelAddingAll} className="link weak">
                  {t('clipboard_ask_add_all_cancel')}
                </a>
              </div>
            </div>
          </Modal>
        )

      case 'adding-error':
        return (
          <Modal widthInPixel={400}>
            {this._errorBox(this.state.error)}
            {this._infoText(t('clipboard_adding_resources'))}
            {this._okCloseAction()}
          </Modal>
        )

      case 'adding-all-cancelled':
        return (
          <Modal widthInPixel={400}>
            {this._infoText(t('clipboard_adding_all_resources_cancelled'))}
            {this._okCloseAction()}
          </Modal>
        )

      case 'adding-all-error':
        return (
          <Modal widthInPixel={400}>
            {this._errorBox(this.state.error)}
            {this._infoText(t('clipboard_adding_all_resources_error'))}
            <div className="ui-actions" style={{ padding: '10px' }}>
              <a onClick={this._cancelBatchAddToClipboard} className="link weak">
                {t('clipboard_ask_add_all_cancel')}
              </a>
              <button
                className="primary-button"
                type="submit"
                onClick={this._okBatchAddToClipboard}>
                {t('clipboard_adding_all_resources_retry')}
              </button>
            </div>
          </Modal>
        )

      case 'removing':
        return <Modal widthInPixel={400}>{this._infoText(t('clipboard_removing_resources'))}</Modal>

      case 'removing-error':
        return (
          <Modal widthInPixel={400}>
            {this._errorBox(this.state.error)}
            {this._infoText(t('clipboard_removing_resources'))}
            {this._okCloseAction()}
          </Modal>
        )

      case 'dialog':
        return (
          <Modal widthInPixel={400}>
            <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>
              {t('clipboard_ask_add_all_1')}
              {this.state.fetchedResources.length}
              {t('clipboard_ask_add_all_2')}
            </div>
            <div className="ui-actions" style={{ padding: '10px' }}>
              <a onClick={this._cancelBatchAddToClipboard} className="link weak">
                {t('clipboard_ask_add_all_cancel')}
              </a>
              <button
                className="primary-button"
                type="submit"
                onClick={this._okBatchAddToClipboard}>
                {t('clipboard_ask_add_all_ok')}
              </button>
            </div>
          </Modal>
        )

      default:
        throw `Unexpected step: ${this.state.step}`
    }
  }
})
