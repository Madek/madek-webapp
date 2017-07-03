React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
cx = require('classnames')
libUrl = require('url')
qs = require('qs')
PageContent = require('./PageContent.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
DashboardHeader = require('./DashboardHeader.cjsx')
t = require('../../lib/string-translation.js')('de')
AsyncDashboardSection = require('../lib/AsyncDashboardSection.cjsx')
Sidebar = require('./Sidebar.cjsx')
TagCloud = require('../ui-components/TagCloud.cjsx')

module.exports = React.createClass
  displayName: 'Dashboard'

  render: ({get, for_url} = @props) ->

    user_dashboard = get.user_dashboard
    sections = get.sections

    visible_sections = f.reject(sections, {hide_from_index: true})

    <PageContent>

      <DashboardHeader get={user_dashboard.dashboard_header} />

      <div className='ui-container midtone bordered rounded-right rounded-bottom table'>

        <div className='ui-container app-body-sidebar table-cell bright bordered-right rounded-bottom-left table-side'>
          <div className='ui-container rounded-bottom-left phm pvl'>

            <Sidebar sections={sections} for_url={for_url} />
          </div>

        </div>

        <div className='ui-container app-body-content table-cell table-substance'>
          <div className='ui-container pal'>

            {
              f.flatten(f.map(visible_sections, (section, index) =>

                f.compact([
                  <div id={section.id}>


                    <div className='ui-resources-header'>
                      <h2 className='title-l ui-resources-title'>
                        {section.title}
                      </h2>

                      <a className='strong' href={'/my/' + section.id}>
                        {t('resources_header_show_all')}
                      </a>

                    </div>


                    {
                      if section.partial == 'media_resources'
                        is_clipboard = section.id == 'clipboard'
                        is_unpublished_entries = section.id == 'unpublished_entries'
                        ui_component = 'Deco.MediaResourcesBox'

                        with_box = false
                        mods = ['unpaginated']
                        fallback = if section['is_empty?'] then true else false

                        initial_props = {
                          mods: mods,
                          withBox: with_box,
                          fallback: fallback,
                          enableOrdering: true,
                          enableOrderByTitle: true,
                          initial: {
                            show_filter: false,
                            is_clipboard: is_clipboard
                          }
                        }

                        <AsyncDashboardSection
                          component={ui_component}
                          url={'/my?___sparse={"user_dashboard":{"' + section.id + '":{}}}'}
                          json_path={'user_dashboard.' + section.id}
                          fallback_url={'/my/' + section.id}
                          initial_props={initial_props}
                        />

                    }

                    {
                      if section.partial == 'groups'

                        group_types = f.zipObject(f.map({
                          internal: t('internal_groups')
                          external: t('external_groups')
                        }, (label, type) ->
                          groups = f.map(get.user_dashboard[section.id][type], (entry) ->
                            {
                              children: entry.name,
                              href: entry.url
                            }
                          )
                          [type, {label: label, list: groups}]
                        ))

                        <div className='ui-container pbl'>
                          {
                            f.map(group_types, (groups, type) ->

                              if groups.list
                                <label className='ui-form-group columned phn'>
                                  <div className='form-label'>
                                    {groups.label}

                                  </div>
                                  <div className='form-item'>
                                    <TagCloud mod='label' list={groups.list} />
                                  </div>
                                </label>

                            )



                          }
                        </div>

                    }

                    {
                      if section.partial == 'keywords'

                        keywords = f.map(get.user_dashboard[section.id], (keyword) =>
                          {
                            children: keyword.label + ' ',
                            href: keyword.url,
                            count: keyword.usage_count
                          }
                        )

                        <div className='ui-container pbh' style={{paddingTop: '15px'}}>
                          {

                            if f.isEmpty(keywords)
                              t('no_keywords_fallback')
                            else
                              <TagCloud mod='label' list={keywords} />

                          }


                        </div>


                    }

                  </div>
                  ,
                  if index < visible_sections.length - 1
                    <hr className='separator mbm' />
                ])
              ))
            }

          </div>
        </div>
      </div>

    </PageContent>
