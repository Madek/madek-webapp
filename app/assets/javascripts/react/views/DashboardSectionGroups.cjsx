React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
cx = require('classnames')
libUrl = require('url')
qs = require('qs')
PageContent = require('./PageContent.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
DashboardHeader = require('./DashboardHeader.cjsx')
t = require('../../lib/i18n-translate.js')
Sidebar = require('./Sidebar.cjsx')
TagCloud = require('../ui-components/TagCloud.cjsx')

module.exports = React.createClass
  displayName: 'DashboardSectionGroups'

  render: ({section, sectionResources} = @props) ->

    group_types = f.zipObject(f.map({
      internal: t('internal_groups')
      delegations: t('responsibility_groups')
      authentication: t('authentication_groups')
      external: t('external_groups')
    }, (label, type) ->
      groups = f.map(sectionResources[type], (entry) ->
        {
          children: entry.name,
          href: entry.url
        }
      )
      [type, {label: label, list: groups}]
    ))

    <div id={section.id}>

      <div className='ui-resources-header'>
        <h2 className='title-l ui-resources-title'>
          {section.title}
        </h2>

        <a className='strong' href={section.href}>
          {t('dashboard_show_all')}
        </a>

      </div>

      <div className='ui-container pbl'>
        {
          f.map(group_types, (groups, type) ->

            if groups.list
              <label className='ui-form-group columned phn' key={type}>
                <div className='form-label'>
                  {groups.label}
                </div>

                {
                  if f.isEmpty(groups.list)
                    <div className='form-item' style={{paddingTop: '5px'}}>
                      {t('dashboard_none_exist')}
                    </div>
                  else
                    <div className='form-item'>
                      <TagCloud mod='label' list={groups.list} />
                    </div>
                }

              </label>

          )

        }
      </div>

    </div>
