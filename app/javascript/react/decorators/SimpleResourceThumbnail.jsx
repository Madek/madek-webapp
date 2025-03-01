/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import ResourceThumbnail from './ResourceThumbnail.jsx'

module.exports = createReactClass({
  displayName: 'SimpleResourceThumbnail',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { type, title, authors_pretty, image_url } = param
    const get = {
      type,
      title,
      authors_pretty,
      image_url,
      disableLink: true
    }
    // NOTE: no token needed
    return <ResourceThumbnail authToken="" get={get} />
  }
})
