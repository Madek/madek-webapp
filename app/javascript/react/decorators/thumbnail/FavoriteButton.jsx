/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const classList = require('classnames/dedupe')
const { parseMods } = require('../../lib/ui.js')
const t = require('../../../lib/i18n-translate.js')
const RailsForm = require('../../lib/forms/rails-form.cjsx')
const Button = require('../../ui-components/Button.cjsx')

module.exports = React.createClass({
  displayName: 'FavoriteButton',

  render(param) {
    let favorButton, favoriteOnClick
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
    return (favorButton = stateIsClient ? (
      <Button className={buttonClass} onClick={favoriteOnClick} data-pending={pendingFavorite}>
        {favoriteIcon}
      </Button>
    ) : (
      <RailsForm name="resource_meta_data" action={actionUrl} method="patch" authToken={authToken}>
        <button className={buttonClass} type="submit">
          {favoriteIcon}
        </button>
      </RailsForm>
    ))
  }
})
