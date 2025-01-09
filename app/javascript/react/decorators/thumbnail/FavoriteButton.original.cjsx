React = require('react')
f = require('active-lodash')
classList = require('classnames/dedupe')
parseMods = require('../../lib/ui.js').parseMods
t = require('../../../lib/i18n-translate.js')
RailsForm = require('../../lib/forms/rails-form.cjsx')
Button = require('../../ui-components/Button.cjsx')

module.exports = React.createClass
  displayName: 'FavoriteButton'


  render: ({authToken, modelFavored, favorUrl, disfavorUrl, favorOnClick, pendingFavorite, stateIsClient, buttonClass} = @props) ->
    actionUrl = if modelFavored then disfavorUrl else favorUrl
    starClass = if modelFavored then 'icon-star' else 'icon-star-empty'
    favoriteIcon = <i className={starClass}></i>
    favoriteOnClick = favorOnClick if not pendingFavorite
    favorButton =
      if stateIsClient
        <Button className={buttonClass} onClick={favoriteOnClick}
          data-pending={pendingFavorite}>
          {favoriteIcon}
        </Button>
      else
        <RailsForm name='resource_meta_data' action={actionUrl}
          method='patch' authToken={authToken}>
          <button className={buttonClass} type='submit'>
            {favoriteIcon}
          </button>
        </RailsForm>
