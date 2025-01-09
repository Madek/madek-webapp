/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const t = require('../../lib/i18n-translate.js')

module.exports = React.createClass({
  displayName: 'BatchHintBox',
  render() {
    return (
      <div className="app-body-sidebar table-cell ui-container table-side pll">
        <div className="ui-container bordered rounded">
          <div className="ui-form-group rowed separated">
            <div className="form-label">{t('meta_data_batch_hint_no_data')}</div>
            <div className="form-item">
              <input className="block" type="text" readOnly="true" />
            </div>
          </div>
          <div className="ui-form-group rowed highlight separated">
            <div className="form-label">
              {t('meta_data_batch_hint_differences')}
              <small>{t('meta_data_batch_hint_differences_override')}</small>
            </div>
            <div className="form-item">
              <input className="block" type="text" readOnly="true" />
            </div>
          </div>
          <div className="ui-form-group rowed">
            <div className="form-label">{t('meta_data_batch_hint_equal_data')}</div>
            <div className="form-item">
              <input
                className="block"
                type="text"
                value={t('meta_data_batch_hint_value')}
                readOnly="true"
              />
            </div>
          </div>
        </div>
      </div>
    )
  }
})
