// View for Batch-Editing Resource Permissions
// Differences between the supported classes (Entry, Collection)
// are handled in the models, so there is only 1 view for all of them.

import React from 'react'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import { t } from '../../lib/ui.js'
import BatchMediaEntryPermissions from '../../../models/batch/batch-media-entry-permissions.js'
import BatchCollectionPermissions from '../../../models/batch/batch-collection-permissions.js'
import ResourcePermissionsForm from '../../decorators/ResourcePermissionsForm.jsx'
import Preloader from '../../ui-components/Preloader.jsx'
import ResourcesBatchBox from '../../decorators/ResourcesBatchBox.jsx'
import TabContent from '../../views/TabContent.jsx'
import PageContent from '../../views/PageContent.jsx'
import PageContentHeader from '../../views/PageContentHeader.jsx'

import xhr from 'xhr'

class BatchResourcePermissions extends React.Component {
  static propTypes = {
    get: PropTypes.shape({
      batch_permissions: PropTypes.array.isRequired,
      batch_resources: PropTypes.shape({
        // for thumbs
        resources: PropTypes.array.isRequired
      }),
      actions: PropTypes.shape({
        save: PropTypes.shape({
          url: PropTypes.string.isRequired,
          method: PropTypes.string.isRequired
        }),
        cancel: PropTypes.shape({ url: PropTypes.string.isRequired })
      })
    }).isRequired,
    authToken: PropTypes.string.isRequired
  }

  constructor(props) {
    super(props)

    // get type from first item in resource list
    const Model = (() => {
      switch (props.get.batch_permissions[0].type) {
        case 'MediaEntry':
          return BatchMediaEntryPermissions
        case 'Collection':
          return BatchCollectionPermissions
        default:
          throw new Error('Invalid type!')
      }
    })()

    this.state = { isClient: false, model: new Model(props.get) }
  }

  componentDidMount() {
    this.state.model.on('change', () => this.forceUpdate())
    return this.setState({ isClient: true })
  }

  componentWillUnmount() {
    return this.state.model.off()
  }

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
  }

  _onSubmit = event => {
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
      function (err, res, body) {
        if (err || res.statusCode > 400 || !body.forward_url) {
          alert(`Error ${res.statusCode}!`)
          return console.error(err || body)
        } else {
          return (window.location = body.forward_url)
        }
      }
    )
  }

  _onCancel = event => {
    event.preventDefault()
    return (window.location = this.props.get.actions.cancel.url)
  }

  render() {
    const props = this.props
    const batchResources = props.get.batch_resources.resources
    const pageTitle =
      t('permissions_batch_title_pre') + props.get.batch_length + t('permissions_batch_title_post')

    return (
      <PageContent>
        <PageContentHeader icon="pen" title={pageTitle} />
        <ResourcesBatchBox
          batchCount={this.props.get.batch_length}
          resources={batchResources}
          authToken={props.authToken}
        />
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
}

export default BatchResourcePermissions
module.exports = BatchResourcePermissions
