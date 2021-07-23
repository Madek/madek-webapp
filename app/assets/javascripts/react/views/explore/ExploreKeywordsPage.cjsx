React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
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
