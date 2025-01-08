/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const classnames = require('classnames')

module.exports = React.createClass({
  displayName: 'CatalogThumbnailShifted',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { imageUrl, count } = param
    const even = count % 2 === 0
    const classes = classnames('ui-collage-item', { odd: !even }, { even })
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
