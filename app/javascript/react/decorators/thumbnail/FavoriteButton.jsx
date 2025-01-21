/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import RailsForm from '../../lib/forms/rails-form.jsx'
import Button from '../../ui-components/Button.jsx'

module.exports = createReactClass({
  displayName: 'FavoriteButton',

  render(param) {
    let favoriteOnClick
    if (param == null) {
      param = this.props
    }
    const {
      authToken,
      modelFavored,
      favorUrl,
      disfavorUrl,
      favorOnClick,
      pendingFavorite,
      stateIsClient,
      buttonClass
    } = param
    const actionUrl = modelFavored ? disfavorUrl : favorUrl
    const starClass = modelFavored ? 'icon-star' : 'icon-star-empty'
    const favoriteIcon = <i className={starClass} />
    if (!pendingFavorite) {
      favoriteOnClick = favorOnClick
    }
    return stateIsClient ? (
      <Button className={buttonClass} onClick={favoriteOnClick} data-pending={pendingFavorite}>
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
})
