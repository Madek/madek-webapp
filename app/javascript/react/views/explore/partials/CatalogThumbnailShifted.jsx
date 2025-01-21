/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import cx from 'classnames'

module.exports = createReactClass({
  displayName: 'CatalogThumbnailShifted',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { imageUrl, count } = param
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
})
