import React from 'react'
import cx from 'classnames'

const CatalogThumbnailShifted = ({ imageUrl, count }) => {
  const even = count % 2 === 0
  const classes = cx('ui-collage-item', { odd: !even }, { even })

  return (
    <div className={classes}>
      <div className="ui-collage-item-wrapper">
        <div className="ui-collage-item-table">
          <div className="ui-collage-item-cell">
            <div className="ui-collage-item-inner">
              <img className="ui-collage-item-image" src={imageUrl} />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default CatalogThumbnailShifted
module.exports = CatalogThumbnailShifted
