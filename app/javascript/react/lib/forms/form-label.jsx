/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import t from '../../../lib/i18n-translate.js'
import MadekPropTypes from '../madek-prop-types.js'
import Icon from '../../ui-components/Icon.jsx'
import Link from '../../ui-components/Link.jsx'
import Tooltipped from '../../ui-components/Tooltipped.jsx'

module.exports = createReactClass({
  displayName: 'MetaKeyFormLabel',
  propTypes: {
    metaKey: MadekPropTypes.metaKey
  },

  render(param) {
    let linkToDocs
    if (param == null) {
      param = this.props
    }
    const { metaKey, contextKey } = param
    let { label, hint, description, documentation_url } = metaKey

    if (contextKey) {
      if (contextKey.label) {
        ;({ label } = contextKey)
      }
      if (contextKey.hint) {
        ;({ hint } = contextKey)
      }
      if (contextKey.description) {
        ;({ description } = contextKey)
      }
      if (contextKey.documentation_url) {
        ;({ documentation_url } = contextKey)
      }
    }

    if (documentation_url) {
      linkToDocs = (
        <Link href={documentation_url} target="_blank">
          {t('meta_data_meta_key_documentation_url')}
        </Link>
      )
    }

    if (this.props.mandatory) {
      label = label + ' *'
    }

    return (
      <div className="form-label">
        {label}
        {(() => {
          if (description) {
            const ttId = (metaKey || contextKey).uuid + '_tooltip' // for a11y
            return (
              <Tooltipped text={description} link={linkToDocs} id={ttId}>
                <span className="ui-form-ui-ttip-toggle ui-ttip-toggle">
                  <Icon i="question" />
                </span>
              </Tooltipped>
            )
          }
        })()}
        <small>{hint}</small>
      </div>
    )
  }
})
