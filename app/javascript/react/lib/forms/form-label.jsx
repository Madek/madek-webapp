import React from 'react'
import t from '../../../lib/i18n-translate.js'
import MadekPropTypes from '../madek-prop-types.js'
import Icon from '../../ui-components/Icon.jsx'
import Link from '../../ui-components/Link.jsx'
import Tooltipped from '../../ui-components/Tooltipped.jsx'

const MetaKeyFormLabel = ({ metaKey, contextKey, mandatory }) => {
  let label = metaKey.label
  let hint = metaKey.hint
  let description = metaKey.description
  let documentation_url = metaKey.documentation_url

  // Override with contextKey values if present
  if (contextKey) {
    if (contextKey.label) {
      label = contextKey.label
    }
    if (contextKey.hint) {
      hint = contextKey.hint
    }
    if (contextKey.description) {
      description = contextKey.description
    }
    if (contextKey.documentation_url) {
      documentation_url = contextKey.documentation_url
    }
  }

  let linkToDocs
  if (documentation_url) {
    linkToDocs = (
      <Link href={documentation_url} target="_blank">
        {t('meta_data_meta_key_documentation_url')}
      </Link>
    )
  }

  if (mandatory) {
    label = label + ' *'
  }

  return (
    <div className="form-label">
      {label}
      {description && (
        <Tooltipped
          text={description}
          link={linkToDocs}
          id={(metaKey || contextKey).uuid + '_tooltip'}>
          <span className="ui-form-ui-ttip-toggle ui-ttip-toggle">
            <Icon i="question" />
          </span>
        </Tooltipped>
      )}
      <small>{hint}</small>
    </div>
  )
}

MetaKeyFormLabel.propTypes = {
  metaKey: MadekPropTypes.metaKey
}

export default MetaKeyFormLabel
module.exports = MetaKeyFormLabel
