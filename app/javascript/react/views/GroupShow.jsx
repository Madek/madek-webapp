/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import isEmpty from 'lodash/isEmpty'
import t from '../../lib/i18n-translate.js'
import PageHeader from '../ui-components/PageHeader.js'
import PageContent from './PageContent.jsx'
import MediaResourcesBox from '../decorators/MediaResourcesBox.jsx'
import libUrl from 'url'
import f from 'lodash'

const infotable = (group, members, vocabulary_permissions) =>
  f.compact([
    [t('group_meta_data_name'), group.name],
    group.institutional_name
      ? [t('group_meta_data_institutional_name'), group.institutional_name]
      : undefined,
    members
      ? [t('group_show_members'), f.map(members, member => member.label).join(', ')]
      : undefined,
    vocabulary_permissions
      ? [
          t('group_show_vocabulary_permissions'),
          f.map(vocabulary_permissions, function(permissions) {
            const { url } = permissions.vocabulary
            const { label } = permissions.vocabulary
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
              <div>
                <a href={url}>{label}</a>
                {` ${rights}`}
              </div>
            )
          })
        ]
      : undefined
  ])

const GroupShow = createReactClass({
  displayName: 'GroupShow',

  forUrl() {
    return libUrl.format(this.props.get.resources.config.for_url)
  },

  render() {
    const { get } = this.props

    const { group } = get

    const title = group.name

    const headerActions = get.group.edit_url ? (
      <a href={get.group.edit_url} className="primary-button">
        {t('group_show_edit_button')}
      </a>
    ) : (
      undefined
    )

    return (
      <PageContent>
        <PageHeader title={title} icon="privacy-group" actions={headerActions} />
        <div className="ui-container tab-content bordered bright rounded-right rounded-bottom">
          <div className="ui-container pal">
            <table className="borderless">
              <tbody>
                {f.map(infotable(group, get.members, get.vocabulary_permissions), function(
                  ...args
                ) {
                  const [label, value] = Array.from(args[0]),
                    i = args[1]
                  if (isEmpty(value)) {
                    return null
                  } else {
                    return (
                      <tr key={label + i}>
                        <td className="ui-summary-label">{label}</td>
                        <td className="ui-summary-content">{value}</td>
                      </tr>
                    )
                  }
                })}
              </tbody>
            </table>
          </div>
          <MediaResourcesBox
            for_url={this.props.for_url}
            get={get.resources}
            authToken={this.props.authToken}
            mods={[{ bordered: false }, 'rounded-bottom']}
            resourceTypeSwitcherConfig={{ showAll: false }}
            enableOrdering={true}
            enableOrderByTitle={true}
          />
        </div>
      </PageContent>
    )
  }
})

module.exports = GroupShow
