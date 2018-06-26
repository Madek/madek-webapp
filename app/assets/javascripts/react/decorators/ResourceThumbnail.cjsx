React = require('react')
async = require('async')
f = require('active-lodash')
cx = require('classnames')
ampersandReactMixin = require('ampersand-react-mixin')
t = require('../../lib/i18n-translate.js')
Models = require('../../models/index.coffee')
{ Link, Icon, Thumbnail, Button, Preloader, AskModal
} = require('../ui-components/index.coffee')
ResourceThumbnailRenderer = require('./ResourceThumbnailRenderer.cjsx')
PinThumbnail = require('./PinThumbnail.cjsx')
ListThumbnail = require('./ListThumbnail.cjsx')
ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
Picture = require('../ui-components/Picture.cjsx')
BoxFetchRelations = require('./BoxFetchRelations.js')

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

  relationsTrigger: (props) ->
    this.relationsTransition(props)

  relationsInitial: (props) ->
    return BoxFetchRelations(null, props, (ps) => this.relationsTrigger(ps))

  relationsTransition: (props) ->
    next = BoxFetchRelations(f.cloneDeep(@state.relationsState), props, (ps) => this.relationsTrigger(ps))
    @setState({relationsState: next})

  getInitialState: ()-> {
    isClient: @props.isClient or false
    pendingFavorite: false
    deleteModal: false
    relationsState: this.relationsInitial({type: @props.get.type})
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

  _fetchRelations: () ->
    this.relationsTransition(
      {
        state: @state,
        event: 'try-fetch',
        resource: @props.get
      }
    )

  _onHover: ()->
    @_fetchRelations() if @props.fetchRelations

  _favorOnClick: () ->
    @setState(pendingFavorite: true)
    action = {}
    action.name = if @state.model.favored then 'disfavor' else 'favor'
    action.url = @state.model[action.name + '_url']
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
      parentRelations = @state.relationsState.relations.parents
      childRelations = @state.relationsState.relations.children

      if parentRelations
        parentsCount = parentRelations.pagination.total_count
        parentsCountText = parentsCount + ' ' + t('resource_thumbnail_sets')

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
        childrenCountText = childrenCount + ' ' + t('resource_thumbnail_contents')

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
      favorUrl: get.favor_url
      disfavorUrl: get.disfavor_url
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
      onClipboard: true if model.on_clipboard
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
        editUrl={get.edit_meta_data_by_context_url}
        destroyable={get.destroyable}
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
        metaData={@props.list_meta_data.meta_data if @props.list_meta_data}
        style={@props.style}
        selectProps={selectProps}
        favoriteProps={favoriteProps}
        deleteProps={deleteProps}
        get={get}
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
