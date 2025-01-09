/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const cx = require('classnames')
const parseUrl = require('url').parse
const buildUrl = require('url').format
const qs = require('qs')
const PageContent = require('./PageContent.cjsx')
const DashboardHeader = require('./DashboardHeader.cjsx')
const t = require('../../lib/i18n-translate.js')
const AsyncDashboardSection = require('../lib/AsyncDashboardSection.cjsx')
const Sidebar = require('./Sidebar.cjsx')
const TagCloud = require('../ui-components/TagCloud.cjsx')
const Preloader = require('../ui-components/Preloader.cjsx')

module.exports = React.createClass({
  displayName: 'DashboardSectionResources',

  getInitialState() {
    return {
      result: null
    }
  },

  _callback(result) {
    return this.setState({ result })
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { section, url } = param
    const is_clipboard = section.id === 'clipboard'
    const is_unpublished_entries = section.id === 'unpublished_entries'

    const mods = ['unpaginated']
    const fallback = section['is_empty?'] ? true : false

    const initial_props = {
      mods,
      fallback,
      enableOrdering: true,
      enableOrderByTitle: true,
      initial: {
        show_filter: false,
        is_clipboard
      }
    }

    const parsedUrl = parseUrl(url, true)
    delete parsedUrl.search
    parsedUrl.query['___sparse'] = `{"user_dashboard":{"${section.id}":{}}}`

    return (
      <div id={section.id}>
        <div className="ui-resources-header">
          <h2 className="title-l ui-resources-title">{section.title}</h2>
          {(() => {
            if (this.state.result === null) {
              const style = {
                width: '100px',
                height: '10px',
                marginTop: '10px',
                marginLeft: '30px',
                display: 'inline-block'
              }
              return <Preloader mods="small" style={style} />
            } else if (this.state.result === 'empty') {
              return <span style={{ marginLeft: '10px' }}>{t('dashboard_none_exist')}</span>
            } else {
              return (
                <a className="strong" href={section.href}>
                  {t('dashboard_show_all')}
                </a>
              )
            }
          })()}
        </div>
        <AsyncDashboardSection
          url={buildUrl(parsedUrl)}
          json_path={`user_dashboard.${section.id}`}
          fallback_url={section.href}
          initial_props={initial_props}
          callback={this._callback}
          renderEmpty={this.state.result === null}
        />
      </div>
    )
  }
})
