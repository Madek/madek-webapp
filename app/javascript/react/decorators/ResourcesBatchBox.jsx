import React from 'react'
import PropTypes from 'prop-types'
import t from '../../lib/i18n-translate.js'
import ResourceThumbnail from '../decorators/ResourceThumbnail.jsx'

const ResourcesBatchBox = ({ resources, authToken, batchCount, counts }) => {
  const actualBatchCount =
    typeof batchCount === 'string' || typeof batchCount === 'number' ? batchCount : resources.length

  return (
    <div className="bordered ui-container midtone rounded-right rounded-bottom mbm">
      <div className="ui-resources-selection">
        <div className="ui-toolbar inverted ui-container pvx phs rounded-top">
          <h2 className="ui-toolbar-header">
            {actualBatchCount === 1
              ? actualBatchCount + ' ' + t('meta_data_batch_item_selected')
              : actualBatchCount + ' ' + t('meta_data_batch_items_selected')}
            {counts && counts.authorized_resources < counts.all_resources ? (
              <span style={{ color: '#e5b100' }}>
                {` ${t('meta_data_batch_some_ignored_1')}`}
                {counts.all_resources - counts.authorized_resources}
                {t('meta_data_batch_some_ignored_2')}
              </span>
            ) : undefined}
          </h2>
        </div>
        <div style={{ overflow: 'hidden' }} className="ui-resources-media">
          <div className="ui-resources-holder pal">
            <ul className="grid ui-resources">
              {resources.map(resource => (
                <ResourceThumbnail
                  elm="li"
                  key={resource.uuid}
                  get={resource}
                  authToken={authToken}
                />
              ))}
              {resources.length < actualBatchCount && (
                <li
                  style={{
                    paddingTop: '50px',
                    paddingLeft: '20px',
                    display: 'block',
                    float: 'left',
                    fontSize: '24px'
                  }}>
                  {`+${actualBatchCount - resources.length}`}
                  <br />
                  {t('meta_data_batch_more')}
                </li>
              )}
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}

ResourcesBatchBox.propTypes = {
  resources: PropTypes.array.isRequired,
  authToken: PropTypes.string.isRequired
}

export default ResourcesBatchBox
module.exports = ResourcesBatchBox
