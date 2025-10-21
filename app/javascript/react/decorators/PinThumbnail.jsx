import React, { memo } from 'react'
import cx from 'classnames'
import t from '../../lib/i18n-translate.js'
import Picture from '../ui-components/Picture.jsx'
import Button from '../ui-components/Button.jsx'
import ResourceIcon from '../ui-components/ResourceIcon.jsx'
import FavoriteButton from './thumbnail/FavoriteButton.jsx'
import DeleteModal from './thumbnail/DeleteModal.jsx'
import StatusIcon from './thumbnail/StatusIcon.jsx'

const PinThumbnail = memo(props => {
  const {
    resourceType,
    imageUrl,
    mediaType,
    title,
    subtitle,
    mediaUrl,
    selectProps,
    favoriteProps,
    editable,
    editUrl,
    destroyable,
    deleteProps,
    statusProps,
    pictureLinkStyle,
    onPictureClick
  } = props

  const isCollection = resourceType === 'Collection'

  const innerImage = imageUrl ? (
    <Picture mods="ui-tile__image" src={imageUrl} alt={title} />
  ) : (
    <ResourceIcon
      mediaType={mediaType}
      thumbnail={false}
      tiles={true}
      type={resourceType}
      overrideClasses="ui-tile__image"
    />
  )

  const actionsLeft = []
  const actionsRight = []

  if (favoriteProps && favoriteProps.favoritePolicy) {
    const favorButton = (
      <FavoriteButton
        modelFavored={favoriteProps.modelFavored}
        favorUrl={favoriteProps.favorUrl}
        disfavorUrl={favoriteProps.disfavorUrl}
        favorOnClick={favoriteProps.favorOnClick}
        pendingFavorite={favoriteProps.pendingFavorite}
        stateIsClient={favoriteProps.stateIsClient}
        authToken={favoriteProps.authToken}
        buttonClass="ui-tile__action-link"
      />
    )
    actionsLeft.push(favorButton)
  }

  if (selectProps && selectProps.onSelect) {
    const selectAction = (
      <a
        onClick={selectProps.onSelect}
        className="ui-tile__action-link"
        title={
          selectProps.isSelected
            ? t('resources_box_selection_remove_selection')
            : t('resources_box_selection_select')
        }>
        <i className={cx('icon-checkbox', { active: selectProps.isSelected })} />
      </a>
    )
    actionsLeft.push(selectAction)
  }

  if (editable) {
    actionsRight.push(
      <Button className="ui-tile__action-link" href={editUrl}>
        <i className="icon-pen" />
      </Button>
    )
  }

  if (deleteProps && destroyable) {
    actionsRight.push(
      <Button className="ui-tile__action-link" onClick={deleteProps.showModal}>
        <i className="icon-trash" />
      </Button>
    )
  }

  let badgeLeft, badgeRight

  if (statusProps) {
    badgeLeft = (
      <StatusIcon
        privacyStatus={statusProps.privacyStatus}
        resourceType={resourceType}
        modelPublished={statusProps.modelPublished}
        iconClass="ui-tile__flag ui-tile__flag--privac"
      />
    )
  }

  if (resourceType === 'FilterSet') {
    badgeRight = <i className="ui-tile__flag ui-tile__flag--typ icon-filter" />
  }

  let starShadow = '1px 0px 1px rgba(255, 255, 255, 0.5)'
  starShadow += ', 0px 1px 1px rgba(255, 255, 255, 0.5)'
  starShadow += ', -1px 0px 1px rgba(255, 255, 255, 0.5)'
  starShadow += ', 0px -1px 1px rgba(255, 255, 255, 0.5)'

  return (
    <div>
      {deleteProps && deleteProps.stateDeleteModal === true ? (
        <DeleteModal
          resourceType={resourceType}
          onModalOk={deleteProps.onModalOk}
          onModalCancel={deleteProps.onModalCancel}
          modalTitle={deleteProps.modalTitle}
        />
      ) : null}
      <div className={cx('ui-tile', { 'ui-tile--set': isCollection })}>
        <div className="ui-tile__head">
          {favoriteProps && favoriteProps.favoritePolicy && favoriteProps.modelFavored && (
            <i
              className="icon-star"
              style={{ position: 'absolute', padding: '7px', textShadow: starShadow }}
            />
          )}
          <ul className="ui-tile__actions left by-left">
            {actionsLeft.map((action, index) => (
              <li className="ui-tile__action" key={`action_left_${index}`}>
                {action}
              </li>
            ))}
          </ul>
          <ul className="ui-tile__actions right by-right">
            {actionsRight.map((action, index) => (
              <li className="ui-tile__action" key={`action_right_${index}`}>
                {action}
              </li>
            ))}
          </ul>
        </div>
        <div className="ui-tile__body">
          <a
            className="ui-tile__thumbnail"
            style={pictureLinkStyle}
            onClick={onPictureClick}
            href={mediaUrl}>
            {innerImage}
          </a>
        </div>
        <a href={mediaUrl}>
          <div className="ui-tile__foot">
            <h3 className="ui-tile__title">{title}</h3>
            <h4 className="ui-tile__meta">{subtitle}</h4>
            <span className="ui-tile__flags">
              {badgeLeft}
              {badgeRight}
            </span>
          </div>
        </a>
      </div>
    </div>
  )
})

PinThumbnail.displayName = 'PinThumbnail'

export default PinThumbnail
module.exports = PinThumbnail
