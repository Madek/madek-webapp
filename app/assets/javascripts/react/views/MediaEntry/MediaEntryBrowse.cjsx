React = require('react')

PageHeader = require('../../ui-components/PageHeader')
MetaDataList = require('../../decorators/MetaDataList.cjsx')
ResourceThumbnail = require('../../decorators//ResourceThumbnail.cjsx')
BrowseEntriesList = require('./BrowseEntriesList.cjsx')

module.exports = React.createClass({
  displayName: 'MediaEntryBrowse',

  render: (props = this.props) ->
    {get, authToken} = props
    <div>

      <PageHeader icon='eye' title='Nach ähnlichen Inhalten stöbern' />

      <div className='bordered ui-container midtone rounded-right rounded-bottom table'>
        <div className='app-body-sidebar table-cell bright ui-container bordered-right rounded-bottom-left table-side'>
          <div className='ui-container rounded-left phm pvl'>
            <SideBarContent {...props} />
            <div className='ui-fadeout-right' role='presentation' />
          </div>
        </div>

        <div className='app-body-content table-cell table-substance ui-container'>
          <div className='ui-container mbh pam'>
            <BrowseEntriesList browse={get.browse_resources} authToken={authToken}/>
          </div>
        </div>

      </div>
    </div>
})


SideBarContent = ({get, authToken}) -> (
  {entry} = get
  summaryContext = get.entry_meta_data.entry_summary_context
  <div>
    <div className='mbm'>
      <ResourceThumbnail
        get={entry}
        authToken={authToken} isClient={false}
      />
    </div>
    <MetaDataList
      mods='ui-media-overview-metadata'
      tagMods='small'
      list={summaryContext} showTitle={false}/>
  </div>
)
