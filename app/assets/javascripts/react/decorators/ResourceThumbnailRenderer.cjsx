React = require('react')
async = require('async')
f = require('active-lodash')
cx = require('classnames')
ampersandReactMixin = require('ampersand-react-mixin')
t = require('../../lib/i18n-translate.js')
Models = require('../../models/index.coffee')
{ Link, Icon, Thumbnail, Button, Preloader, AskModal
} = require('../ui-components/index.coffee')
StatusIcon = require('./thumbnail/StatusIcon.cjsx')
FavoriteButton = require('./thumbnail/FavoriteButton.cjsx')
DeleteModal = require('./thumbnail/DeleteModal.cjsx')

module.exports = React.createClass
  displayName: 'ResourceThumbnailRenderer'

  shouldComponentUpdate: (nextProps, nextState) ->
    l = require('lodash')
    return !l.isEqual(@state, nextState) || !l.isEqual(@props, nextProps)

  render: ({resourceType,
      mediaType,
      elm, get,
      onPictureClick,
      relationsProps,
      favoriteProps,
      deleteProps,
      statusProps,
      selectProps,
      textProps,
      positionProps} = @props
  ) ->

    if statusProps
      statusIcon = <StatusIcon privacyStatus={statusProps.privacyStatus}
        resourceType={resourceType}
        modelPublished={statusProps.modelPublished} />

    # hover - actions
    actionsLeft = []
    actionsRight = []

    # hover - action - select
    if selectProps and selectProps.onSelect
      selectAction =
        <li className='ui-thumbnail-action' key='selector'>
          <span className='js-only'>
            <Link onClick={selectProps.onSelect}
              style={selectProps.selectStyle}
              className='ui-thumbnail-action-checkbox'
              title={if selectProps.isSelected then 'Auswahl entfernen' else 'auswählen'}>
              <Icon i='checkbox' mods={if selectProps.isSelected then 'active'}/>
            </Link>
          </span>
        </li>
      actionsLeft.push(selectAction)

    # hover - action - fav
    if favoriteProps && favoriteProps.favoritePolicy
      favorButton = <FavoriteButton modelFavored={favoriteProps.modelFavored}
        favorUrl={favoriteProps.favorUrl} disfavorUrl={favoriteProps.disfavorUrl}
        favorOnClick={favoriteProps.favorOnClick} pendingFavorite={favoriteProps.pendingFavorite}
        stateIsClient={favoriteProps.stateIsClient} authToken={favoriteProps.authToken}
        buttonClass='ui-thumbnail-action-favorite' />
      actionsLeft.push(
        <li key='favorite' className='ui-thumbnail-action'>{favorButton}</li>)

    # change position buttons
    if f.get(positionProps, 'changeable', false) and resourceType is 'MediaEntry'
      { handlePositionChange } = positionProps
      commonCss =
        cursor: (if positionProps.disabled then 'not-allowed' else 'pointer')
      iconCssClass = cx({ mid: positionProps.disabled })

      actionsLeft.push(
        <li
          key='action01'
          className='ui-thumbnail-action mrn'
          style={commonCss}
          title='Move to the beginning'
          onClick={(e) -> handlePositionChange(get.uuid, -2, e)}
        >
          <Icon i='move-left-first' className={iconCssClass} />
        </li>
      )

      actionsLeft.push(
        <li
          key='action02'
          className='ui-thumbnail-action mhn'
          style={commonCss}
          title='Move left'
          onClick={(e) -> handlePositionChange(get.uuid, -1, e)}
        >
          <Icon i='move-left' className={iconCssClass} />
        </li>
      )

      actionsLeft.push(
        <li
          key='action03'
          className='ui-thumbnail-action mhn'
          style={commonCss}
          title='Move right'
          onClick={(e) -> handlePositionChange(get.uuid, 1, e)}
        >
          <Icon i='move-right' className={iconCssClass} />
        </li>
      )

      actionsLeft.push(
        <li
          key='action04'
          className='ui-thumbnail-action mln'
          style={commonCss}
          title='Move to the end'
          onClick={(e) -> handlePositionChange(get.uuid, 2, e)}
        >
          <Icon i='move-right-last' className={iconCssClass} />
        </li>
      )


    if get.editable
      actionsRight.push(
        <li key='edit' className='ui-thumbnail-action'>
          <Button className='ui-thumbnail-action-favorite' href={get.edit_meta_data_by_context_url}>
            <i className='icon-pen'></i>
          </Button>
        </li>
      )

    if deleteProps && get.destroyable
      actionsRight.push(
        <li key='destroy' className='ui-thumbnail-action'>
          <Button className='ui-thumbnail-action-favorite' onClick={deleteProps.showModal}>
            <i className='icon-trash'></i>
          </Button>
        </li>
      )


    thumbProps =
      draft: statusProps.modelPublished == false
      onClipboard: statusProps.onClipboard
      clipboardUrl: get.clipboard_url
      type: get.type
      mods: (['video'] if mediaType is 'video')
      src: get.image_url
      href: get.url
      alt: get.title
      mediaType: mediaType
      # click handlers:
      onPictureClick: onPictureClick
      pictureLinkStyle: @props.pictureLinkStyle
      # extra elements (nested for layout):
      meta: textProps
      badgeLeft: statusIcon
      badgeRight: if get.type is 'FilterSet'
        <Icon i='filter' title='This is a Filterset'/>
      actionsLeft: actionsLeft
      actionsRight: actionsRight

      flyoutTop: if relationsProps and relationsProps.parent and (f.include ['MediaEntry', 'Collection'], resourceType)
        title: 'Übergeordnete Sets'
        children: if relationsProps.parent.ready then relationsProps.parent.thumbs else <Preloader mods='small'/>
        caption: if relationsProps.parent.ready then relationsProps.parent.count + ' Sets' else ''

      flyoutBottom: if relationsProps and relationsProps.child and resourceType is 'Collection'
        title: 'Set enthält'
        children: if relationsProps.child.ready then relationsProps.child.thumbs else <Preloader mods='small'/>
        caption: if relationsProps.child.ready then relationsProps.child.count + ' Inhalte' else ''

      disableLink: get.disableLink
      editMetaDataByContextUrl: get.edit_meta_data_by_context_url


    <div className='ui-resource-body'>
      <Thumbnail {...thumbProps} />
      {
        if deleteProps && deleteProps.stateDeleteModal == true
          <DeleteModal resourceType={get.type} onModalOk={deleteProps.onModalOk}
            onModalCancel={deleteProps.onModalCancel} modalTitle={deleteProps.modalTitle} />
        else
          null
      }
    </div>
