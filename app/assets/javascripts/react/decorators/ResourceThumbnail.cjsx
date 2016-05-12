React = require('react')
async = require('async')
f = require('active-lodash')
cx = require('classnames')
ampersandReactMixin = require('ampersand-react-mixin')
{Link, Icon, Thumbnail, AskModal} = require('../ui-components/index.coffee')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
Models = require('../../models/index.coffee')
RailsForm = require('../lib/forms/rails-form.cjsx')
Button = require('../ui-components/Button.cjsx')
t = require('../../lib/string-translation')('de')

CURSOR_SELECT_STYLE = {cursor: 'cell'}

module.exports = React.createClass
  displayName: 'ResourceThumbnail'
  mixins: [ampersandReactMixin]
  propTypes:
    authToken: React.PropTypes.string.isRequired
    onSelect: React.PropTypes.func
    onClick: React.PropTypes.func
    get: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry', 'Collection', 'FilterSet'])
    # TODO: consilidate with `get` (when used in uploader)
    resource: React.PropTypes.shape
      type: React.PropTypes.oneOf(['MediaEntry'])

  getInitialState: ()-> {
    active: @props.isClient or false
    pendingFavorite: false
    deleteModal: false
  }
  componentDidMount: ()->
    if (modelByType = Models[@props.get.type])
      model = new modelByType(@props.get)
    else
      console.error('WARNING: No model found for resource!', @props.get)
    @setState(active: true, model: model)

  _favorOnClick: () ->
    @setState(pendingFavorite: true)
    action = if @state.model.favored then 'disfavor' else 'favor'
    @state.model.setFavoredStatus action, (err, res)=>
      @setState(pendingFavorite: false)

  _showModal: () ->
    @setState(deleteModal: true)

  _onModalOk: () ->
    @setState(deleteModal: false)
    @state.model.delete(
      (err, res) ->
        location.reload()
    )

  _onModalCancel: () ->
    @setState(deleteModal: false)


  render: ({get, elm, onClick, isSelected, authToken} = @props, state = @state)->
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
        if state.active
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
          <Button className='ui-thumbnail-action-favorite' href={get.url + '/meta_data/edit'}>
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
    parentRelations = get.parent_relations
    childRelations = get.child_relations

    if parentRelations
      parentsCount = parentRelations.count
      parentsCountText = parentsCount + ' Sets'

      if parentsCount > 0
        parentThumbs = f.get(get, ['parent_relations', 'resources']).map (item) ->
          <li className='ui-thumbnail-level-item media_set set odd'>
            <a className='ui-level-image-wrapper' href={item.url}>
              <div className='ui-thumbnail-level-image-holder'>
                <img className='ui-thumbnail-level-image' src={item.image_url}/>
              </div>
            </a>
          </li>

    if childRelations
      childrenCount = childRelations.count
      childrenCountText = childrenCount + ' Inhalte'

      if childrenCount > 0
        childThumbs = f.get(get, ['child_relations', 'resources']).map (item) ->
          classes = 'ui-thumbnail-level-item media_set set odd'
          if item.type == 'MediaEntry'
            classes = 'ui-thumbnail-level-item media_entry image odd'
          <li className={classes}>
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
      flyoutTop: if parentRelations
        title: 'Übergeordnete Sets'
        children: parentThumbs
        caption: parentsCount + ' Sets'
      flyoutBottom: if childRelations
        title: 'Set enthält'
        children: childThumbs
        caption: childrenCount + ' Inhalte'

    <Element className={cx('ui-resource', 'ui-selected': isSelected)}>
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
              onCancel={@_onModalCancel} onOk={@_onModalOk}>
              {t(type + '_ask_delete_question_pre')}
              <strong>{model.title}</strong>
              {t('resource_ask_delete_question_post')}
            </AskModal>
          else
            null
        }
      </div>
    </Element>
