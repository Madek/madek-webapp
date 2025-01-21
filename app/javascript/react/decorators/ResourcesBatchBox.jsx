/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import t from '../../lib/i18n-translate.js'
import ResourceThumbnail from '../decorators/ResourceThumbnail.jsx'

module.exports = createReactClass({
  displayName: 'ResourcesBatchBox',
  propTypes: {
    resources: PropTypes.array.isRequired,
    authToken: PropTypes.string.isRequired
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    let { resources, authToken, batchCount, counts } = param
    batchCount =
      f.isString(batchCount) || f.isNumber(batchCount) ? batchCount : f.get(resources, 'length')

    return (
      <div className="bordered ui-container midtone rounded-right rounded-bottom mbm">
        <div className="ui-resources-selection">
          <div className="ui-toolbar inverted ui-container pvx phs rounded-top">
            <h2 className="ui-toolbar-header">
              {batchCount === 1
                ? batchCount + ' ' + t('meta_data_batch_item_selected')
                : batchCount + ' ' + t('meta_data_batch_items_selected')}
              {counts && counts.authorized_resources < counts.all_resources ? (
                <span style={{ color: '#e5b100' }}>
                  {` ${t('meta_data_batch_some_ignored_1')}`}
                  {counts.all_resources - counts.authorized_resources}
                  {t('meta_data_batch_some_ignored_2')}
                </span>
              ) : (
                undefined
              )}
            </h2>
          </div>
          <div style={{ overflow: 'hidden' }} className="ui-resources-media">
            <div className="ui-resources-holder pal">
              <ul className="grid ui-resources">
                {f.map(resources, resource => (
                  <ResourceThumbnail
                    elm="li"
                    key={resource.uuid}
                    get={resource}
                    authToken={authToken}
                  />
                ))}
                {(() => {
                  if (resources.length < batchCount) {
                    const style = {
                      paddingTop: '50px',
                      paddingLeft: '20px',
                      display: 'block',
                      float: 'left',
                      fontSize: '24px'
                    }

                    return (
                      <li style={style}>
                        {`+${batchCount - resources.length}`}
                        <br />
                        {t('meta_data_batch_more')}
                      </li>
                    )
                  }
                })()}
              </ul>
            </div>
          </div>
        </div>
      </div>
    )
  }
})
