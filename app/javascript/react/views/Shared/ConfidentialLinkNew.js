import React from 'react'
import f from 'lodash'
import { t } from '../../lib/ui.js'
import UI from '../../ui-components/index.js'
import RailsForm from '../../lib/forms/rails-form.jsx'
import DayPicker from 'react-day-picker'
import MomentLocaleUtils from 'react-day-picker/moment'
import currentLocale from '../../../lib/current-locale'
import Moment from 'moment'

const locale = currentLocale()
const disabledDays = day => Moment(day).isBefore(new Date())

class ConfidentialLinkNew extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      expiresAtDate: Moment(props.get.default_expires_at),
      useExpiryDate: true
    }
  }

  _toggleUseExpiryDate() {
    this.setState(current => ({ useExpiryDate: !current.useExpiryDate }))
  }

  _handleDayClick(day, modifiers) {
    if (f.get(modifiers, 'disabled', false) === false) this.setState({ expiresAtDate: Moment(day) })
  }

  render(props = this.props) {
    const action = f.get(props, 'get.actions.create')
    if (!action) return false

    const textAreaStyle = {
      minHeight: 'initial',
      resize: 'vertical'
    }

    return (
      <div className="by-center" style={{ marginLeft: 'auto', marginRight: 'auto' }}>
        <div
          className="ui-container bright bordered rounded mal phm pbm"
          style={{ display: 'inline-block', minWidth: '420px' }}>
          <RailsForm
            name="confidential_link"
            method={action.method}
            action={action.url}
            authToken={props.authToken}>
            <div className="ui-form-group rowed prn pbs">
              <h3 className="title-l">{t('confidential_links_create_title')}</h3>
            </div>
            <div className="ui-form-group rowed pan">
              <label className="form-label">
                {t('confidential_links_create_description')}
                <textarea
                  className="form-item block"
                  style={textAreaStyle}
                  name={'confidential_link[description]'}
                  rows="3"
                />
              </label>
            </div>
            <div className="mbm">
              <label className="form-label">
                <input
                  type="checkbox"
                  className="mrx"
                  checked={!!this.state.useExpiryDate}
                  onChange={this._toggleUseExpiryDate.bind(this)}
                />
                {t('confidential_links_create_set_expiration_date')}
              </label>
            </div>
            {this.state.useExpiryDate && (
              <div className="ui-form-group rowed pan">
                <label className="form-label">
                  {t('confidential_links_list_expires_hint_pre')}
                  {this.state.expiresAtDate.format('L')} — {this.state.expiresAtDate.fromNow()}
                </label>
                <input
                  type="hidden"
                  name="confidential_link[expires_at]"
                  value={this.state.expiresAtDate.format()}
                />
                <DayPicker
                  mode="single"
                  onDayClick={this._handleDayClick.bind(this)}
                  disabledDays={disabledDays}
                  initialMonth={this.state.expiresAtDate.toDate()}
                  fromMonth={Moment().toDate()}
                  toMonth={Moment().add(1, 'year').toDate()}
                  selectedDays={this.state.expiresAtDate.toDate()}
                  localeUtils={MomentLocaleUtils}
                  locale={locale}
                  key={this.state.expiresAtDate.toString()}
                />
              </div>
            )}
            <div className="ui-actions mtm">
              <UI.Button type="submit" className="primary-button">
                {t('confidential_links_create_submit')}
              </UI.Button>
              <UI.Button href={action.url} className="button">
                {t('confidential_links_create_cancel')}
              </UI.Button>
            </div>
          </RailsForm>
        </div>
      </div>
    )
  }
}

module.exports = ConfidentialLinkNew
