React = require('react')
async = require('async')
f = require('active-lodash')
ampersandReactMixin = require('ampersand-react-mixin')
urlFromBrowserFile = require('../../lib/url-from-browser-file.coffee')
{Icon, Thumbnail} = require('../ui-components/index.coffee')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
Models = require('../../models/index.coffee')
RailsForm = require('../lib/forms/rails-form.cjsx')
Button = require('../ui-components/Button.cjsx')

module.exports = React.createClass
  displayName: 'ResourceThumbnail'
  mixins: [ampersandReactMixin]
  propTypes:
    authToken: React.PropTypes.string
    get: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry', 'Collection', 'FilterSet'])
    # TODO: consilidate with `get` (when used in uploader)
    resource: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry'])

  getInitialState: ()-> {
    active: false
    pendingFavorite: false
  }
  componentDidMount: ()->
    localPreviewImage(@props.resource, @setState.bind(@))
    model = new Models[@props.get.type](@props.get)
    @setState(active: true, model: model)

  componentWillReceiveProps: (nextProps)->
    return if (@props.uploading?.file is nextProps.uploading?.file)
    localPreviewImage(nextProps.resource, @setState.bind(@))

  _favorOnClick: () ->
    @setState(pendingFavorite: true)
    action = if @state.model.favored then 'disfavor' else 'favor'
    @state.model.setFavoredStatus action, (err, res)=>
      @setState(pendingFavorite: false)

  renderItem: (item) ->
    clazz = "ui-thumbnail-level-item media_set set odd"
    if item.type == 'MediaEntry'
      clazz = "ui-thumbnail-level-item media_entry image odd"
    <li className={clazz}>
      <a className="ui-level-image-wrapper" href={item.url}>
        <div className="ui-thumbnail-level-image-holder">
          <img className="ui-thumbnail-level-image" src={item.image_url}></img>
        </div>
      </a>
    </li>

  render: ({get, elm, authToken} = @props, state = @state)->
    # get = @state.model or @props.get
    model = @state.model or @props.get

    # map the type name:
    type = get.type.replace(/Collection/, 'MediaSet')
    # map the privacy icon:
    # see <http://madek.readthedocs.org/en/latest/entities/#privacy-status>
    # vs <http://test.madek.zhdk.ch/styleguide/Icons#6.2>
    iconMapping = {'public': 'open', 'private': 'private', 'shared': 'group'}
    privacyIcon = "privacy-#{iconMapping[get.privacy_status]}"

    # fav
    favoriteAction = if model.favored then 'disfavor' else 'favor'
    favoriteUrl = model.url + '/' + favoriteAction

    starClass = if model.favored then 'icon-star' else 'icon-star-empty'
    favoriteItem = <i className={starClass}></i>
    favoriteOnClick = @_favorOnClick if not @state.pendingFavorite

    actionsLeft = []
    actionsRight = []

    parents = @props.get.parent_relations
    children = @props.get.child_relations

    parentsCount = @props.get.parent_count
    childrenCount = @props.get.child_count

    parentRelations = []
    childRelations = []
    if parentsCount > 0
      parentRelations = parents.resources.map (item)->
        <li className="ui-thumbnail-level-item media_set set odd">
          <a className="ui-level-image-wrapper" href={item.url}>
            <div className="ui-thumbnail-level-image-holder">
              <img className="ui-thumbnail-level-image" src={item.image_url}></img>
            </div>
          </a>
        </li>

    if childrenCount > 0
      childRelations = children.resources.map (item) =>
        @renderItem(item)

    if get.favorite_policy
      favorButton =
        if @state.active
          <Button className='ui-thumbnail-action-favorite' onClick={favoriteOnClick}
            data-pending={@state.pendingFavorite}>
            {favoriteItem}
          </Button>
        else
          <RailsForm name='resource_meta_data' action={favoriteUrl}
            method='patch' authToken={authToken}>
            <button className='ui-thumbnail-action-favorite' type='submit'>
              {favoriteItem}
            </button>
          </RailsForm>

      actionsLeft.push(
        <li key='favorite' className='ui-thumbnail-action'>
          {favorButton}
        </li>)

    Element = elm or 'div'
    thumbProps =
      type: f.kebabCase(type)
      mods: ['video'] if get.media_type is 'video'
      src: get.image_url or state.localPreview or '.'
      href: get.url
      alt: get.title
      meta:
        title: get.title or get.uploadStatus
      badgeLeft:
        <Icon i={privacyIcon} title={get.privacy_status}/>
      badgeRight: if get.type is 'FilterSet'
        <Icon i='filter' title='This is a Filterset'/>
      actionsLeft: actionsLeft
      actionsRight: actionsRight
      showRelations: get.show_relations
      parentsCount: parentsCount
      childrenCount: childrenCount
      parentRelations: parentRelations
      childRelations: childRelations

    <Element className='ui-resource'>
      <div className='ui-resource-body'>
        <Thumbnail {...thumbProps}/>
      </div>
    </Element>

# helpers

# async! will cause re-render with the new img, but only once per file:
getUrlFromBrowserFileQueue = async.queue(urlFromBrowserFile, 1)
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
