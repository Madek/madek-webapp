React = require('react')
async = require('async')
f = require('active-lodash')
cx = require('classnames')
ampersandReactMixin = require('ampersand-react-mixin')
t = require('../../lib/string-translation')('de')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
Models = require('../../models/index.coffee')
RailsForm = require('../lib/forms/rails-form.cjsx')
{ Link, Icon, Thumbnail, Button, Preloader, AskModal
} = require('../ui-components/index.coffee')

CURSOR_SELECT_STYLE = {cursor: 'cell'}

module.exports = React.createClass
  displayName: 'ResourceThumbnail'
  mixins: [ampersandReactMixin]
  propTypes:
    authToken: React.PropTypes.string.isRequired
    onSelect: React.PropTypes.func
    onClick: React.PropTypes.func
    fetchRelations: React.PropTypes.bool
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

  componentDidMount: ()->
    # instantiate model from data if not already…
    get = @props.get
    unless (get.isState or get.isCollection)
      if (modelByType = Models[get.type])
        model = new modelByType(get)
      else
        console.error('WARNING: No model found for resource!', get)
    @setState(isClient: true, model: model)

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
        @setState(fetchingRelations: f.without(@state.fetchingRelations, typeToFetch))
        next(err, res)),
      (err)=> @setState(fetchingRelations: false))

  _onHover: ()->
    @_fetchRelations() if @props.fetchRelations

  _favorOnClick: () ->
    @setState(pendingFavorite: true)
    action = if @state.model.favored then 'disfavor' else 'favor'
    @state.model.setFavoredStatus action, (err, res)=>
      @setState(pendingFavorite: false)

  _showModal: () ->
    @setState(deleteModal: true)

  _onModalOk: () ->
    @state.model.delete (err, res)->
      location.reload()

  _onModalCancel: () ->
    @setState(deleteModal: false)

  render: ({get, elm, onClick, isSelected, fetchRelations, authToken} = @props, state = @state)->
    model = @state.model or @props.get

    # map the type name:
    type = get.type.replace(/Collection/, 'MediaSet')
    # map the privacy icon:
    # see <http://madek.readthedocs.org/en/latest/entities/#privacy-status>
    # vs <http://test.madek.zhdk.ch/styleguide/Icons#6.2>
    iconMapping = {'public': 'open', 'private': 'private', 'shared': 'group'}
    privacyIcon = "privacy-#{iconMapping[get.privacy_status]}"

    # hover - actions
    actionsLeft = []
    actionsRight = []

    # hover - action - select
    onSelect = @props.onSelect
    if onSelect then do ()->
      selector = (
        <Link onClick={onSelect}
          style={CURSOR_SELECT_STYLE}
          className='ui-thumbnail-action-checkbox'
          title={if isSelected then 'Auswahl entfernen' else 'auswählen'}>
          <Icon i='checkbox' mods={if isSelected then 'active'}/>
        </Link>)
      actionsLeft.push(
        <li className='ui-thumbnail-action' key='selector'>
          <span className='js-only'>{selector}</span></li>)

    # hover - action - fav
    if get.favorite_policy
      favoriteAction = if model.favored then 'disfavor' else 'favor'
      favoriteUrl = model.url + '/' + favoriteAction
      starClass = if model.favored then 'icon-star' else 'icon-star-empty'
      favoriteItem = <i className={starClass}></i>
      favoriteOnClick = @_favorOnClick if not @state.pendingFavorite
      favorButton =
        if state.isClient
          <Button className='ui-thumbnail-action-favorite' onClick={favoriteOnClick}
            data-pending={state.pendingFavorite}>
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
        <li key='favorite' className='ui-thumbnail-action'>{favorButton}</li>)


    if get.editable
      actionsRight.push(
        <li key='edit' className='ui-thumbnail-action'>
          <Button className='ui-thumbnail-action-favorite' href={get.url + '/meta_data/edit_context'}>
            <i className='icon-pen'></i>
          </Button>
        </li>
      )

    if get.destroyable
      actionsRight.push(
        <li key='destroy' className='ui-thumbnail-action'>
          <Button className='ui-thumbnail-action-favorite' onClick={@_showModal}>
            <i className='icon-trash'></i>
          </Button>
        </li>
      )

    # hover - flyout - relations - thumbnail list:
    if fetchRelations
      parentRelations = f.get(model, 'parent_media_resources')
      childRelations = f.get(model, 'child_media_resources')

      if parentRelations
        parentsCount = parentRelations.pagination.total_count
        parentsCountText = parentsCount + ' Sets'

        if parentsCount > 0
          parentThumbs = f.get(parentRelations, 'resources').map (item) ->
            <li className='ui-thumbnail-level-item media_set set odd' key={item.uuid}>
              <a className='ui-level-image-wrapper' href={item.url}>
                <div className='ui-thumbnail-level-image-holder'>
                  <img className='ui-thumbnail-level-image' src={item.image_url}/>
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
                  <img className='ui-thumbnail-level-image' src={item.image_url}/>
                </div>
              </a>
            </li>


    Element = elm or 'div'
    thumbProps =
      type: f.kebabCase(type)
      mods: ['video'] if get.media_type is 'video'
      src: get.image_url or state.localPreview or '.'
      href: get.url
      alt: get.title
      # click handlers:
      onClick: onClick
      style: (CURSOR_SELECT_STYLE if onClick && (onClick == @props.onSelect))
      # extra elements (nested for layout):
      meta:
        title: get.title or get.uploadStatus
      badgeLeft:
        <Icon i={privacyIcon} title={get.privacy_status}/>
      badgeRight: if get.type is 'FilterSet'
        <Icon i='filter' title='This is a Filterset'/>
      actionsLeft: actionsLeft
      actionsRight: actionsRight

      flyoutTop: if fetchRelations and (f.include ['MediaEntry', 'Collection'], model.type)
        title: 'Übergeordnete Sets'
        children: if parentRelations then parentThumbs else <Preloader mods='small'/>
        caption: if parentRelations then parentsCount + ' Sets' else ''

      flyoutBottom: if fetchRelations and model.type is 'Collection'
        title: 'Set enthält'
        children: if childRelations then childThumbs else <Preloader mods='small'/>
        caption: if childRelations then childrenCount + ' Inhalte' else ''

    <Element
      className={cx('ui-resource', 'ui-selected': isSelected)}
      onMouseOver={@_onHover}>

      <div className='ui-resource-body'>
        <Thumbnail {...thumbProps}/>
        {
          if @state.deleteModal == true
            type = switch get.type
              when 'Collection'
                'collection'
              when 'MediaEntry'
                'media_entry'
            <AskModal title={t(type + '_ask_delete_title')}
              onCancel={@_onModalCancel} onOk={@_onModalOk}
              okText={t('resource_ask_delete_ok')}
              cancelText={t('resource_ask_delete_cancel')}>
              <p className="pam by-center">
                {t(type + '_ask_delete_question_pre')}
                <strong>{model.title}</strong>
                {t('resource_ask_delete_question_post')}
              </p>
            </AskModal>
          else
            null
        }
      </div>
    </Element>
