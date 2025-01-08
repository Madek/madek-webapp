/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('lodash')
const t = require('../../../../lib/i18n-translate')

module.exports = React.createClass({
  displayName: 'CatalogThumbnail',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { imageUrl, hrefUrl, usageCount } = param
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
})
