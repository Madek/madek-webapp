import React from 'react'
import { parse as parseUrl, format as buildUrl } from 'url'
import AsyncModal from './Collection/AsyncModal.jsx'
import SelectCollection from './Collection/SelectCollection.jsx'
import MediaEntryHeader from './MediaEntryHeader.jsx'
import Share from './Shared/Share.jsx'

class MediaEntryHeaderWithModal extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      selectCollectionModal: false,
      shareModal: false
    }
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
    return (
      <div style={{ margin: '0px', padding: '0px' }}>
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
}

export default MediaEntryHeaderWithModal
