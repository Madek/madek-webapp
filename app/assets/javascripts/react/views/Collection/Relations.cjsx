React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
RailsForm = require('../../lib/forms/rails-form.cjsx')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')

classnames = require('classnames')

module.exports = React.createClass
  displayName: 'CollectionRelations'

  render: ({authToken, get} = @props) ->
    <div className="bright pal rounded-bottom rounded-top-right ui-container">
      <h3 className="title-l separated mbm">
        {t('relations_title')}
      </h3>
      <h4 className="title-m mbm">{t('relations_parents_title')}</h4>
      <MediaResourcesBox withBox={false} get={get.relations.parent_media_resources} authToken={authToken} />
      <h4 className="title-m mbm">{t('relations_siblings_title')}</h4>
      <MediaResourcesBox withBox={false} get={get.relations.sibling_media_resources} authToken={authToken} />
    </div>
