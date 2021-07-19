React = require('react')
ReactDOM = require('react-dom')
Moment = require('moment')
currentLocale = require('../../lib/current-locale.js')
isEmpty = require('lodash/isEmpty')
trim = require('lodash/trim')
t = require('../../lib/i18n-translate.js')

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
      {t('release_local_git_version')}: <a href={git_url}>{git_hash}</a>
    </h2>
  </div>

DeploymentInfo = ({tree_id, commit_id, build_time, deployed, changes_since_release}) =>
  Moment.locale(currentLocale())
  buildUrl = "https://ci.zhdk.ch/cider-ci/ui/workspace/trees/#{tree_id}"
  commitUrl = "https://github.com/Madek/Madek/commits/#{commit_id}"

  <div className='ui-container pbm'>
    <h2 className='title-s'>
      {deployed && !!deployed.time &&
        <span>Deployment: {Moment(deployed.time).format('LLLL')}, </span>
      }
      <span><a href={buildUrl}>Build</a>: </span>
      {Moment(build_time).format('LLLL')}
    </h2>
    {!deployed.is_release &&
      <div className='mtm'>
        <h2 className='title-s'>
          <span>
            <a href={commitUrl}>{t('release_version')}</a>{'! '}
            {t('release_changes_since_release')}:</span>
        </h2>
        <pre className='pls' style={{whiteSpace: 'pre'}}>
          {changes_since_release}
        </pre>
      </div>
    }
  </div>

ReleasesInfo = ({releases, children}) =>
  current = releases[0]
  past = releases.slice(1)
  name = (r) =>
    if r.name and r.info_url
      <span>Madek {r.semver} "<a href={r.info_url}>{r.name}</a>"</span>
    else if r.name
      <span>Madek {r.semver} "{r.name}"</span>
    else
      <span>Madek {r.semver}</span>

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
