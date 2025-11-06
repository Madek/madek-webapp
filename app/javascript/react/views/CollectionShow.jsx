import React from 'react'
import f from 'lodash'
import { parse as parseUrl, format as buildUrl } from 'url'
import t from '../../lib/i18n-translate.js'
import RightsManagement from '../templates/ResourcePermissions.jsx'
import CollectionRelations from './Collection/Relations.jsx'
import RelationResources from './Collection/RelationResources.jsx'
import Tabs from './Tabs.jsx'
import Tab from './Tab.jsx'
import PageContent from './PageContent.jsx'
import TabContent from './TabContent.jsx'
import CollectionDetailOverview from './Collection/DetailOverview.jsx'
import CollectionDetailAdditional from './Collection/DetailAdditional.jsx'
import AsyncModal from './Collection/AsyncModal.jsx'
import SelectCollection from './Collection/SelectCollection.jsx'
import HighlightedContents from './Collection/HighlightedContents.jsx'
import MediaEntryHeader from './MediaEntryHeader.jsx'
import MetaDataByListing from '../decorators/MetaDataByListing.jsx'
import UsageData from '../decorators/UsageData.jsx'
import Share from './Shared/Share.jsx'

const WORKFLOW_STATES = { IN_PROGRESS: 'IN_PROGRESS', FINISHED: 'FINISHED' }

const parseUrlState = function (location) {
  const urlParts = f.slice(parseUrl(location).pathname.split('/'), 1)
  if (urlParts.length < 3) {
    return { action: 'show', argument: null }
  } else {
    return {
      action: urlParts[2],
      argument: urlParts.length > 3 ? urlParts[3] : undefined
    }
  }
}

const contentTestId = id => `set_tab_content_${id}`

const tabTestId = id => `set_tab_${id}`

class CollectionShow extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      isMounted: false,
      urlState: parseUrlState(this.props.for_url),
      selectCollectionModal: false,
      shareModal: false
    }
  }

  componentDidMount() {
    return this.setState({ isMounted: true })
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    if (nextProps.for_url === this.props.for_url) {
      return
    }
    return this.setState({ urlState: parseUrlState(this.props.for_url) })
  }

  _onClick = asyncAction => {
    if (asyncAction === 'select_collection') {
      return this.setState({ selectCollectionModal: true })
    } else if (asyncAction === 'share') {
      return this.setState({ shareModal: true })
    }
  }

  render() {
    const { authToken, get } = this.props
    const { isMounted, urlState } = this.state
    return (
      <PageContent>
        {(() => {
          if (this.state.selectCollectionModal) {
            const onClose = () => {
              return this.setState({ selectCollectionModal: false })
            }

            const contentForGet = get => {
              return (
                <SelectCollection
                  get={get}
                  async={true}
                  authToken={this.props.authToken}
                  onClose={onClose}
                />
              )
            }

            const extractGet = json => {
              return json.collection_selection
            }

            const getUrl = () => {
              const parsedUrl = parseUrl(get.header.select_collection_url, true)
              delete parsedUrl.search
              parsedUrl.query['___sparse'] = '{collection_selection:{}}'
              return buildUrl(parsedUrl)
            }

            return (
              <AsyncModal
                get={get.collection_selection}
                getUrl={getUrl()}
                contentForGet={contentForGet}
                extractGet={extractGet}
              />
            )
          }
        })()}
        {(() => {
          if (this.state.shareModal) {
            const onClose = () => {
              return this.setState({ shareModal: false })
            }

            const contentForGet = get => {
              return (
                <Share
                  fullPage={false}
                  get={get}
                  async={true}
                  authToken={this.props.authToken}
                  onClose={onClose}
                />
              )
            }

            const extractGet = json => {
              return json
            }

            const getUrl = get.header.share_url
            return (
              <AsyncModal
                widthInPixel={800}
                get={null}
                getUrl={getUrl}
                contentForGet={contentForGet}
                extractGet={extractGet}
              />
            )
          }
        })()}
        <MediaEntryHeader
          authToken={authToken}
          get={get.header}
          async={isMounted}
          onClick={this._onClick}
        />
        <Tabs>
          {f.map(get.tabs, tab => (
            <Tab
              key={tab.id}
              href={tab.href}
              testId={tabTestId(tab.id)}
              iconType={tab.icon_type}
              privacyStatus={get.privacy_status}
              label={tab.label}
              active={tab.id === get.active_tab}
            />
          ))}
        </Tabs>
        {(() => {
          switch (urlState.action) {
            case 'relations':
              switch (get.action) {
                case 'relations':
                  return (
                    <CollectionRelations
                      get={get}
                      authToken={authToken}
                      testId={contentTestId('relations')}
                    />
                  )
                case 'relation_parents':
                  return (
                    <RelationResources
                      get={get}
                      authToken={authToken}
                      scope="parents"
                      testId={contentTestId('relations_parents')}
                    />
                  )
                case 'relation_children':
                  return (
                    <RelationResources
                      get={get}
                      authToken={authToken}
                      scope="children"
                      testId={contentTestId('relations_children')}
                    />
                  )
                case 'relation_siblings':
                  return (
                    <RelationResources
                      get={get}
                      authToken={authToken}
                      scope="siblings"
                      testId={contentTestId('relations_siblings')}
                    />
                  )
              }
              break

            case 'usage_data':
              return (
                <TabContent testId={contentTestId('usage_data')}>
                  <div className="bright pal rounded-bottom rounded-top-right ui-container">
                    {get.logged_in ? <UsageData get={get} /> : undefined}
                  </div>
                </TabContent>
              )

            case 'more_data':
              return (
                <TabContent testId={contentTestId('more_data')}>
                  <div className="bright pal rounded-bottom rounded-top-right ui-container">
                    <div className="ui-container">
                      <h3 className="title-l mbl">{t('media_entry_all_metadata_title')}</h3>
                      <MetaDataByListing
                        list={get.all_meta_data}
                        vocabLinks={true}
                        hideSeparator={true}
                      />
                    </div>
                  </div>
                </TabContent>
              )

            case 'permissions':
              return (
                <TabContent testId={contentTestId('permissions')}>
                  <div className="bright pal rounded-bottom rounded-top-right ui-container">
                    {f.get(get, 'workflow.status') === WORKFLOW_STATES.IN_PROGRESS && (
                      <div className="ui-alert">
                        As this Set is part of the workflow
                        <a href={get.workflow.actions.edit.url}>&quot;{get.workflow.name}&quot;</a>,
                        managing permissions is available only by changing common settings on
                        workflow edit page which will be applied after finishing it.
                      </div>
                    )}
                    {f.get(get, 'workflow.status') !== WORKFLOW_STATES.IN_PROGRESS && (
                      <RightsManagement authToken={this.props.authToken} get={get.permissions} />
                    )}
                  </div>
                </TabContent>
              )

            case 'context':
              return (
                <TabContent testId={contentTestId(`context_${urlState.argument}`)}>
                  <CollectionDetailOverview get={get} authToken={authToken} />
                  <HighlightedContents get={get} authToken={authToken} />
                  <CollectionDetailAdditional get={get} authToken={authToken} />
                </TabContent>
              )

            // main tab:
            default:
              return (
                <TabContent testId={contentTestId('show')}>
                  <CollectionDetailOverview get={get} authToken={authToken} />
                  <HighlightedContents get={get} authToken={authToken} />
                  <CollectionDetailAdditional get={get} authToken={authToken} />
                </TabContent>
              )
          }
        })()}
      </PageContent>
    )
  }
}

export default CollectionShow
module.exports = CollectionShow
