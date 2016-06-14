React = require('react')
classnames = require('classnames')


module.exports = React.createClass
  displayName: 'CatalogThumbnailShifted'
  render: ({imageUrl, count} = @props)->
    even = (count % 2 == 0)
    classes = classnames('ui-collage-item', { odd: !even }, { even: even })
    <div className={classes}>
      <div className="ui-collage-item-wrapper">
        <div className="ui-collage-item-table">
          <div className="ui-collage-item-cell">
            <div className="ui-collage-item-inner">
              <img className="ui-collage-item-image" src={imageUrl}></img>
            </div>
          </div>
        </div>
      </div>
    </div>
