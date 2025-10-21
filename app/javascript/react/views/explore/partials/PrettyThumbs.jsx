import React from 'react'

const PrettyThumbs = ({ imageUrl, hrefUrl, label, author }) => {
  return (
    <a className="ui-collage-item" href={hrefUrl}>
      <div className="ui-collage-item-wrapper">
        <div className="ui-collage-item-table">
          <div className="ui-collage-item-cell">
            <div className="ui-collage-item-inner">
              <img className="ui-collage-item-image" src={imageUrl} />
            </div>
          </div>
        </div>
        <div className="ui-collage-item-meta">
          <h3 className="title-xs">{label}</h3>
          <h4 className="title-xs-alt">{author}</h4>
        </div>
      </div>
    </a>
  )
}

export default PrettyThumbs
module.exports = PrettyThumbs
