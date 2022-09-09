React = require('react')
async = require('async')
f = require('active-lodash')
cx = require('classnames')
ampersandReactMixin = require('ampersand-react-mixin')
t = require('../../lib/i18n-translate.js')
{ Link, Icon, Thumbnail, Button, Preloader, AskModal
} = require('../ui-components/index.coffee')
ResourceThumbnailRenderer = require('./ResourceThumbnailRenderer.cjsx')
PinThumbnail = require('./PinThumbnail.cjsx')
ListThumbnail = require('./ListThumbnail.cjsx')
ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
Picture = require('../ui-components/Picture.cjsx')
BoxFetchRelations = require('./BoxFetchRelations.js')
BoxFavorite = require('./BoxFavorite.js')
BoxDelete = require('./BoxDelete.js')
getMediaType = require('../../models/shared/get-media-type.js')
BoxBatchApplyButton = require('./BoxBatchApplyButton.jsx')

CURSOR_SELECT_STYLE = {cursor: 'cell'}

module.exports = React.createClass
  displayName: 'ResourceThumbnail'
  mixins: [ampersandReactMixin]
  propTypes:
    authToken: React.PropTypes.string
    onSelect: React.PropTypes.func
    fetchRelations: React.PropTypes.bool
    elm: React.PropTypes.string # type of html node of outer wrapper
    get: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry', 'Collection'])
    # TODO: consilidate with `get` (when used in uploader)
    resource: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry'])

  shouldComponentUpdate: (nextProps, nextState) ->
    l = require('lodash')
    return !l.isEqual(@state, nextState) || !l.isEqual(@props, nextProps)

  relationsTrigger: (props) ->
    this.relationsTransition(props)

  relationsInitial: (props) ->
    return BoxFetchRelations(null, props, (ps) => this.relationsTrigger(ps))

  relationsTransition: (props) ->
    next = BoxFetchRelations(f.cloneDeep(@state.relationsState), props, (ps) => this.relationsTrigger(ps))
    @setState({relationsState: next})

  favoriteTrigger: (props) ->
    this.favoriteTransition(props)

  favoriteInitial: (props) ->
    return BoxFavorite(null, props, (ps) => this.favoriteTrigger(ps))

  favoriteTransition: (props) ->
    next = BoxFavorite(f.cloneDeep(@state.favoriteState), props, (ps) => this.favoriteTrigger(ps))
    @setState({favoriteState: next})


  getInitialState: ()-> {
    isClient: @props.isClient or false
    deleteModal: false
    relationsState: this.relationsInitial({type: @props.get.type})
    favoriteState: this.favoriteInitial({resource: @props.get})
  }

  componentDidMount: ()->
    @setState(isClient: true)

  _fetchRelations: () ->
    this.relationsTransition(
      {
        event: 'try-fetch',
        resource: @props.get
      }
    )

  _onHover: ()->
    @_fetchRelations() if @props.fetchRelations

  _favorOnClick: () ->
    this.favoriteTransition({event: 'toggle', resource: @props.get})

  _showModal: () ->
    @setState(deleteModal: true)

  _onModalOk: () ->
    BoxDelete(
      @props.get,
      () =>
        location.reload()
    )

  _onModalCancel: () ->
    @setState(deleteModal: false)

  render: ({get, elm, isSelected, fetchRelations, authToken, positionProps} = @props, state = @state)->

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
      pendingFavorite: @state.favoriteState.pendingFavorite
      favorOnClick: @_favorOnClick
      modelFavored: @state.favoriteState.favored
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
      modalTitle: @props.get.title
      showModal: @_showModal
    }

    statusProps = {
      modelType: @props.get.type
      modelPublished: (@props.get['published?'] if @props.get.type is 'MediaEntry')
      privacyStatus: get.privacy_status
      onClipboard: true if @props.get.on_clipboard
    }

    selectProps = {
      onSelect: @props.onSelect
      selectStyle: CURSOR_SELECT_STYLE
      isSelected: @props.isSelected
    }


    getTextProps = () =>

      getTitle = () =>
        if @props.overrideTexts && @props.overrideTexts.title
          @props.overrideTexts.title
        else
          get.title

      getSubtitle = () =>
        if @props.overrideTexts && @props.overrideTexts.subtitle
          @props.overrideTexts.subtitle
        else
          get.authors_pretty


      if get.uploadStatus
        title: get.uploadStatus[0]
        subtitle: get.uploadStatus[1]
      else
        title: getTitle()
        subtitle: getSubtitle()

    textProps = getTextProps()


    resourceMediaType = if @props.uploadMediaType
      @props.uploadMediaType
    else
      getMediaType(f.get(@props.get, 'media_file.content_type'))

    if @props.pinThumb
      <li style={@props.style} className={cx('ui-resource', {
        'is-video': get.media_type == 'video', 'ui-selected': (selectProps and selectProps.isSelected)})
      }>
        {@props.batchApplyButton}
        <PinThumbnail
          resourceType={@props.get.type}
          imageUrl={f.get(get, 'media_file.previews.images.large.url', get.image_url)}
          mediaType={resourceMediaType}
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
          onPictureClick={this.props.onPictureClick}
          pictureLinkStyle={this.props.pictureLinkStyle}
        />
      </li>
    else if @props.listThumb
      classes = {'ui-resource': true, 'ui-selected': true if (selectProps and selectProps.isSelected)}
      <li className={cx(classes)} style={@props.style}>
        {@props.batchApplyButton}
        <ListThumbnail
          resourceType={@props.get.type}
          imageUrl={get.image_url}
          mediaType={resourceMediaType}
          title={textProps.title}
          subtitle={textProps.subtitle}
          mediaUrl={get.url}
          metaData={@props.list_meta_data.meta_data if @props.list_meta_data}
          style={@props.style}
          selectProps={selectProps}
          favoriteProps={favoriteProps}
          deleteProps={deleteProps}
          get={get}
          onPictureClick={this.props.onPictureClick}
          pictureLinkStyle={this.props.pictureLinkStyle}
          positionProps={positionProps}
        />
      </li>
    else
      Element = elm or 'div'
      classes = {'ui-resource': true, 'ui-selected': true if (selectProps and selectProps.isSelected)}
      <Element
        style={@props.style}
        className={cx(classes)}
        onMouseOver={relationsProps.onHover if relationsProps}>
        {@props.batchApplyButton}
        <ResourceThumbnailRenderer
          resourceType={@props.get.type}
          mediaType={resourceMediaType}
          elm={elm}
          get={get}
          relationsProps={relationsProps}
          favoriteProps={favoriteProps}
          deleteProps={deleteProps}
          statusProps={statusProps}
          selectProps={selectProps}
          textProps={textProps}
          style={@props.style}
          onPictureClick={this.props.onPictureClick}
          pictureLinkStyle={this.props.pictureLinkStyle}
          positionProps={positionProps}
          />
      </Element>




FlyoutImage = React.createClass
  displayName: 'FlyoutImage'

  render: ({imageUrl, title, mediaType, resourceType} = @props)->
    if imageUrl
      <Picture mods='ui-thumbnail-level-image' src={imageUrl} alt={title} />
    else
      <ResourceIcon mediaType={mediaType} flyout={true}
        type={resourceType} overrideClasses='ui-thumbnail-level-image' />
