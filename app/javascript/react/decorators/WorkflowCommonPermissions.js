import React from 'react'
import f from 'lodash'
import cx from 'classnames'
import TagCloud from '../ui-components/TagCloud.jsx'
import t from '../../lib/i18n-translate'
import labelize from '../../lib/labelize'

export default class WorkflowCommonPermissions extends React.Component {
  render() {
    const { responsible, write, read, read_public } = this.props.permissions
    const { showHeader } = this.props
    const supHeadStyle = { textTransform: 'uppercase', fontSize: '85%', letterSpacing: '0.15em' }

    return (
      <div>
        {showHeader && (
          <span style={supHeadStyle}>{t('workflow_common_settings_permissions_title')}</span>
        )}
        <ul>
          <li>
            <span className="title-s">
              {t('workflow_common_settings_permissions_responsible')}:{' '}
            </span>
            {!!responsible && (
              <TagCloud mod="person" mods="small inline" list={labelize([responsible])} />
            )}
          </li>
          <li>
            <span className="title-s">
              {t('workflow_common_settings_permissions_write')}
              {': '}
            </span>
            <TagCloud mod="person" mods="small inline" list={labelize(write)} />
          </li>
          <li>
            <span className="title-s">
              {t('workflow_common_settings_permissions_read')}
              {': '}
            </span>
            <TagCloud mod="person" mods="small inline" list={labelize(read)} />
          </li>
          <li>
            <span className="title-s">
              {t('workflow_common_settings_permissions_read_public')}
              {': '}
            </span>
            {read_public ? (
              <i className="icon-checkmark" title="Ja" />
            ) : (
              <i className="icon-close" title="Nein" />
            )}
          </li>
        </ul>
      </div>
    )
  }
}

WorkflowCommonPermissions.defaultProps = {
  showHeader: false
}
