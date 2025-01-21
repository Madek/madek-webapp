import React from 'react'
import f from 'lodash'
import t from '../../lib/i18n-translate.js'
import Modal from '../ui-components/Modal.jsx'
import Preloader from '../ui-components/Preloader.jsx'

class BoxDestroy extends React.Component {
  constructor(props) {
    super(props)
  }

  renderLoading() {
    return (
      <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>
        <Preloader />
      </div>
    )
  }

  renderContent() {
    if (this.props.loading) {
      return this.renderLoading()
    } else {
      return this.renderReady()
    }
  }

  renderReady() {
    return (
      <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>
        {this.renderError()}
        <div style={{ marginBottom: '20px' }}>
          <div>{t('batch_destroy_resources_ask_1')}</div>

          <div style={{ fontWeight: 'bold' }}>
            {f.size(f.filter(this.props.idsWithTypes, { type: 'MediaEntry' }))}
            {t('batch_destroy_resources_ask_2')}
          </div>
          <div style={{ fontWeight: 'bold' }}>
            {f.size(f.filter(this.props.idsWithTypes, { type: 'Collection' }))}
            {t('batch_destroy_resources_ask_3')}
          </div>
          <div>{t('batch_destroy_resources_ask_4')}</div>
        </div>
        <div className="ui-actions" style={{ padding: '10px' }}>
          <a onClick={this.props.onClose} className="link weak">
            {t('batch_destroy_resources_cancel')}
          </a>
          <button className="primary-button" type="submit" onClick={this.props.onOk}>
            {t('batch_destroy_resources_ok')}
          </button>
        </div>
      </div>
    )
  }

  renderError() {
    if (!this.props.error) {
      return null
    }
    return (
      <div className="ui-alerts" style={{ marginBottom: '10px' }}>
        <div className="error ui-alert">{this.props.error}</div>
      </div>
    )
  }

  render() {
    return <Modal widthInPixel={400}>{this.renderContent()}</Modal>
  }
}

module.exports = BoxDestroy
