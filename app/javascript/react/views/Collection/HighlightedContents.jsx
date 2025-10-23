import React from 'react'
import t from '../../../lib/i18n-translate.js'
import cx from 'classnames'
import { isEmpty, get as utilGet } from '../../../lib/utils.js'

class HighlightedContents extends React.Component {
  render() {
    const { get } = this.props
    if (isEmpty(get.highlighted_media_resources && get.highlighted_media_resources.resources)) {
      return null
    }

    const mediaEntries = get.highlighted_media_resources.resources.filter(
      r => r.type === 'MediaEntry'
    )
    const collections = get.highlighted_media_resources.resources.filter(
      r => r.type === 'Collection'
    )
    const combined = [...mediaEntries, ...collections]

    return (
      <div className="ui-container midtone-darker bordered">
        <div className="ui-container inverted ui-toolbar phs pvx">
          <h2 className="ui-toolbar-header">{t('collection_highlighted_contents')}</h2>
        </div>
        <div className="ui-featured-entries ptl phm">
          <ul className="ui-featured-entries-list ui-resources tiles horizontal large">
            {combined.map((mediaResource, index) => (
              <HighlightedContent key={`key_${index}`} mediaResource={mediaResource} />
            ))}
          </ul>
        </div>
      </div>
    )
  }
}

class HighlightedContent extends React.Component {
  render() {
    const { mediaResource } = this.props
    const iconMapping = { public: 'open', private: 'private', shared: 'group' }
    const iconName = `privacy-${iconMapping[mediaResource.privacy_status]}`

    const aClass = cx('ui-tile', { 'ui-tile--set': mediaResource.type === 'Collection' })

    const images =
      utilGet(mediaResource, 'type') === 'Collection'
        ? utilGet(mediaResource, 'cover', [])
        : utilGet(mediaResource, 'media_file.previews.images', [])

    // smallest image that is smaller than wanted or the largest available:
    let image = images.filter(i => i.width >= 300).slice(-1)[0]
    if (!image) {
      image = images.filter(i => i.width > 0)[0]
    }

    if (!image) {
      // eslint-disable-next-line no-console
      console.error('No image!', { props: this.props })
    }

    let imgProps = {}
    if (image) {
      const uniqueImages = images.filter(
        (img, index, self) => index === self.findIndex(i => i.url === img.url)
      )
      const srcSetParts = uniqueImages
        .map(({ url, width }) => {
          if (url && width) {
            return `${url} ${width}w`
          }
          return null
        })
        .filter(Boolean)

      imgProps = {
        src: image.url,
        srcSet: srcSetParts.join(', ')
      }
    }
    imgProps.style = {
      backgroundColor: 'rgba(1.0, 1.0, 1.0, 0.3)',
      boxShadow: '0 0 150px #575757 inset',
      width: !image ? '300px' : undefined
    }

    return (
      <a className={aClass} href={mediaResource.url} style={{ marginLeft: '5px' }}>
        <div className="ui-tile__body">
          <div className="ui-tile__thumbnail">
            <img {...{ className: 'ui-tile__image', ...imgProps }} />
          </div>
        </div>
        <div className="ui-tile__foot">
          <h3 className="ui-tile__title">{mediaResource.title}</h3>
          <h4 className="ui-tile__meta">{mediaResource.authors_pretty}</h4>
          <span className="ui-tile__flags">
            <i className={`icon-${iconName}`} title={mediaResource.privacy_status} />
          </span>
        </div>
      </a>
    )
  }
}

export default HighlightedContents
module.exports = HighlightedContents
