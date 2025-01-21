/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'

module.exports = createReactClass({
  displayName: 'PrettyThumbs',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { imageUrl, hrefUrl, label, author } = param
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
})
