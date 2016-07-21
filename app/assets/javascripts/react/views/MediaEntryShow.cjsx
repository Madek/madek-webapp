React = require('react')
f = require('active-lodash')
classList = require('classnames')
t = require('../../lib/string-translation')('de')

UI = require('../ui-components/index.coffee')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
MetaDataList = require('../decorators/MetaDataList.cjsx')
MediaEntryPreview = require('../decorators/MediaEntryPreview.cjsx')
MetaDataByListing = require('../decorators/MetaDataByListing.cjsx')
ResourceShowOverview = require('../templates/ResourceShowOverview.cjsx')

module.exports = React.createClass
  displayName: 'Views.MediaEntryShow'
  propTypes:
    get: React.PropTypes.shape(
      title: React.PropTypes.string.isRequired
      url: React.PropTypes.string.isRequired
      image_url: React.PropTypes.string.isRequired
      meta_data: MadekPropTypes.resourceMetaData.isRequired
      responsible: MadekPropTypes.user.isRequired
      # TODO: actually, those are tabs:
      # tabs: UI.propTypes.TabList.isRequired
      # more_data: React.PropTypes.object.isRequired # TODO
      # relations: React.PropTypes.object.isRequired # TODO
      # permissions: React.PropTypes.object.isRequired # TODO
    ).isRequired


  render: ({get} = @props)->
    # first is the summary vocab, rest from configured list:
    summaryContext = get.meta_data.entry_summary_context
    listContexts = get.meta_data.contexts_for_entry_extra
    # [summaryContext, listContexts] = [f.first(metaData, 1), f.drop(metaData, 1)]

    # overview has summary on the left and preview on the right
    overview =
      content: <MetaDataList
                  mods='ui-media-overview-metadata'
                  tagMods='small'
                  list={summaryContext} showTitle={false}/>
      previewLg: <MediaEntryPreview get={get} mods='ui-media-overview-preview-item'/>

    layout =
      overview: <ResourceShowOverview mods='ui-media-overview' {...overview}/>
      # TODO: topNotice: '[topNotice]'
      moreInfo: if f.present(listContexts)
        <div className='ui-container midtone rounded-bottom pal well'>
          <MetaDataByListing list={listContexts}/></div>


    # TODO: use <AppResourceLayout…/>, fake the boxes for now:

    {# complete box (under the title):}
    <div className='ui-container tab-content bordered rounded-right rounded-bottom mbh'>

      {# top part of the box:}
      <div className='ui-container bright pal rounded-top-right'>
        {layout.overview}
      </div>

      {# bottom part of the box:}
      <div className='ui-container.rounded-bottom'>
        {layout.moreInfo}
      </div>

    </div>
