React = require('react')
async = require('async')
f = require('active-lodash')
c = require('classnames')
t = require('../../lib/i18n-translate.js')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
Models = require('../../models/index.coffee')
Picture = require('../ui-components/Picture.cjsx')
Button = require('../ui-components/Button.cjsx')
ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
FavoriteButton = require('./thumbnail/FavoriteButton.cjsx')
DeleteModal = require('./thumbnail/DeleteModal.cjsx')
StatusIcon = require('./thumbnail/StatusIcon.cjsx')


module.exports = React.createClass
  displayName: 'PinThumbnail'

  render: ({resourceType, imageUrl, mediaType, title, subtitle, mediaUrl,
    selectProps, favoriteProps, editable, editUrl, destroyable, deleteProps, statusProps} = @props) ->

    isCollection = resourceType == 'Collection'

    innerImage = if imageUrl
      <Picture mods='ui-tile__image' src={imageUrl} alt={title} />
    else
      <ResourceIcon mediaType={mediaType} thumbnail={false} tiles={true}
        type={resourceType} overrideClasses='ui-tile__image' />

    actionsLeft = []
    actionsRight = []

    if favoriteProps && favoriteProps.favoritePolicy
      favorButton =
        <FavoriteButton modelFavored={favoriteProps.modelFavored}
            favorUrl={favoriteProps.favorUrl} disfavorUrl={favoriteProps.disfavorUrl}
            favorOnClick={favoriteProps.favorOnClick} pendingFavorite={favoriteProps.pendingFavorite}
            stateIsClient={favoriteProps.stateIsClient} authToken={favoriteProps.authToken}
            buttonClass='ui-tile__action-link'/>
      actionsLeft.push(favorButton)

    if selectProps and selectProps.onSelect
      selectAction =
        <a onClick={selectProps.onSelect} className='ui-tile__action-link'
          title={if selectProps.isSelected then t('resources_box_selection_remove_selection') else t('resources_box_selection_select')}>
          <i className={c('icon-checkbox', 'active': selectProps.isSelected)}></i>
        </a>
      actionsLeft.push(selectAction)

    if editable
      actionsRight.push(
        <Button className='ui-tile__action-link' href={editUrl}>
          <i className='icon-pen'></i>
        </Button>
      )

    if deleteProps && destroyable
      actionsRight.push(
        <Button className='ui-tile__action-link' onClick={deleteProps.showModal}>
          <i className='icon-trash'></i>
        </Button>
      )

    if statusProps
      badgeLeft = <StatusIcon privacyStatus={statusProps.privacyStatus}
        resourceType={resourceType} modelIsNew={statusProps.modelIsNew}
        modelPublished={statusProps.modelPublished}
        iconClass='ui-tile__flag ui-tile__flag--privac' />

    if resourceType == 'FilterSet'
      badgeRight = <i className='ui-tile__flag ui-tile__flag--typ icon-filter'></i>


    starShadow = '1px 0px 1px rgba(255, 255, 255, 0.5)'
    starShadow += ', 0px 1px 1px rgba(255, 255, 255, 0.5)'
    starShadow += ', -1px 0px 1px rgba(255, 255, 255, 0.5)'
    starShadow += ', 0px -1px 1px rgba(255, 255, 255, 0.5)'

    <li style={@props.style} className={c('ui-resource', 'ui-selected': (selectProps and selectProps.isSelected))}>
      {
        if deleteProps && deleteProps.stateDeleteModal == true
          <DeleteModal resourceType={resourceType} onModalOk={deleteProps.onModalOk}
            onModalCancel={deleteProps.onModalCancel} modalTitle={deleteProps.modalTitle} />
        else
          null
      }
      <div className={c('ui-tile', {'ui-tile--set': isCollection})}>
        <div className='ui-tile__head'>
          {
            if favoriteProps && favoriteProps.favoritePolicy && favoriteProps.modelFavored
              <i className='icon-star' style={{position: 'absolute', padding: '7px', textShadow: starShadow}}/>
          }
          <ul className='ui-tile__actions left by-left'>
            {
              f.map(
                actionsLeft, (action, index) ->
                  <li className='ui-tile__action' key={'action_left_' + index}>
                    {action}
                  </li>
              )
            }
          </ul>
          <ul className='ui-tile__actions right by-right'>
            {
              f.map(
                actionsRight, (action, index) ->
                  <li className='ui-tile__action' key={'action_right_' + index}>
                    {action}
                  </li>
              )
            }
          </ul>
        </div>
        <div className='ui-tile__body'>
          <a className='ui-tile__thumbnail' href={mediaUrl}>
            {innerImage}
          </a>
        </div>
        <a href={mediaUrl}>
          <div className='ui-tile__foot'>
            <h3 className='ui-tile__title'>{title}</h3>
            <h4 className='ui-tile__meta'>{subtitle}</h4>
            <span className='ui-tile__flags'>
              {badgeLeft}
              {badgeRight}
            </span>
          </div>
        </a>
      </div>
    </li>
