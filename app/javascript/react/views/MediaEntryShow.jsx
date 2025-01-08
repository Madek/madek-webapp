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
const appRequest = require('../../lib/app-request.js')

const UI = require('../ui-components/index.js')
const MadekPropTypes = require('../lib/madek-prop-types.js')
const MetaDataList = require('../decorators/MetaDataList.jsx')
const MediaEntryPreview = require('../decorators/MediaEntryPreview.jsx')
const MetaDataByListing = require('../decorators/MetaDataByListing.jsx')
const ResourceShowOverview = require('../templates/ResourceShowOverview.jsx')
const BrowseEntriesList = require('./MediaEntry/BrowseEntriesList.jsx')
const MediaEntrySiblings = require('./MediaEntry/MediaEntrySiblings.jsx').default

module.exports = React.createClass({
  displayName: 'Views.MediaEntryShow',
  propTypes: {
    get: React.PropTypes.shape({
      title: React.PropTypes.string.isRequired,
      url: React.PropTypes.string.isRequired,
      // image_url: React.PropTypes.string.isRequired
      meta_data: MadekPropTypes.resourceMetaData.isRequired,
      responsible: MadekPropTypes.user.isRequired
      // tabs: UI.propTypes.TabList.isRequired
      // more_data: React.PropTypes.object.isRequired
      // relations: React.PropTypes.object.isRequired
      // permissions: React.PropTypes.object.isRequired
    }).isRequired
  },

  getInitialState() {
    return {
      isClient: false,
      fetchedBrowseEntries: null
    }
  },

  componentDidMount() {
    this._isMounted = true
    this.setState({ active: true })
    if (!this.props.get.browse_url) {
      return
    }
    return (this._fetchingBrowseEntries = appRequest(
      { url: this.props.get.browse_url, sparse: { browse_resources: {} } },
      (err, res, data) => {
        if (!this._isMounted) {
          return
        }
        if (err && !data && !data.browse_resources) {
          console.error('Error while fetching browsable entries data!\n\n', err)
          return this.setState({ fetchedBrowseEntries: false })
        } else {
          return this.setState({ fetchedBrowseEntries: data.browse_resources })
        }
      }
    ))
  },

  componentWillUnmount() {
    this._isMounted = false
    if (this._fetchingBrowseEntries) {
      return this._fetchingBrowseEntries.abort()
    }
  },

  render(param, state) {
    if (param == null) {
      param = this.props
    }
    const { get, authToken } = param
    if (state == null) {
      ;({ state } = this)
    }
    const summaryContext = get.meta_data.entry_summary_context
    const listContexts = get.meta_data.contexts_for_entry_extra

    // overview has summary on the left and preview on the right
    const previewStyle = { width: '100%' }
    if (get.media_type !== 'video') {
      previewStyle.maxHeight = '500px'
    }
    const overview = {
      content: (
        <MetaDataList
          mods="ui-media-overview-metadata"
          tagMods="small"
          list={summaryContext}
          showTitle={false}
        />
      ),

      previewLg: (
        <MediaEntryPreview
          get={get}
          mediaProps={{ style: previewStyle }}
          mods="ui-media-overview-preview"
          withLink={true}
          withZoomLink={true}
        />
      )
    }

    const layout = {
      overview: (
        <ResourceShowOverview {...Object.assign({ mods: 'ui-media-overview' }, overview)} />
      ),
      moreInfo: f.present(listContexts) ? (
        <div className="ui-container midtone rounded-bottom pal well">
          <MetaDataByListing list={listContexts} />
        </div>
      ) : (
        undefined
      )
    }

    return (
      <div>
        <div className="ui-container tab-content bordered rounded-right rounded-bottom mbh">
          <div className="ui-container bright pal rounded-top-right">{layout.overview}</div>
          <div className="ui-container.rounded-bottom">{layout.moreInfo}</div>
        </div>
        {(() => {
          if (get.browse_url) {
            const browseHeader = (
              <h3 className="title-l pbl">
                {t('browse_entries_title')}{' '}
                <a href={get.browse_url} style={{ textDecoration: 'none' }}>
                  <UI.Icon i="link" />
                </a>
              </h3>
            )

            return (
              <div>
                <div className="no-js">
                  <a href={get.browse_url}>
                    <UI.Icon i="eye" /> {t('browse_entries_title')}
                  </a>
                </div>
                <div className="js-only">
                  <MediaEntrySiblings url={get.siblings_url} />
                  <div className="ui-container midtone bordered rounded mbh pam">
                    <BrowseEntriesList
                      isLoading={!state.fetchedBrowseEntries}
                      browse={state.fetchedBrowseEntries}
                      header={browseHeader}
                      authToken={authToken}
                    />
                  </div>
                </div>
              </div>
            )
          }
        })()}
      </div>
    )
  }
})
