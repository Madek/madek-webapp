/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import t from '../../../lib/i18n-translate.js'

import cx from 'classnames'

module.exports = createReactClass({
  displayName: 'HighlightedContents',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    if (
      f.isEmpty(
        get.highlighted_media_resources != null
          ? get.highlighted_media_resources.resources
          : undefined
      )
    ) {
      return null
    }

    return (
      <div className="ui-container midtone-darker bordered">
        <div className="ui-container inverted ui-toolbar phs pvx">
          <h2 className="ui-toolbar-header">{t('collection_highlighted_contents')}</h2>
        </div>
        <div className="ui-featured-entries ptl phm">
          <ul className="ui-featured-entries-list ui-resources tiles horizontal large">
            {f.map(
              f.union(
                f.filter(get.highlighted_media_resources.resources, { type: 'MediaEntry' }),
                f.filter(get.highlighted_media_resources.resources, { type: 'Collection' })
              ),
              (mediaResource, index) => (
                <HighlightedContent key={`key_${index}`} mediaResource={mediaResource} />
              )
            )}
          </ul>
        </div>
      </div>
    )
  }
})

var HighlightedContent = createReactClass({
  displayName: 'HighlightedContent',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { mediaResource } = param
    const iconMapping = { public: 'open', private: 'private', shared: 'group' }
    const iconName = `privacy-${iconMapping[mediaResource.privacy_status]}`

    const aClass = cx('ui-tile', { 'ui-tile--set': mediaResource.type === 'Collection' })

    const images =
      f.get(mediaResource, 'type') === 'Collection'
        ? f.get(mediaResource, 'cover')
        : f.get(mediaResource, 'media_file.previews.images')
    // smallest image that is smaller than wanted or the largest available:
    let image = f.findLast(images, i => i.width >= 300)
    if (!image) {
      image = f.first(f.where(images, i => i.width > 0))
    }

    console.error('No image!', { props: this.props })

    let imgProps = {}
    if (image) {
      imgProps = {
        src: image.url,
        srcSet: f
          .chain(images)
          .values()
          .uniq('url')
          .map(function ({ url, width }) {
            if (url && width) {
              return `${url} ${width}w`
            }
          })
          .compact()
          .value()
          .join(', ')
      }
    }
    imgProps.style = {
      backgroundColor: 'rgba(1.0, 1.0, 1.0, 0.3)', //'rgba(0, 0, 0, 0.3)',
      boxShadow: '0 0 150px #575757 inset',
      width: !image ? '300px' : undefined
    }

    return (
      <a className={aClass} href={mediaResource.url} style={{ marginLeft: '5px' }}>
        <div className="ui-tile__body">
          <div className="ui-tile__thumbnail">
            <img {...Object.assign({ className: 'ui-tile__image' }, imgProps)} />
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
})
