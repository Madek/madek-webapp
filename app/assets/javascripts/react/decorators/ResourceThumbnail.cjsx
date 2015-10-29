React = require('react')
async = require('async')
f = require('active-lodash')
ampersandReactMixin = require('ampersand-react-mixin')
urlFromBrowserFile = require('../../lib/url-from-browser-file.coffee')
Icon = require('../ui-components/Icon.cjsx')
Thumbnail = require('../ui-components/Thumbnail.cjsx')

getUrlFromBrowserFileQueue = async.queue(urlFromBrowserFile, 1)

# async! will cause re-render with the new img, but only once per file:
localPreviewImage = (resource, callback)->
  # TODO: generic fallback images
  type = f.get(resource, 'uploading.file.type')
  switch
    when /image\//.test(type)
      getUrlFromBrowserFileQueue.push f.get(resource, 'uploading.file'), (url)->
        return callback({}) if not url
        callback(localPreview: url)
    else
      callback({})

module.exports = React.createClass
  displayName: 'ResourceThumbnail'
  mixins: [ampersandReactMixin]
  getInitialState: ()-> {active: true}
  componentDidMount: ()->
    localPreviewImage(@props.resource, @setState.bind(@))

  componentWillReceiveProps: (nextProps)->
    return if (@props.uploading?.file is nextProps.uploading?.file)
    localPreviewImage(nextProps.resource, @setState.bind(@))

  propTypes:
    resource: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry', 'Collection', 'FilterSet'])

  render: ({resource} = @props, state = @state)->
    # map the type name:
    type = resource.type.replace(/Collection/, 'MediaSet')
    props =
      type: f.kebabCase(type)
      src: resource.image_url or state.localPreview or '.'
      href: resource.url
      alt: resource.title
      privacy: resource.privacy_status
      meta:
        title: resource.title or resource.uploadStatus
      badgeLeft: if resource.type is 'FilterSet'
        <Icon i='filter' title='This is a Filterset'/>

    <Thumbnail {...props}/>
