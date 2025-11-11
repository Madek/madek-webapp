// Input field enhanced with Calendar-Date-Picker

const LOCALE = 'de' // not configurable yet, see also the 'moment/locale' below
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Overlay from 'react-bootstrap/lib/Overlay'
import moment from 'moment'
import 'moment/locale/de'
import DayPicker, { DateUtils } from 'react-day-picker'
import MomentLocaleUtils from 'react-day-picker/moment'
import isDate from 'lodash/isDate'
import isEmpty from 'lodash/isEmpty'
import memoize from 'lodash/memoize'

const lazyDate = memoize(strOrDate => {
  if (isEmpty(strOrDate)) return
  const d = isDate(strOrDate) ? strOrDate : moment(strOrDate, 'L', true).toDate()
  if (!isNaN(d)) return d
})
const propTypeLazyDate = PropTypes.oneOfType([PropTypes.string, PropTypes.instanceOf(Date)])

class DatePicker extends Component {
  constructor(props) {
    super(props)
    this.state = {
      value: props.value,
      day: undefined,
      isFocused: false
    }
    this.focus = this.focus.bind(this)
    this._onInputChange = this._onInputChange.bind(this)
    this._onDaySelect = this._onDaySelect.bind(this)
    this._setDatefromText = this._setDatefromText.bind(this)
    this._onInputFocus = this._onInputFocus.bind(this)
    this._onPickerClick = this._onPickerClick.bind(this)
    this._onInputBlur = this._onInputBlur.bind(this)
    this._timeouts = {}
  }

  // method to focus the input field
  focus() {
    clearTimeout(this._timeouts.focus)
    this._timeouts.focus = setTimeout(() => this.inputEl && this.inputEl.focus(), 0)
  }

  // show Picker when input has focus, hide it *except* when calender is clicked
  _onPickerClick() {
    this.clickedPicker = true
  }
  _onInputBlur() {
    if (this.clickedPicker) {
      this.focus()
    } else {
      this.setState({ isFocused: false })
    }
  }
  _onInputFocus() {
    this.setState({ isFocused: true }, () => {
      if (!this.clickedPicker) {
        const initial = this.state.day || lazyDate(this.props.initialDate)
        initial && this.dayPicker && this.dayPicker.showMonth(initial)
      }
      this.clickedPicker = false
    })
  }

  // set value and parsed day when text input
  _onInputChange(e) {
    const { value } = e.target
    this._setDatefromText(value)
    this.props.onChange(value)
  }

  // set day and formatted value when day selection from calendar
  _onDaySelect(day, { disabled }) {
    if (disabled) return
    const value = moment(day).format('L')
    this.props.onChange(value)
    this.props.onSelect && this.props.onSelect(day)
    this.setState({ day, value }, () => {
      this.inputEl && this.inputEl.blur()
    })
  }

  // NOTE: when valid day is parsed/set, has DOM side effects (moving calendar month)
  _setDatefromText(value) {
    const momentDay = moment(value, 'L', true)
    if (momentDay.isValid()) {
      const day = momentDay.toDate()
      this.setState({ value, day }, () => {
        // after state did update, switch month
        this.dayPicker && this.dayPicker.showMonth(this.state.day)
      })
    } else {
      this.setState({ value, day: null })
    }
  }

  // Lifecycle:
  // NOTE: on handling the input value
  // - form value MUST be kept in internal state (perf)
  // - it is *based* on the value *prop*
  // - onChange is triggered when value changes (likely updates value prop in parent)
  // - therefore, if value prop changes, we must also set the state
  // - also, calendar-handling is not in constructor because it is a side effect
  componentDidMount() {
    this._setDatefromText(this.props.value)
  }
  componentDidUpdate(prevProps) {
    if (prevProps.value !== this.props.value) {
      this._setDatefromText(this.props.value)
    }
  }
  // cleanup
  componentWillUnmount() {
    Object.keys(this._timeouts).forEach(k => clearTimeout(this._timeouts[k]))
  }

  render({ props, state } = this) {
    // extract props. rest goes to DayPicker
    const { id, className, placeholder, laterThan, initialDate, ...restProps } = props

    return (
      <div id={`${id}.DatePicker`} className="ui-datepicker">
        <input
          type="text"
          className={className}
          placeholder={placeholder}
          value={state.value || ''}
          onChange={this._onInputChange}
          onFocus={this._onInputFocus}
          onBlur={this._onInputBlur}
          ref={el => {
            this.inputEl = el
          }}
        />

        {/* NOTE: custom overlay consist of Overlay + child div */}
        <Overlay
          placement="bottom"
          show={this.inputEl && this.state.isFocused}
          container={this}
          target={() => this.inputEl}>
          <div className="ui-datepicker--overlay" onMouseDown={this._onPickerClick}>
            <DayPicker
              {...restProps}
              locale={LOCALE}
              localeUtils={MomentLocaleUtils}
              onDayClick={this._onDaySelect}
              selectedDays={state.day}
              disabledDays={day => {
                if (!laterThan) return
                const beforeDate = lazyDate(laterThan)
                return day < beforeDate || DateUtils.isSameDay(day, beforeDate)
              }}
              initialMonth={state.day || lazyDate(initialDate)}
              ref={el => {
                this.dayPicker = el
              }}
            />
          </div>
        </Overlay>
      </div>
    )
  }
}

DatePicker.propTypes = {
  value: PropTypes.string,
  onChange: PropTypes.func.isRequired, // returns String!
  onSelect: PropTypes.func, // returns Date!
  className: PropTypes.string,
  placeholder: PropTypes.string,
  initialDate: propTypeLazyDate,
  laterThan: propTypeLazyDate
}

DatePicker.defaultProps = {
  id: Math.random().toString().slice(2)
}

export default DatePicker

// export helpers for constistent config (locale etc)
export const parseDate = str => lazyDate(str)
