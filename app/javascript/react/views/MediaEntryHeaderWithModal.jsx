/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import { parse as parseUrl, format as buildUrl } from 'url'
import AsyncModal from './Collection/AsyncModal.jsx'
import SelectCollection from './Collection/SelectCollection.jsx'
import MediaEntryHeader from './MediaEntryHeader.jsx'
import Share from './Shared/Share.jsx'

module.exports = createReactClass({
  displayName: 'MediaEntryHeaderWithModal',

  getInitialState() {
    return {
      selectCollectionModal: false,
      shareModal: false
    }
  },

  _onClick(asyncAction) {
    if (asyncAction === 'select_collection') {
      return this.setState({ selectCollectionModal: true })
    } else if (asyncAction === 'share') {
      return this.setState({ shareModal: true })
    }
  },

  render(param) {
    let authToken
    let onClose, contentForGet, get, extractGet, getUrl
    if (param == null) {
      param = this.props
    }
    ;({ authToken, get } = param)
    return (
      <div style={{ margin: '0px', padding: '0px' }}>
        {(() => {
          if (this.state.selectCollectionModal) {
            onClose = () => {
              return this.setState({ selectCollectionModal: false })
            }

            contentForGet = get => {
              return (
                <SelectCollection
                  get={get}
                  async={true}
                  authToken={this.props.authToken}
                  onClose={onClose}
                />
              )
            }

            extractGet = json => {
              return json.collection_selection
            }

            getUrl = () => {
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
            onClose = () => {
              return this.setState({ shareModal: false })
            }

            contentForGet = get => {
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

            extractGet = json => {
              return json
            }

            getUrl = get.header.share_url
            return (
              <AsyncModal
                get={null}
                getUrl={getUrl}
                widthInPixel={800}
                contentForGet={contentForGet}
                extractGet={extractGet}
              />
            )
          }
        })()}
        <MediaEntryHeader
          authToken={authToken}
          get={get.header}
          async={true}
          onClick={this._onClick}
        />
      </div>
    )
  }
})
