React = require('react')
ReactDOM = require('react-dom')
t = require('../../lib/string-translation.js')('de')
ReactMarkdown = require('react-markdown')

module.exports = React.createClass
  displayName: 'ReleaseShow'

  render: ({get, authToken} = @props) ->
    <div className='app-body-ui-container'>
      <div className="ui-body-title">
        <div className="ui-body-title-label">
          <h1 className="title-xl">
            <span><i className="icon-tag"></i></span> {t('release_info')}
          </h1>
        </div>
      </div>
      <div className='ui-container tab-content bordered rounded-top rounded-bottom mbh'>
        <div className='ui-container bright pal rounded-top rounded-bottom'>
          <h1 style={{fontSize: '32px', marginBottom: '30px'}}>Madek {get.version} {'"' + get.name + '"'}</h1>
          <ReactMarkdown source={get.description} softBreak='br' className='ui-markdown' />
        </div>
      </div>
    </div>
