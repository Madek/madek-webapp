React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')
PrettyThumbs = require('../views/explore/partials/PrettyThumbs.cjsx')

module.exports = React.createClass
  displayName: 'ExploreLayout'

  getInitialState: () -> { active: false }

  render: ({authToken, sections, collageResources, pageTitle} = @props) ->

    <div>

      <div className='app-body-ui-container pts context-home' style={{width: '1000px'}}>
        <a className="strong" style={{position: 'relative', top: '20px'}} href='/explore'>
          Zurück
        </a>

        {f.map sections, (section, index) ->
          list = [ ]
          separator = <hr key={'separator_' + index} className='separator'></hr>
          list.push(separator) if index > 0
          list.push(section)
          list
        }

      </div>
    </div>
