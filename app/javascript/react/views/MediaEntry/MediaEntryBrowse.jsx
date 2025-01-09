/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const t = require('../../../lib/i18n-translate.js')
const PageHeader = require('../../ui-components/PageHeader')
const MetaDataList = require('../../decorators/MetaDataList.cjsx')
const ResourceThumbnail = require('../../decorators//ResourceThumbnail.cjsx')
const BrowseEntriesList = require('./BrowseEntriesList.cjsx')

module.exports = React.createClass({
  displayName: 'MediaEntryBrowse',

  render(props) {
    if (props == null) {
      ;({ props } = this)
    }
    const { get, authToken } = props
    return (
      <div>
        <PageHeader icon="eye" title={t('browse_entries_title')} />
        <div className="bordered ui-container midtone rounded-right rounded-bottom table">
          <div className="app-body-sidebar table-cell bright ui-container bordered-right rounded-bottom-left table-side">
            <div className="ui-container rounded-left phm pvl">
              <SideBarContent {...Object.assign({}, props)} />
              <div className="ui-fadeout-right" role="presentation" />
            </div>
          </div>
          <div className="app-body-content table-cell table-substance ui-container">
            <div className="ui-container pal">
              <BrowseEntriesList browse={get.browse_resources} authToken={authToken} />
            </div>
          </div>
        </div>
      </div>
    )
  }
})

var SideBarContent = function({ get, authToken }) {
  let entry, summaryContext
  return (
    ({ entry } = get),
    (summaryContext = get.entry_meta_data.entry_summary_context),
    (
      <div>
        <div className="mbm">
          <ResourceThumbnail get={entry} authToken={authToken} isClient={false} />
        </div>
        <MetaDataList
          mods="ui-media-overview-metadata"
          tagMods="small"
          list={summaryContext}
          showTitle={false}
        />
      </div>
    )
  )
}
