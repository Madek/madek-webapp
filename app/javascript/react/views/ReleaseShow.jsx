/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import Moment from 'moment'
import currentLocale from '../../lib/current-locale.js'
import isEmpty from 'lodash/isEmpty'
import t from '../../lib/i18n-translate.js'

module.exports = createReactClass({
  displayName: 'ReleaseShow',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    return (
      <div className="app-body-ui-container">
        <div className="ui-body-title">
          <div className="ui-body-title-label">
            <h1 className="title-xl">
              <span>
                <i className="icon-tag" />
              </span>{' '}
              {t('release_info')}
            </h1>
          </div>
        </div>
        <div className="ui-container tab-content bordered rounded-top rounded-bottom mbh">
          <div className="ui-container bright pal rounded-top rounded-bottom">
            {get.dev_info && <DevelopmentInfo {...Object.assign({}, get.dev_info)} />}
            {get.deploy_info && !isEmpty(get.deploy_info) && (
              <DeploymentInfo {...Object.assign({}, get.deploy_info)} />
            )}
            {get.releases && !isEmpty(get.releases) && <ReleasesInfo releases={get.releases} />}
          </div>
        </div>
      </div>
    )
  }
})

var DevelopmentInfo = ({ git_hash, git_url }) => {
  return (
    <div className="ui-container pbm">
      <h2 className="title-s">
        {t('release_local_git_version')}: <a href={git_url}>{git_hash}</a>
      </h2>
    </div>
  )
}

var DeploymentInfo = ({ tree_id, commit_id, build_time, deployed }) => {
  Moment.locale(currentLocale())
  const buildUrl = `https://ci.zhdk.ch/cider-ci/ui/workspace/trees/${tree_id}`
  const commitUrl = `https://github.com/Madek/Madek/commits/${commit_id}`

  return (
    <div className="ui-container pbm">
      <h2 className="title-s">
        {deployed && !!deployed.time && (
          <span>Deployment: {Moment(deployed.time).format('LLLL')}, </span>
        )}
        <span>
          <a href={buildUrl}>Build</a>:{' '}
        </span>
        {Moment(build_time).format('LLLL')}
      </h2>
      <div className="mtm">
        <h2 className="title-s">
          <a href={commitUrl}>{t('release_source_history')}</a>
        </h2>
      </div>
    </div>
  )
}

var ReleasesInfo = ({ releases }) => {
  const current = releases[0]
  const past = releases.slice(1)
  const name = r => {
    if (r.name && r.info_url) {
      return (
        <span>
          Madek {r.semver} &quot;<a href={r.info_url}>{r.name}</a>&quot;
        </span>
      )
    } else if (r.name) {
      return (
        <span>
          Madek {r.semver} &quot;{r.name}&quot;
        </span>
      )
    } else {
      return <span>Madek {r.semver}</span>
    }
  }

  return (
    <div>
      <div className="ui-container pbm">
        <a className="header-anchor" id={current.semver} />
        <h3 className="title-xl separated mbs">
          {name(current)}{' '}
          <a href={`#${current.semver}`}>
            <i className="icon-link" />
          </a>
        </h3>
        <MarkdownPrecompiled source={current.description} />
      </div>
      <h2 className="title-s">Vorherige Versionen</h2>
      {past.map(r => (
        <div key={r.semver}>
          <div className="ui-container pbm">
            <a id={r.semver} />
            <h3 className="title-l separated mbs">
              {name(r)}{' '}
              <a href={`#${r.semver}`}>
                <i className="icon-link" />
              </a>
            </h3>
            <MarkdownPrecompiled source={r.description} />
          </div>
        </div>
      ))}
    </div>
  )
}

var MarkdownPrecompiled = ({ source }) => (
  <div className="ui-markdown" dangerouslySetInnerHTML={{ __html: source }} />
)
