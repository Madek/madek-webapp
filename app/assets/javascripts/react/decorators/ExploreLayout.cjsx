React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
PrettyThumbs = require('../views/explore/partials/PrettyThumbs.cjsx')

module.exports = React.createClass
  displayName: 'ExploreLayout'

  getInitialState: () -> { active: false }

  render: ({authToken, menu, sections, collageResources, pageTitle} = @props) ->

    <div>

      <div className="app-body-title">
        <div className="ui-body-title">
          <div className="ui-body-title-label">
            <h1 className="title-xl">
              <i className="icon-catalog"></i>
              {' ' + pageTitle}
            </h1>
          </div>
        </div>
      </div>
      <div className="app-body-ui-container">
        <div className="bordered ui-container midtone table rounded-right rounded-bottom">

          {menu}

          <div className="app-body-content table-cell table-substance ui-container context-fix">
            {if collageResources
              <CollageLoggedIn resources={collageResources} />
            }

            {f.map sections, (section, index) ->
              list = [ ]
              separator = <hr key={'separator_' + index} className="separator"></hr>
              list.push(separator) if index > 0
              list.push(section)
              list
            }

          </div>
        </div>
      </div>
    </div>


CollageLoggedIn = React.createClass
  displayName: 'CollageLoggedIn'
  render: ({authToken, resources} = @props)->
    <div className="ui-collage ui-container rounded-top-right" id="teaser-set">
      {f.map f.chunk(f.slice(resources, 0, 10), 5), (chunk, row) ->
        <div key={'row_' + row} className="ui-collage-row">
          {f.map chunk, (resource) ->
            <PrettyThumbs key={resource.uuid} label={resource.title} author={resource.authors_pretty}
              imageUrl={resource.image_url} hrefUrl={resource.url} authToken={authToken} />
          }
        </div>
      }
    </div>
