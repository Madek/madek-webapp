import React from 'react'
import ResourceThumbnail from './ResourceThumbnail.jsx'
import t from '../../lib/i18n-translate'

class SuperBoxUpload extends React.Component {
  constructor(props) {
    super(props)
  }

  renderResource(config) {
    return (
      <ResourceThumbnail
        elm="div"
        style={null}
        get={config.resource}
        isClient={true}
        fetchRelations={false}
        isSelected={false}
        onSelect={null}
        authToken={config.authToken}
        key={'resource_' + (config.resource.uuid || config.resource.cid)}
        pinThumb={false}
        listThumb={false}
        uploadMediaType={config.resource.mediaType}
      />
    )
  }

  renderResources(config) {
    return config.collection.map(r => {
      return this.renderResource({ resource: r, authToken: config.authToken })
    })
  }

  renderContent(config) {
    if (config.collection.length == 0) {
      return <div style={{ height: '250px' }} />
    }

    return (
      <ul className="grid show_permissions ui-resources">
        <li className="ui-resources-page">
          <ul className="ui-resources-page-items">{this.renderResources(config)}</ul>
        </li>
      </ul>
    )
  }

  render() {
    const collection = this.props.collection
    const authToken = this.props.authToken
    const children = this.props.children

    return (
      <div
        data-test-id="resources-box"
        className="ui-container midtone bordered rounded mvl ui-polybox">
        <div className="ui-container inverted ui-toolbar pvx rounded-top">
          <h2 className="ui-toolbar-header pls" style={{ minHeight: '1px' }}>
            {t('media_entry_media_import_box_header_a') +
              collection.length +
              t('media_entry_media_import_box_header_b')}
          </h2>
        </div>

        <div className="ui-resources-holder pam">
          <div className="ui-container table auto">
            <div className="ui-container table-cell table-substance">
              {children}

              {this.renderContent({
                collection: collection,
                authToken: authToken
              })}
            </div>
          </div>
        </div>
      </div>
    )
  }
}

module.exports = SuperBoxUpload
