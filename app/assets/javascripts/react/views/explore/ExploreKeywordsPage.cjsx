React = require('react')
ReactDOM = require('react-dom')
t = require('../../../lib/string-translation')('de')
f = require('lodash')
classnames = require('classnames')
CatalogThumbnailShifted = require('./partials/CatalogThumbnailShifted.cjsx')
LoginMenu = require('../_layouts/LoginMenu.js').default
ResourcesSection = require('./partials/ResourcesSection.cjsx')
ResourceThumbnail = require('../../decorators/ResourceThumbnail.cjsx')
UI = require('../../ui-components/index.coffee')
Preloader = require('../../ui-components/Preloader.cjsx')
loadXhr = require('../../../lib/load-xhr.coffee')
libUrl = require('url')
qs = require('qs')
setUrlParams = require('../../../lib/set-params-for-url.coffee')
Keyword = require('../../ui-components/Keyword.cjsx')


module.exports = React.createClass
  displayName: 'ExploreKeywordsPage'

  render: ({get, authToken} = @props) ->
    <div>

      <div className="app-body-ui-container pts context-home">


        <h1 className='title-xl mtl mbm'>
          {get.content.data.title}
        </h1>

        <div className='ui-resources-holder pal'>

          <ul className='ui-tag-cloud' style={{marginBottom: '40px'}}>
          {
            f.map get.content.data.list, (resource, n) ->
              <Keyword key={'key_' + n} label={resource.keyword.label}
                hrefUrl={resource.keyword.url} count={resource.keyword.usage_count} />
          }
          </ul>
        </div>

      </div>
    </div>
