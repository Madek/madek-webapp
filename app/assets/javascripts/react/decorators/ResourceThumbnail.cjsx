React = require('react')
async = require('async')
f = require('active-lodash')
ampersandReactMixin = require('ampersand-react-mixin')
urlFromBrowserFile = require('../../lib/url-from-browser-file.coffee')
{Icon, Thumbnail} = require('../ui-components/index.coffee')

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

  render: ({get, elm} = @props, state = @state)->
    # map the type name:
    type = get.type.replace(/Collection/, 'MediaSet')
    # map the privacy icon:
    # see <http://madek.readthedocs.org/en/latest/entities/#privacy-status>
    # vs <http://test.madek.zhdk.ch/styleguide/Icons#6.2>
    iconMapping = {'public': 'open', 'private': 'private', 'shared': 'group'}
    privacyIcon = "privacy-#{iconMapping[get.privacy_status]}"

    Element = elm or 'div'
    props =
      type: f.kebabCase(type)
      src: get.image_url or state.localPreview or '.'
      href: get.url
      alt: get.title
      meta:
        title: get.title or get.uploadStatus
      badgeLeft:
        <Icon i={privacyIcon} title={get.privacy_status}/>
      badgeRight: if get.type is 'FilterSet'
        <Icon i='filter' title='This is a Filterset'/>

    <Element className='ui-resource'>
      <div className='ui-resource-body'>
        <Thumbnail {...props}/>
      </div>
    </Element>
