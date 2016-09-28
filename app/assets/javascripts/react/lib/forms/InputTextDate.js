// Input for MetaDatum::TextDate
// support free text entry OR day from calendar OR duration (2 days from 2 calendars)

// Formating: Only strings are saved. On load, those strings are parsed to
// provide the best possible input subtype. This is hacky but save:
// In case of wrong parsing of exisiting data, the output won't change;
// so this won't alter any Data as long user does not explicitly change it!
// (If this should ever work with real timestamps, 1 picker for duration might be better)

import React, {Component, PropTypes} from 'react'
import compact from 'lodash/compact'
import isString from 'lodash/isString'
import ui from '../ui.coffee'
const t = ui.t('de')

import DatePicker, {parseDate} from '../../ui-components/DatePicker'

const SUBTYPES = ['text', 'timestamp', 'duration']
const formatDuration = (DateValues) => compact(DateValues).join(' - ')
const parseDuration = (MdValues) => isString(MdValues[0]) && MdValues[0].split(' - ')
const initialSubtype = (MdValues) => {
  const dates = (parseDuration(MdValues) || []).map(parseDate)
  if (!dates[0]) return SUBTYPES[0]
  if (!dates[1]) return SUBTYPES[1]
  return SUBTYPES[2]
}

class InputTextDate extends Component {
  constructor (props) {
    super(props)
    this.state = {
      isClient: true,
      subType: initialSubtype(props.values),
      values: parseDuration(props.values) || []
    }
    this._onSelectSubtype = this._onSelectSubtype.bind(this)
    this._formatValues = this._formatValues.bind(this)
  }

  _formatValues () { // stringify (internal) values for parent(s)
    return (this.state.subType === 'duration'
      ? formatDuration(this.state.values)
      : this.state.values[0]) || ''
  }
  _onInputChange (updates) {
    const cur = this.state.values
    // NOTE: "merges" 2 (sparse) arrays by position
    const values = [0, 1].map((i) => (isString(updates[i])) ? updates[i] : cur[i])
    this.setState({ values })
    this.props.onChange([this._formatValues(values)])
  }

  _onSelectSubtype (e) {
    const subType = e.target.value
    this.setState({subType})
    // set the internal value to an apropriate version for input type:
    const value = formatDuration(this.state.values)
    if (subType === 'text') {
      this.setState({values: [value]})
    } else {
      this.setState({values: parseDuration([value])})
    }
  }

  componentDidUpdate (_prevProps, prevState) {
    // DOM: when switching the input type, focus the input field right after
    if (prevState.subType !== this.state.subType) {
      this.inputEl && this.inputEl.focus()
    }
  }

  render ({props, state} = this) {
    const {id, name} = props
    const {subType, values} = state

    const stringifiedValue = this._formatValues(values)

    return <div className='form-item'>

      {/* formatted value for form serialization */}
      <input type='hidden' name={name} value={stringifiedValue} />

      {/* input type selector */}
      <div className='col1of3'>
        <div className='mrs'>
          <select id={`${id}.select-input-type`}
            className='block'
            onChange={this._onSelectSubtype} value={subType}>
            {SUBTYPES.map((type) =>
              <option value={type} key={type}
              >{t(`meta_data_input_date_type_${type}`)}</option>)}
          </select>
        </div>
      </div>

      {/* inputs by type */}
      <div>{(() => {
        switch (subType) {
          case 'text':
            return <div className='col2of3'>
              <input
                type='text'
                className='block'
                placeholder={t('meta_data_input_date_placeholder_timestamp')}
                onChange={(e) => this._onInputChange([e.target.value])}
                value={this._formatValues(state.values) || ''}
                ref={(el) => { this.inputEl = el }}
              />
            </div>

          case 'timestamp':
            return (<div className='col2of3'>
              <DatePicker
                id={id}
                className='block'
                value={state.values[0]}
                onChange={(val) => this._onInputChange([val])}
                placeholder={t('meta_data_input_date_placeholder_timestamp')}
                ref={(el) => { this.inputEl = el }}
              />
            </div>)

          case 'duration':
            return (<div>
              {/* NOTE: two pickers!
                  - when #1 has value, #2 is is prefered input (ref)
                  - when value of #1 is a date, only later ones can be choosen
              */}
              <div className='col1of3'>
                <div className='mrx'>
                  <DatePicker
                    id={`${id}.from`}
                    className='block'
                    value={state.values[0]}
                    onChange={(val) => this._onInputChange([val])}
                    placeholder={t('meta_data_input_date_placeholder_duration_from')}
                    ref={(el) => { this.inputEl = el }}
                  />
                </div>
              </div>
              <div className='col1of3'>
                <div className='mlx'>
                  <DatePicker
                    id={`${id}.to`}
                    className='block'
                    value={state.values[1]}
                    onChange={(val) => this._onInputChange([null, val])}
                    initialDate={state.values[0]}
                    laterThan={state.values[0]}
                    placeholder={t('meta_data_input_date_placeholder_duration_to')}
                    ref={(el) => { if (state.values[0]) this.inputEl = el }}
                  />
                </div>
              </div>
            </div>)

          default: throw new Error('Invalid input type!')
        } })()}
      </div>
    </div>
  }
}

InputTextDate.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  values: PropTypes.arrayOf(PropTypes.string).isRequired,
  multiple: PropTypes.bool.isRequired,
  active: PropTypes.bool.isRequired,
  onChange: PropTypes.func.isRequired
}

export default InputTextDate
