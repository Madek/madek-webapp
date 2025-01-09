/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const t = require('../../lib/i18n-translate.js')
const ResourceThumbnail = require('../decorators/ResourceThumbnail.cjsx')

module.exports = React.createClass({
  displayName: 'ResourcesBatchBox',
  propTypes: {
    resources: React.PropTypes.array.isRequired,
    authToken: React.PropTypes.string.isRequired
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

                    const text = `+${batchCount - resources.length} ${t('meta_data_batch_more')}`

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
