import React from 'react'
import t from '../../../../lib/i18n-translate.js'

const CatalogThumbnail = ({ imageUrl, hrefUrl, usageCount }) => {
  return (
    <div className="ui-thumbnail media-catalog" style={{ display: 'table-cell' }}>
      <div className="ui-thumbnail-privacy">
        <i className="icon-privacy-open" title={t('contents_privacy_public')} />
      </div>
      <a className="ui-thumbnail-image-wrapper" href={hrefUrl}>
        <div className="ui-thumbnail-image-holder">
          <div className="ui-thumbnail-table-image-holder">
            <div className="ui-thumbnail-cell-image-holder">
              <div className="ui-thumbnail-inner-image-holder">
                <img className="ui-thumbnail-image" src={imageUrl} />
              </div>
            </div>
          </div>
        </div>
      </a>
      <div className="ui-thumbnail-meta">
        <span className="ui-thumbnail-meta-extension">{usageCount}</span>
      </div>
    </div>
  )
}

export default CatalogThumbnail
module.exports = CatalogThumbnail
