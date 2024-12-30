React = require('react')
f = require('lodash')
t = require('../../../../lib/i18n-translate')

module.exports = React.createClass
  displayName: 'CatalogThumbnail'

  render: ({imageUrl, hrefUrl, usageCount} = @props)->
    <div className="ui-thumbnail media-catalog" style={{display: 'table-cell'}}>
      <div className="ui-thumbnail-privacy">
        <i className="icon-privacy-open" title={t('contents_privacy_public')}></i>
      </div>
      <a className="ui-thumbnail-image-wrapper" href={hrefUrl}>
        <div className="ui-thumbnail-image-holder">
          <div className="ui-thumbnail-table-image-holder">
            <div className="ui-thumbnail-cell-image-holder">
              <div className="ui-thumbnail-inner-image-holder">
                <img className="ui-thumbnail-image" src={imageUrl}></img>
              </div>
            </div>
          </div>
        </div>
      </a>
      <div className="ui-thumbnail-meta">
        <span className="ui-thumbnail-meta-extension">{usageCount}</span>
      </div>
    </div>
