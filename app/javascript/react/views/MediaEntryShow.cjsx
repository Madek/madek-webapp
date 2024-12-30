React = require('react')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')
appRequest = require('../../lib/app-request.coffee')

UI = require('../ui-components/index.coffee')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
MetaDataList = require('../decorators/MetaDataList.cjsx')
MediaEntryPreview = require('../decorators/MediaEntryPreview.jsx')
MetaDataByListing = require('../decorators/MetaDataByListing.cjsx')
ResourceShowOverview = require('../templates/ResourceShowOverview.cjsx')
BrowseEntriesList = require('./MediaEntry/BrowseEntriesList.cjsx')
MediaEntrySiblings = require('./MediaEntry/MediaEntrySiblings.jsx').default

module.exports = React.createClass
  displayName: 'Views.MediaEntryShow'
  propTypes:
    get: React.PropTypes.shape(
      title: React.PropTypes.string.isRequired
      url: React.PropTypes.string.isRequired
      # image_url: React.PropTypes.string.isRequired
      meta_data: MadekPropTypes.resourceMetaData.isRequired
      responsible: MadekPropTypes.user.isRequired
      # TODO: actually, those are tabs:
      # tabs: UI.propTypes.TabList.isRequired
      # more_data: React.PropTypes.object.isRequired # TODO
      # relations: React.PropTypes.object.isRequired # TODO
      # permissions: React.PropTypes.object.isRequired # TODO
    ).isRequired

  getInitialState: ()-> {
    isClient: false,
    fetchedBrowseEntries: null
  }

  componentDidMount: ()->
    @_isMounted = true
    @setState(active: true)
    return unless !!@props.get.browse_url
    @_fetchingBrowseEntries = appRequest(
      { url: @props.get.browse_url, sparse: { browse_resources: {} } },
      (err, res, data) =>
        return if not @_isMounted
        if err && !data && !data.browse_resources
          console.error('Error while fetching browsable entries data!\n\n', err)
          @setState(fetchedBrowseEntries: false)
        else
          @setState(fetchedBrowseEntries: data.browse_resources))

  componentWillUnmount: ()->
    @_isMounted = false
    if @_fetchingBrowseEntries then @_fetchingBrowseEntries.abort()

  render: ({get, authToken} = @props, state = @state)->
    summaryContext = get.meta_data.entry_summary_context
    listContexts = get.meta_data.contexts_for_entry_extra

    # overview has summary on the left and preview on the right
    previewStyle = {width: '100%'}
    previewStyle.maxHeight = '500px' unless get.media_type == 'video'
    overview =
      content: <MetaDataList
                  mods='ui-media-overview-metadata'
                  tagMods='small'
                  list={summaryContext} showTitle={false}/>

      previewLg: <MediaEntryPreview
        get={get}
        mediaProps={{style: previewStyle}}
        mods='ui-media-overview-preview'
        withLink
        withZoomLink
        />

    layout =
      overview: <ResourceShowOverview mods='ui-media-overview' {...overview}/>
      # TODO: topNotice: '[topNotice]'
      moreInfo: if f.present(listContexts)
        <div className='ui-container midtone rounded-bottom pal well'>
          <MetaDataByListing list={listContexts} /></div>

    # TODO: use <AppResourceLayout…/>, fake the boxes for now:

    {# complete box (under the title):}
    <div>
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

      {if get.browse_url
        browseHeader = <h3 className='title-l pbl'>
          {t('browse_entries_title')}{' '}
          <a href={get.browse_url} style={{textDecoration: 'none'}}>
            <UI.Icon i='link' />
          </a>
        </h3>

        <div>
          <div className='no-js'>
            <a href={get.browse_url}>
              <UI.Icon i='eye'/> {t('browse_entries_title')}
            </a>
          </div>
          <div className='js-only'>
            <MediaEntrySiblings url={get.siblings_url}/>

            <div className='ui-container midtone bordered rounded mbh pam'>

              <BrowseEntriesList
                isLoading={!state.fetchedBrowseEntries}
                browse={state.fetchedBrowseEntries}
                header={browseHeader}
                authToken={authToken}
              />
            </div>
          </div>
        </div>
      }

    </div>
