React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
cx = require('classnames')
parseUrl = require('url').parse
buildUrl = require('url').format
qs = require('qs')
PageContent = require('./PageContent.cjsx')
DashboardHeader = require('./DashboardHeader.cjsx')
t = require('../../lib/i18n-translate.js')
AsyncDashboardSection = require('../lib/AsyncDashboardSection.cjsx')
Sidebar = require('./Sidebar.cjsx')
TagCloud = require('../ui-components/TagCloud.cjsx')
Preloader = require('../ui-components/Preloader.cjsx')

module.exports = React.createClass
  displayName: 'DashboardSectionResources'

  getInitialState: () ->
    {
      result: null
    }

  _callback: (result) ->
    @setState(result: result)

  render: ({section, url} = @props) ->

    is_clipboard = section.id == 'clipboard'
    is_unpublished_entries = section.id == 'unpublished_entries'

    mods = ['unpaginated']
    fallback = if section['is_empty?'] then true else false

    initial_props = {
      mods: mods,
      fallback: fallback,
      enableOrdering: true,
      enableOrderByTitle: true,
      initial: {
        show_filter: false,
        is_clipboard: is_clipboard
      }
    }

    parsedUrl = parseUrl(url, true)
    delete parsedUrl.search
    parsedUrl.query['___sparse'] = '{"user_dashboard":{"' + section.id + '":{}}}'

    <div id={section.id}>

      <div className='ui-resources-header'>
        <h2 className='title-l ui-resources-title'>
          {section.title}
        </h2>

        {
          if @state.result == null
            style = {
              width: '100px',
              height: '10px'
              marginTop: '10px',
              marginLeft: '30px',
              display: 'inline-block'
            }
            <Preloader mods='small' style={style} />
          else if @state.result == 'empty'
            <span style={{marginLeft: '10px'}}>{t('dashboard_none_exist')}</span>
          else
            <a className='strong' href={section.href}>
              {t('dashboard_show_all')}
            </a>
        }

      </div>

      <AsyncDashboardSection
        url={buildUrl(parsedUrl)}
        json_path={'user_dashboard.' + section.id}
        fallback_url={section.href}
        initial_props={initial_props}
        callback={@_callback}
        renderEmpty={@state.result == null}
      />
    </div>
