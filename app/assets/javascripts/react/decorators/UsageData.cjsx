React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
parseUrl = require('url').parse
t = require('../../lib/string-translation.js')('de')

TagCloud = require('../ui-components/TagCloud.cjsx')
Icon = require('../ui-components/Icon.cjsx')
resourceName = require('../lib/decorate-resource-names.coffee')



module.exports = React.createClass
  displayName: 'UsageData'

  render: ({responsible, edit_sessions, created_at_pretty, relation_counts, type} = @props.get) ->

    iconStyle = {
      position: 'relative'
      top: '2px'
    }

    <div className='col1of3'>
      <div className='ui-container prl'>
        <h3 className='title-l separated mbm'>{t('usage_data_responsibility_title')}</h3>
        <div className="ui-metadata-box">
          <table className="borderless">
            <tbody>
              <tr>
                <td className="ui-summary-label">{t('usage_data_responsible')}</td>
                <td className="ui-summary-content">
                  {
                    list = [
                      {
                        children: responsible.name,
                        href: responsible.url,
                        key: responsible.uuid
                      }
                    ]
                    <TagCloud mod='person' mods='small' list={list}></TagCloud>
                  }
                </td>
              </tr>
              <tr>
                <td className="ui-summary-label">
                  {if type == 'MediaEntry' then t('usage_data_import_at') else t('usage_data_created_at')}
                </td>
                <td className="ui-summary-content">
                  {created_at_pretty}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div className='ui-container prl'>
        <h3 className='title-l separated mvm mtl'>{t('usage_data_last_changes_title')}</h3>
        {
          if f.isEmpty(edit_sessions)
            <div>{t('usage_data_last_changes_empty')}</div>
          else
            <div className="ui-metadata-box">
              <table className="borderless">
                <tbody>
                  {
                    f.map(edit_sessions, (edit_session) ->
                      return if not edit_session.user
                      list = [{
                        href: edit_session.user.url
                        children: resourceName(edit_session.user)
                        key:  edit_session.user.uuid
                      }]
                      <tr>
                        <td className="ui-summary-label">{edit_session.change_date}</td>
                        <td className="ui-summary-content">
                          <TagCloud mod='person' mods='small' list={list}></TagCloud>
                        </td>
                      </tr>
                    )
                  }
                </tbody>
              </table>
            </div>
        }
      </div>
      <div className='ui-container prl'>
        <h3 className='title-l separated mvm mtl'>{t('usage_data_relations_title')}</h3>
        <div className="ui-metadata-box">
          <table className="borderless">
            <tbody>
              <tr>
                <td className="ui-summary-label">{t('usage_data_relations_parents')}</td>
                <td className="ui-summary-content">
                  <span>
                    {relation_counts.parent_collections_count} <Icon i='set' style={iconStyle} />
                  </span>
                </td>
              </tr>
              {
                if type == 'Collection'
                  <tr>
                    <td className="ui-summary-label">{t('usage_data_relations_children')}</td>
                    <td className="ui-summary-content">
                      <span>
                        <span>
                          {relation_counts.child_collections_count} <Icon i='set' style={iconStyle} />
                        </span>
                        <span style={{marginLeft: '15px'}}>
                          {relation_counts.child_media_entries_count} <Icon i='media-entry' style={iconStyle} />
                        </span>
                      </span>
                    </td>
                  </tr>
              }
            </tbody>
          </table>
        </div>
      </div>
    </div>
