/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// View for Batch-Editing Resource Permissions
// Differences between the supported classes (Entry, Collection)
// are handled in the models, so there is only 1 view for all of them.

const React = require('react')
const f = require('active-lodash')
const ui = require('../../lib/ui.js')
const { t } = ui

const BatchMediaEntryPermissions = require('../../../models/batch/batch-media-entry-permissions.js')
const BatchCollectionPermissions = require('../../../models/batch/batch-collection-permissions.js')

const ResourcePermissionsForm = require('../../decorators/ResourcePermissionsForm.cjsx')
const Preloader = require('../../ui-components/Preloader.cjsx')
const ResourcesBatchBox = require('../../decorators/ResourcesBatchBox.cjsx')
const TabContent = require('../../views/TabContent.cjsx')
const PageContent = require('../../views/PageContent.cjsx')
const PageContentHeader = require('../../views/PageContentHeader.cjsx')

const xhr = require('xhr')

module.exports = React.createClass({
  displayName: 'BatchResourcePermissions',
  propTypes: {
    get: React.PropTypes.shape({
      batch_permissions: React.PropTypes.array.isRequired,
      batch_resources: React.PropTypes.shape({
        // for thumbs
        resources: React.PropTypes.array.isRequired
      }),
      actions: React.PropTypes.shape({
        save: React.PropTypes.shape({
          url: React.PropTypes.string.isRequired,
          method: React.PropTypes.string.isRequired
        }),
        cancel: React.PropTypes.shape({ url: React.PropTypes.string.isRequired })
      })
    }).isRequired,
    authToken: React.PropTypes.string.isRequired
  },

  // init state model in any case:
  componentWillMount() {
    // get type from first item in resource list
    const Model = (() => {
      switch (this.props.get.batch_permissions[0].type) {
        case 'MediaEntry':
          return BatchMediaEntryPermissions
        case 'Collection':
          return BatchCollectionPermissions
        default:
          throw new Error('Invalid type!')
      }
    })()

    return this.setState({ model: new Model(this.props.get) })
  },

  // NOTE: UI has no fallback, so even though this view only supports
  // 'editing' state, we only activate it on mount to prevent accidental submit
  getInitialState() {
    return { isClient: false }
  },
  componentDidMount() {
    this.state.model.on('change', () => this.forceUpdate())
    return this.setState({ isClient: true })
  },
  componentWillUnmount() {
    return this.state.model.off()
  },

  _loadingMessage() {
    return (
      <div>
        <div className="no-js">
          <div className="error ui-alert mbm">{t('app_warning_jsonly')}</div>
        </div>
        <div className="js-only">
          <Preloader />
        </div>
      </div>
    )
  },

  _onSubmit(event) {
    event.preventDefault()
    return xhr(
      {
        url: this.props.get.actions.save.url,
        method: this.props.get.actions.save.method,
        json: f.merge(this.state.model.serialize(), {
          return_to: this.props.get.actions.cancel.url
        }),
        headers: { 'X-CSRF-Token': this.props.authToken }
      },
      function(err, res, body) {
        if (err || res.statusCode > 400 || !body.forward_url) {
          alert(`Error ${res.statusCode}!`)
          return console.error(err || body)
        } else {
          return (window.location = body.forward_url)
        }
      }
    )
  },

  _onCancel(event) {
    event.preventDefault()
    return (window.location = this.props.get.actions.cancel.url)
  }, // SYNC!

  render(props) {
    if (props == null) {
      ;({ props } = this)
    }
    const batchResources = props.get.batch_resources.resources
    const pageTitle =
      t('permissions_batch_title_pre') + batchResources.length + t('permissions_batch_title_post')

    return (
      <PageContent>
        <PageContentHeader icon="pen" title={pageTitle} />
        <ResourcesBatchBox resources={batchResources} authToken={props.authToken} />
        <TabContent>
          <div className="bright pal rounded-bottom rounded-top-right ui-container">
            {!this.state.isClient ? (
              this._loadingMessage()
            ) : (
              <ResourcePermissionsForm
                editing={true}
                get={this.state.model}
                onSubmit={this._onSubmit}
                onCancel={this._onCancel}
              />
            )}
          </div>
        </TabContent>
      </PageContent>
    )
  }
})
