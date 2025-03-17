/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'lodash'
import t from '../../lib/i18n-translate.js'
import Icon from '../ui-components/Icon.jsx'

module.exports = createReactClass({
  displayName: 'UsageData',

  render(param) {
    if (param == null) {
      param = this.props.get
    }
    const { responsible, edit_sessions, created_at_pretty, relation_counts, type } = param
    const iconStyle = {
      position: 'relative',
      top: '2px'
    }

    return (
      <div className="col1of3">
        <div className="ui-container prl">
          <h3 className="title-l separated mbm">{t('usage_data_responsibility_title')}</h3>
          <div className="ui-metadata-box">
            <table className="borderless">
              <tbody>
                <tr>
                  <td className="ui-summary-label">{t('usage_data_responsible')}</td>
                  <td className="ui-summary-content">{responsible.name}</td>
                </tr>
                <tr>
                  <td className="ui-summary-label">
                    {type === 'MediaEntry' ? t('usage_data_import_at') : t('usage_data_created_at')}
                  </td>
                  <td className="ui-summary-content">{created_at_pretty}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div className="ui-container prl">
          <h3 className="title-l separated mvm mtl">{t('usage_data_last_changes_title')}</h3>
          {f.isEmpty(edit_sessions) ? (
            <div>{t('usage_data_last_changes_empty')}</div>
          ) : (
            <div className="ui-metadata-box">
              <table className="borderless">
                <tbody>
                  {f.map(edit_sessions, function (edit_session) {
                    if (!edit_session.user) {
                      return
                    }
                    return (
                      <tr key={edit_session.uuid}>
                        <td className="ui-summary-label" title={edit_session.change_date_iso}>
                          {edit_session.change_date}
                        </td>
                        <td className="ui-summary-content">{edit_session.user.name}</td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
        <div className="ui-container prl">
          <h3 className="title-l separated mvm mtl">{t('usage_data_relations_title')}</h3>
          <div className="ui-metadata-box">
            <table className="borderless">
              <tbody>
                <tr>
                  <td className="ui-summary-label">{t('usage_data_relations_parents')}</td>
                  <td className="ui-summary-content">
                    <span>
                      {relation_counts.parent_collections_count} <Icon i="set" style={iconStyle} />
                    </span>
                  </td>
                </tr>
                {type === 'Collection' ? (
                  <tr>
                    <td className="ui-summary-label">{t('usage_data_relations_children')}</td>
                    <td className="ui-summary-content">
                      <span>
                        <span>
                          {relation_counts.child_collections_count}{' '}
                          <Icon i="set" style={iconStyle} />
                        </span>
                        <span style={{ marginLeft: '15px' }}>
                          {relation_counts.child_media_entries_count}{' '}
                          <Icon i="media-entry" style={iconStyle} />
                        </span>
                      </span>
                    </td>
                  </tr>
                ) : undefined}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    )
  }
})
