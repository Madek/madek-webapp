/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import { parse as parseUrl, format as buildUrl } from 'url'
import t from '../../lib/i18n-translate.js'
import AsyncDashboardSection from '../lib/AsyncDashboardSection.jsx'
import Preloader from '../ui-components/Preloader.jsx'

module.exports = createReactClass({
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
