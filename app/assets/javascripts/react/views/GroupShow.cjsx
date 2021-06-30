React = require('react')
isEmpty = require('lodash/isEmpty')
ui = require('../lib/ui.coffee')
t = require('../../lib/i18n-translate.js')
PageHeader = require('../ui-components/PageHeader.js')
PageContent = require('./PageContent.cjsx')
MediaResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
libUrl = require('url')
f = require('lodash')
resourceTypeSwitcher = require('../lib/resource-type-switcher.cjsx').resourceTypeSwitcher
parseUrl = require('url').parse
parseQuery = require('qs').parse
setUrlParams = require('../../lib/set-params-for-url.coffee')


link = (c, h) ->
  <a href={h}>{c}</a>

infotable = (group, members, vocabulary_permissions) ->
  f.compact([
    [
      t('group_meta_data_name'),
      group.name
    ],
    [
      t('group_meta_data_institutional_name'),
      group.institutional_name
    ] if group.institutional_name,
    [
      t('group_show_members'),
      f.map(members, (member) ->
          member.label
      ).join(', ')
    ] if members,
    [
      t('group_show_vocabulary_permissions'),
      f.map(vocabulary_permissions, (permissions) ->
        url = permissions.vocabulary.url
        label = permissions.vocabulary.label
        rights = if permissions.use && permissions.view
          t('group_show_permissions_view_use')
        else if permissions.view
          t('group_show_permissions_view')
        else if permissions.user
          t('group_show_permissions_use')
        <div>
          <a href={url}>
            {label}
          </a>
          {' ' + rights}
        </div>
      )
    ] if vocabulary_permissions
  ])

GroupShow = React.createClass
  displayName: 'GroupShow',


  forUrl: () ->
    libUrl.format(@props.get.resources.config.for_url)

  render: () ->

    get = @props.get

    group = get.group

    title = group.name

    renderSwitcher = (boxUrl) =>
      resourceTypeSwitcher(boxUrl, false, null)

    headerActions = if get.group.edit_url
      <a href={get.group.edit_url} className='primary-button'>
        {t('group_show_edit_button')}
      </a>

    <PageContent>
      <PageHeader title={title} icon='privacy-group' actions={headerActions} />
      <div className='ui-container tab-content bordered bright rounded-right rounded-bottom'>
        <div className='ui-container pal'>
          <table className='borderless'>
            <tbody>
              {
                f.map(
                  infotable(group, get.members, get.vocabulary_permissions),
                  ([label, value], i) ->
                    if isEmpty(value)
                      null
                    else
                      <tr key={label + i}>
                        <td className='ui-summary-label'>{label}</td>
                        <td className='ui-summary-content'>{value}</td>
                      </tr>
                )
              }
            </tbody>
          </table>
        </div>
        <MediaResourcesBox
          for_url={@props.for_url}
          get={get.resources} authToken={@props.authToken}
          mods={[ {bordered: false}, 'rounded-bottom' ]}
          renderSwitcher={renderSwitcher}
          enableOrdering={true}
          enableOrderByTitle={true} />
      </div>
    </PageContent>


module.exports = GroupShow
