/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const PageContentHeader = require('./PageContentHeader.jsx')
const HeaderPrimaryButton = require('./HeaderPrimaryButton.jsx')
const t = require('../../lib/i18n-translate.js')
const CreateCollectionModal = require('./My/CreateCollectionModal.jsx')

module.exports = React.createClass({
  displayName: 'DashboardHeader',

  getInitialState() {
    return {
      active: this.props.isClient,
      showModal: false,
      mounted: false
    }
  },

  componentDidMount() {
    return this.setState({ mounted: true })
  },

  _onClose() {
    return this.setState({ showModal: false })
  },

  _onCreateSetClick(event) {
    event.preventDefault()
    this.setState({ showModal: true })
    return false
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get, authToken } = param
    return (
      <div style={{ margin: '0px', padding: '0px' }}>
        <PageContentHeader icon="home" title={t('sitemap_my_archive')}>
          <HeaderPrimaryButton
            icon="upload"
            text={t('dashboard_create_media_entry_btn')}
            href={get.new_media_entry_url}
          />
          <HeaderPrimaryButton
            icon="plus"
            text={t('dashboard_create_collection_btn')}
            href={get.new_collection_url}
            onClick={this._onCreateSetClick}
          />
        </PageContentHeader>
        {this.state.showModal ? (
          <CreateCollectionModal
            get={get.new_collection}
            async={this.state.mounted}
            authToken={authToken}
            onClose={this._onClose}
            newCollectionUrl={get.new_collection_url}
          />
        ) : (
          undefined
        )}
      </div>
    )
  }
})
