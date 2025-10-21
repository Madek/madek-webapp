import React from 'react'
import { isEmpty } from '../../lib/utils.js'
import t from '../../lib/i18n-translate.js'
import PageHeader from '../ui-components/PageHeader.js'
import PageContent from './PageContent.jsx'
import MediaResourcesBox from '../decorators/MediaResourcesBox.jsx'

const infotable = (group, members, vocabulary_permissions) =>
  [
    [t('group_meta_data_name'), group.name],
    group.institutional_name
      ? [t('group_meta_data_institutional_name'), group.institutional_name]
      : undefined,
    members ? [t('group_show_members'), members.map(member => member.label).join(', ')] : undefined,
    vocabulary_permissions
      ? [
          t('group_show_vocabulary_permissions'),
          vocabulary_permissions.map(permissions => {
            const { url, label } = permissions.vocabulary
            const rights = (() => {
              if (permissions.use && permissions.view) {
                return t('group_show_permissions_view_use')
              } else if (permissions.view) {
                return t('group_show_permissions_view')
              } else if (permissions.user) {
                return t('group_show_permissions_use')
              }
            })()
            return (
              <div key={url}>
                <a href={url}>{label}</a>
                {` ${rights}`}
              </div>
            )
          })
        ]
      : undefined
  ].filter(Boolean)

const GroupShow = ({ get, for_url, authToken }) => {
  const { group } = get
  const title = group.name

  const headerActions = get.group.edit_url ? (
    <a href={get.group.edit_url} className="primary-button">
      {t('group_show_edit_button')}
    </a>
  ) : undefined

  return (
    <PageContent>
      <PageHeader title={title} icon="privacy-group" actions={headerActions} />
      <div className="ui-container tab-content bordered bright rounded-right rounded-bottom">
        <div className="ui-container pal">
          <table className="borderless">
            <tbody>
              {infotable(group, get.members, get.vocabulary_permissions).map(
                ([label, value], i) => {
                  if (isEmpty(value)) {
                    return null
                  }
                  return (
                    <tr key={label + i}>
                      <td className="ui-summary-label">{label}</td>
                      <td className="ui-summary-content">{value}</td>
                    </tr>
                  )
                }
              )}
            </tbody>
          </table>
        </div>
        <MediaResourcesBox
          for_url={for_url}
          get={get.resources}
          authToken={authToken}
          mods={[{ bordered: false }, 'rounded-bottom']}
          resourceTypeSwitcherConfig={{ showAll: false }}
          enableOrdering={true}
          enableOrderByTitle={true}
        />
      </div>
    </PageContent>
  )
}

export default GroupShow
module.exports = GroupShow
