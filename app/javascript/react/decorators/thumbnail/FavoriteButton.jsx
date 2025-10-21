import React from 'react'
import RailsForm from '../../lib/forms/rails-form.jsx'
import Button from '../../ui-components/Button.jsx'

const FavoriteButton = ({
  authToken,
  modelFavored,
  favorUrl,
  disfavorUrl,
  favorOnClick,
  pendingFavorite,
  stateIsClient,
  buttonClass
}) => {
  const actionUrl = modelFavored ? disfavorUrl : favorUrl
  const starClass = modelFavored ? 'icon-star' : 'icon-star-empty'
  const favoriteIcon = <i className={starClass} />
  const handleClick = pendingFavorite ? undefined : favorOnClick

  return stateIsClient ? (
    <Button className={buttonClass} onClick={handleClick} data-pending={pendingFavorite}>
      {favoriteIcon}
    </Button>
  ) : (
    <RailsForm name="resource_meta_data" action={actionUrl} method="patch" authToken={authToken}>
      <button className={buttonClass} type="submit">
        {favoriteIcon}
      </button>
    </RailsForm>
  )
}

export default FavoriteButton
module.exports = FavoriteButton
