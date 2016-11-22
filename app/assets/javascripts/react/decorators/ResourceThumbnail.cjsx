React = require('react')
async = require('async')
f = require('active-lodash')
cx = require('classnames')
ampersandReactMixin = require('ampersand-react-mixin')
t = require('../../lib/string-translation')('de')
Models = require('../../models/index.coffee')
{ Link, Icon, Thumbnail, Button, Preloader, AskModal
} = require('../ui-components/index.coffee')
ResourceThumbnailRenderer = require('./ResourceThumbnailRenderer.cjsx')
PinThumbnail = require('./PinThumbnail.cjsx')
ListThumbnail = require('./ListThumbnail.cjsx')
ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
Picture = require('../ui-components/Picture.cjsx')

CURSOR_SELECT_STYLE = {cursor: 'cell'}

module.exports = React.createClass
  displayName: 'ResourceThumbnail'
  mixins: [ampersandReactMixin]
  propTypes:
    authToken: React.PropTypes.string
    onSelect: React.PropTypes.func
    onClick: React.PropTypes.func
    fetchRelations: React.PropTypes.bool
    elm: React.PropTypes.string # type of html node of outer wrapper
    get: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry', 'Collection', 'FilterSet'])
    # TODO: consilidate with `get` (when used in uploader)
    resource: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry'])

  getInitialState: ()-> {
    isClient: @props.isClient or false
    pendingFavorite: false
    deleteModal: false
  }

  componentWillMount: ()->
    # instantiate model from data if not already…
    get = @props.get
    unless (get.isState or get.isCollection)
      if (modelByType = Models[get.type])
        model = new modelByType(get)
      else
        # FIXME: throw this
        console.error('WARNING: No model found for resource!', get)
    @setState(model: model or get)

  componentDidMount: ()->
    @setState(isClient: true)

  _fetchRelations: ()-> # for hover/flyouts
    model = @state.model
    return console.error('No model found in state!') unless model
    return console.error('Not implemented for model!') unless model.fetchRelations
    return if @state.fetchingRelations

    typesToFetch = ['parent']
    typesToFetch.push('child') if (model.type is 'Collection')

    # NOTE: setting state.fetchingRelations also forces view update!
    @setState(fetchingRelations: typesToFetch)
    async.each(typesToFetch, ((typeToFetch, next)=>
      model.fetchRelations typeToFetch, (err, res)=>
        if @isMounted() then @setState(
          fetchingRelations: f.without(@state.fetchingRelations, typeToFetch))
        next(err, res)),
      (err)=> @setState(fetchingRelations: false) if @isMounted())

  _onHover: ()->
    @_fetchRelations() if @props.fetchRelations

  _favorOnClick: () ->
    @setState(pendingFavorite: true)
    action = if @state.model.favored then 'disfavor' else 'favor'
    @state.model.setFavoredStatus action, (err, res)=>
      @setState(pendingFavorite: false) if @isMounted()

  _showModal: () ->
    @setState(deleteModal: true)

  _onModalOk: () ->
    @state.model.delete (err, res)->
      location.reload()

  _onModalCancel: () ->
    @setState(deleteModal: false)

  render: ({get, elm, onClick, isSelected, fetchRelations, authToken} = @props, state = @state)->
    model = @state.model or @props.get


    if fetchRelations
      parentRelations = f.get(model, 'parent_collections')
      childRelations = f.get(model, 'child_media_resources')

      if parentRelations
        parentsCount = parentRelations.pagination.total_count
        parentsCountText = parentsCount + ' Sets'

        if parentsCount > 0
          parentThumbs = f.get(parentRelations, 'resources').map (item) ->
            <li className='ui-thumbnail-level-item media_set set odd' key={item.uuid}>
              <a className='ui-level-image-wrapper' href={item.url}>
                <div className='ui-thumbnail-level-image-holder'>
                  <FlyoutImage resourceType={item.type} title={item.title}
                    imageUrl={item.image_url} mediaType={item.media_type} />
                </div>
              </a>
            </li>

      if childRelations
        childrenCount = childRelations.pagination.total_count
        childrenCountText = childrenCount + ' Inhalte'

        if childrenCount > 0
          childThumbs = f.get(childRelations, 'resources').map (item) ->
            classes = 'ui-thumbnail-level-item media_set set odd'
            if item.type == 'MediaEntry'
              classes = 'ui-thumbnail-level-item media_entry image odd'
            <li className={classes} key={item.uuid}>
              <a className='ui-level-image-wrapper' href={item.url}>
                <div className='ui-thumbnail-level-image-holder'>
                  <FlyoutImage resourceType={item.type} title={item.title}
                    imageUrl={item.image_url} mediaType={item.media_type} />
                </div>
              </a>
            </li>

    relationsProps = {
      onHover: @_onHover
      parent: if fetchRelations
        ready: (true if parentRelations)
        count: (parentsCount if parentRelations)
        thumbs: (parentThumbs if parentThumbs)
      child: if fetchRelations
        ready: (true if childRelations)
        count: (childrenCount if childRelations)
        thumbs: (childThumbs if childThumbs)
    }

    favoriteProps = {
      pendingFavorite: @state.pendingFavorite
      favorOnClick: @_favorOnClick
      modelFavored: model.favored
      modelUrl: model.url
      stateIsClient: state.isClient
      authToken: authToken
      favoritePolicy: get.favorite_policy
    }

    deleteProps = {
      stateDeleteModal: @state.deleteModal
      onModalCancel: @_onModalCancel
      onModalOk: @_onModalOk
      modalTitle: model.title
      showModal: @_showModal
    }

    statusProps = {
      modelType: model.type
      modelIsNew: (model.isNew() if model.type is 'MediaEntry')
      modelPublished: (model['published?'] if model.type is 'MediaEntry')
      privacyStatus: get.privacy_status
    }

    selectProps = {
      onSelect: @props.onSelect
      selectStyle: CURSOR_SELECT_STYLE
      isSelected: @props.isSelected
    }

    textProps = if get.uploadStatus
      title: get.uploadStatus[0]
      subtitle: get.uploadStatus[1]
    else
      title: get.title
      subtitle: get.authors_pretty

    if @props.pinThumb
      <PinThumbnail
        resourceType={model.type}
        imageUrl={f.get(get, 'media_file.previews.images.large.url', get.image_url)}
        mediaType={model.mediaType}
        title={textProps.title}
        subtitle={textProps.subtitle}
        mediaUrl={get.url}
        selectProps={selectProps}
        favoriteProps={favoriteProps}
        editable={get.editable}
        deleteProps={deleteProps}
        statusProps={statusProps}
        style={@props.style}
        />
    else if @props.listThumb
      <ListThumbnail
        resourceType={model.type}
        imageUrl={get.image_url}
        mediaType={model.mediaType}
        title={textProps.title}
        subtitle={textProps.subtitle}
        mediaUrl={get.url}
        metaData={@props.indexMetaData}
        loadingMetadata={@props.loadingMetadata}
        style={@props.style}
        selectProps={selectProps}
        />
    else
      <ResourceThumbnailRenderer
        resourceType={model.type}
        mediaType={model.mediaType}
        elm={elm}
        get={get}
        pictureOnClick={onClick}
        relationsProps={relationsProps}
        favoriteProps={favoriteProps}
        deleteProps={deleteProps}
        statusProps={statusProps}
        selectProps={selectProps}
        textProps={textProps}
        style={@props.style}
        />




FlyoutImage = React.createClass
  displayName: 'FlyoutImage'

  render: ({imageUrl, title, mediaType, resourceType} = @props)->
    if imageUrl
      <Picture mods='ui-thumbnail-level-image' src={imageUrl} alt={title} />
    else
      <ResourceIcon mediaType={mediaType} flyout={true}
        type={resourceType} overrideClasses='ui-thumbnail-level-image' />
