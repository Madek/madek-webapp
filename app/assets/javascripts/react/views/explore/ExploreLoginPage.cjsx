React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
classnames = require('classnames')
CatalogThumbnailShifted = require('./partials/CatalogThumbnailShifted.cjsx')
LoginDialog = require('./LoginDialog.cjsx')

module.exports = React.createClass
  displayName: 'ExploreLoginPage'

  getInitialState: () -> { active: false }

  render: ({authToken, get} = @props) ->

    <div className="ui-collage crooked ui-container overlaid" id="teaser-set">

      {f.map f.chunk(f.slice(get.teaser_entries.resources, 0, 20), 5), (chunk, row) ->
        <div key={'row_' + row} className="ui-collage-row">
          {f.map chunk, (resource, index) ->
            <CatalogThumbnailShifted key={'item_' + row + '_' + index} count={index + 1} imageUrl={resource.image_url} />
          }
        </div>
      }

      <LoginDialog />

    </div>
