React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
cx = require('classnames')
libUrl = require('url')
qs = require('qs')
PageContent = require('./PageContent.cjsx')
DashboardHeader = require('./DashboardHeader.cjsx')
t = require('../../lib/i18n-translate.js')
Sidebar = require('./Sidebar.cjsx')
TagCloud = require('../ui-components/TagCloud.cjsx')

module.exports = React.createClass
  displayName: 'DashboardSectionKeywords'

  render: ({section, sectionResources} = @props) ->

    keywords = f.map(sectionResources, (keyword) =>
      {
        children: keyword.label + ' ',
        href: keyword.url,
        count: keyword.usage_count
      }
    )

    <div id={section.id}>

      <div className='ui-resources-header'>
        <h2 className='title-l ui-resources-title'>
          {section.title}
        </h2>

        {
          if f.isEmpty(keywords)
            <span style={{marginLeft: '10px'}}>{t('dashboard_none_exist')}</span>
          else
            <a className='strong' href={section.href}>
              {t('dashboard_show_all')}
            </a>
        }

      </div>

      {
        if !f.isEmpty(keywords)
          <div className='ui-container pbh' style={{paddingTop: '15px'}}>
            <TagCloud mod='label' list={keywords} />
          </div>
      }
    </div>
