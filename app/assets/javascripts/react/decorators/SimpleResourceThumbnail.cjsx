React = require('react')
ResourceThumbnail = require('./ResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'SimpleResourceThumbnail'

  render: ({type, title, authors_pretty, image_url} = @props) ->
    get = {
      type: type,
      title: title,
      authors_pretty: authors_pretty,
      image_url: image_url
      disableLink: true
    }
    # NOTE: no token needed
    <ResourceThumbnail authToken={''} get={get} />
