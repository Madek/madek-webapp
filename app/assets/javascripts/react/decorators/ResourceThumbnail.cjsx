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

  render: ({get} = @props, state = @state)->
    # map the type name:
    type = get.type.replace(/Collection/, 'MediaSet')
    props =
      type: f.kebabCase(type)
      src: get.image_url or state.localPreview or '.'
      href: get.url
      alt: get.title
      meta:
        title: get.title or get.uploadStatus
      badgeLeft:
        <Icon i={"privacy-#{get.privacy_status}"} title={get.privacy_status}/>
      badgeRight: if get.type is 'FilterSet'
        <Icon i='filter' title='This is a Filterset'/>

    <Thumbnail {...props}/>
