React = require('react')
ReactDOM = require('react-dom')
Moment = require('moment')
Moment.locale('de')
isEmpty = require('lodash/isEmpty')
t = require('../../lib/string-translation.js')('de')

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

          {get.dev_info && <DevelopmentInfo {...get.dev_info} />}

          {get.deploy_info && !isEmpty(get.deploy_info) &&
            <DeploymentInfo {...get.deploy_info} />
          }

          {get.releases && !isEmpty(get.releases) &&
            <ReleasesInfo releases={get.releases}/>
          }
        </div>
      </div>
    </div>

DevelopmentInfo = ({git_hash, git_url}) =>
  <div className='ui-container pbm'>
    <h2 className='title-s'>
      Entwicklungs-Version: <a href={git_url}>{git_hash}</a>
    </h2>
  </div>

DeploymentInfo = ({tree_id, commit_id, time}) =>
  <div className='ui-container pbm'>
    <h2 className='title-s'>
      <span>Letztes Deployment: </span>
      <a href={"https://ci.zhdk.ch/cider-ci/ui/workspace/trees/#{tree_id}"}>
        {Moment(time).format('LLLL')}
      </a>
    </h2>
  </div>

ReleasesInfo = ({releases, children}) =>
  current = releases[0]
  past = releases.slice(1)
  name = (r) => <span>Madek {r.semver} "<a href={r.info_url}>{r.name}</a>"</span>

  <div>
    <div className='ui-container pbm'>
      <a className='header-anchor' id={current.semver}/>
      <h3 className='title-xl separated mbs'>
        {name(current)} <a href={'#' + current.semver}><i className='icon-link'/></a>
      </h3>
      <MarkdownPrecompiled source={current.description} />
    </div>

    <h2 className='title-s'>Vorherige Versionen</h2>
    {past.map (r)-> <div key={r.semver}>
      <div className='ui-container pbm'>
        <a id={r.semver}/>
        <h3 className='title-l separated mbs'>
          {name(r)} <a href={'#' + r.semver}><i className='icon-link'/></a>
        </h3>
        <MarkdownPrecompiled source={r.description} />
      </div>
    </div>}
  </div>

MarkdownPrecompiled = ({source})->
  <div className='ui-markdown' dangerouslySetInnerHTML={{__html: source}} />
