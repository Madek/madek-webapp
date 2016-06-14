React = require('react')

module.exports = React.createClass
  displayName: 'CatalogThumbnail'
  render: ({imageUrl, hrefUrl, label, description, usageCount} = @props)->
    <li className="ui-resource">
      <div className="ui-thumbnail media-catalog">
        <div className="ui-thumbnail-privacy">
          <i className="icon-privacy-open" title="Diese Inhalte sind öffentlich zugänglich"></i>
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
          <h3 className="ui-thumbnail-meta-title">{label}</h3>
          <p className="ui-thumbnail-meta-subtitle">{description}</p>
          <span className="ui-thumbnail-meta-extension">{usageCount}</span>
        </div>
      </div>
    </li>
