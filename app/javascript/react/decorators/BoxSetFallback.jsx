import React from 'react'
import ReactDOM from 'react-dom'
import f from 'lodash'
import BoxTitlebarRender from './BoxTitlebarRender.jsx'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'
import setsFallbackUrl from '../../lib/sets-fallback-url.js'

class BoxSetFallback extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    var fallback = this.props.fallback
    var try_collections = this.props.try_collections
    var currentUrl = this.props.currentUrl
    var usePathUrlReplacement = this.props.usePathUrlReplacement
    var resetFilterLink = this.props.resetFilterLink

    if (!fallback) {
      return null
    }

    if (!f.isBoolean(fallback)) {
      // we are given a fallback message, use it
      return fallback
    } else {
      // otherwise, build default fallback message:

      var renderMessage = () => {
        var setsUrl = setsFallbackUrl(currentUrl, usePathUrlReplacement)
        if (try_collections && setsUrl) {
          return (
            <div>
              {t('resources_box_no_content_but_sets_1')}
              <a href={setsUrl}>{t('resources_box_no_content_but_sets_2')}</a>
              {t('resources_box_no_content_but_sets_3')}
            </div>
          )
        } else {
          return t('resources_box_no_content')
        }
      }

      var renderBr = () => {
        if (resetFilterLink) {
          return <br />
        } else {
          return null
        }
      }

      return (
        <div className="pvh mth mbl">
          <div className="title-l by-center">
            {renderMessage()}
            {renderBr()}
            {resetFilterLink}
          </div>
        </div>
      )
    }
  }
}

module.exports = BoxSetFallback
