import React from 'react'

const WorthThumbnail = ({ imageUrl, hrefUrl, label, author }) => {
  return (
    <li
      className="ui-resource not-loaded-contexts"
      data-id="4f458313-acfc-4bf9-86ab-598ad036a60e"
      data-is-editable="true"
      data-is-manageable="false"
      data-media-type="set"
      data-title="Schweizer Filmexperimente 1950-1988, Restaurierung"
      data-type="media-set">
      <div className="ui-resource-body">
        <div className="ui-resource-thumbnail">
          <div className="ui-thumbnail media-set set">
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
              <h3 className="ui-thumbnail-meta-title">{label}</h3>
              <h4 className="ui-thumbnail-meta-subtitle">{author}</h4>
            </div>
          </div>
        </div>
      </div>
    </li>
  )
}

export default WorthThumbnail
module.exports = WorthThumbnail
