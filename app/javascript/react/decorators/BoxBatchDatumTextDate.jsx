import React from 'react'
import CustomDatePicker from '../lib/forms/CustomDatePicker.jsx'
import DatePickerPopup from '../lib/forms/DatePickerPopup.jsx'
import moment from 'moment'
import BoxRenderLabel from './BoxRenderLabel.jsx'
import l from 'lodash'

// Just import (although not used here) since it sets some global stuff for
// locales which are used in other components (tests failed).
// Remove it and check the failing tests.

import DatePicker from '../ui-components/DatePicker.js'

class BoxBatchDatumTextDate extends React.Component {
  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  renderValue() {
    return (
      <div
        style={{
          display: 'inline-block',
          width: '70%',
          verticalAlign: 'top'
        }}>
        {this.renderValueDate()}
      </div>
    )
  }

  render() {
    return (
      <div>
        <BoxRenderLabel
          trigger={this.props.trigger}
          metaKeyForm={this.props.metaKeyForm}
          editable={this.props.editable}
          vocabLabel={this.props.vocabLabel}
        />
        {this.renderValue()}
      </div>
    )
  }

  setMonthAt(d) {
    this.props.trigger(this.props.metaKeyForm, { action: 'set-month-at', date: d })
  }

  setMonthFrom(d) {
    this.props.trigger(this.props.metaKeyForm, { action: 'set-month-from', date: d })
  }

  setMonthTo(d) {
    this.props.trigger(this.props.metaKeyForm, { action: 'set-month-to', date: d })
  }

  setText(event) {
    var text = event.target.value
    this.props.trigger(this.props.metaKeyForm, { action: 'change-text', text: text })
  }

  showAt() {
    this.props.trigger(this.props.metaKeyForm, { action: 'show-at' })
  }

  showFromTo() {
    this.props.trigger(this.props.metaKeyForm, { action: 'show-from-to' })
  }

  closeAt() {
    this.props.trigger(this.props.metaKeyForm, { action: 'close-at' })
  }

  closeFromTo() {
    this.props.trigger(this.props.metaKeyForm, { action: 'close-from-to' })
  }

  dateTripleToString(d) {
    return moment()
      .date(d.day + 1)
      .month(d.month)
      .year(d.year)
      .format('DD.MM.YYYY')
  }

  selectAt(d) {
    this.props.trigger(this.props.metaKeyForm, {
      action: 'select-at',
      text: this.dateTripleToString(d)
    })
  }

  selectFrom(d) {
    if (this.props.metaKeyForm.data.selectedTo) {
      this.props.trigger(this.props.metaKeyForm, {
        action: 'select-from-to',
        text:
          this.dateTripleToString(d) +
          ' - ' +
          this.dateTripleToString(this.props.metaKeyForm.data.selectedTo)
      })
    } else {
      this.props.trigger(this.props.metaKeyForm, { action: 'select-from', date: d })
    }
  }

  selectTo(d) {
    if (this.props.metaKeyForm.data.selectedFrom) {
      this.props.trigger(this.props.metaKeyForm, {
        action: 'select-from-to',
        text:
          this.dateTripleToString(this.props.metaKeyForm.data.selectedFrom) +
          ' - ' +
          this.dateTripleToString(d)
      })
    } else {
      this.props.trigger(this.props.metaKeyForm, { action: 'select-to', date: d })
    }
  }

  renderSelected(d, onDate) {
    return (
      <div
        style={{
          float: 'left',
          width: '180px',
          textAlign: 'center',
          verticalAlign: 'middle',
          marginTop: '53px',
          height: '30px',
          paddingTop: '62px'
        }}>
        {this.dateTripleToString(d)}
        <div onClick={() => onDate()} className="button" style={{ marginLeft: '10px' }}>
          <i className="fa fa-calendar"></i>
        </div>
      </div>
    )
  }

  clearSelectedFrom() {
    this.props.trigger(this.props.metaKeyForm, { action: 'clear-select-from' })
  }

  renderFrom() {
    return (
      <div style={{ float: 'left' }}>
        <CustomDatePicker
          passedState={this.props.metaKeyForm.data.stateFrom}
          monthCallback={d => this.setMonthFrom(d)}
          callback={d => this.selectFrom(d)}
          selected={this.props.metaKeyForm.data.selectedFrom}
        />
      </div>
    )
  }

  clearSelectedTo() {
    this.props.trigger(this.props.metaKeyForm, { action: 'clear-select-to' })
  }

  renderTo() {
    return (
      <div style={{ float: 'left' }}>
        <CustomDatePicker
          passedState={this.props.metaKeyForm.data.stateTo}
          monthCallback={d => this.setMonthTo(d)}
          callback={d => this.selectTo(d)}
          selected={this.props.metaKeyForm.data.selectedTo}
        />
      </div>
    )
  }

  popupStyle() {
    return {
      clear: 'both',
      position: 'absolute',
      zIndex: '2000',
      backgroundColor: '#fff',
      padding: '0px',
      borderRadius: '5px',
      top: '7px',
      WebkitBoxShadow: '0px 1px 3px 0px rgba(0,0,0,0.5)',
      MozBoxShadow: '0px 1px 3px 0px rgba(0,0,0,0.5)',
      boxShadow: '0px 1px 3px 0px rgba(0,0,0,0.5)',
      width: this.props.metaKeyForm.data.showFromTo ? '500px' : null,
      left: this.props.metaKeyForm.data.showFromTo ? '-427px' : null
    }
    // return {
    //   clear: 'both',
    //   position: 'absolute',
    //   zIndex: '1000',
    //   backgroundColor: '#fff',
    //   border: '1px solid #ddd',
    //   padding: '10px',
    //   borderRadius: '5px',
    //   top: '60px'
    // }
  }

  renderAtDatePicker() {
    if (!this.props.metaKeyForm.data.showAt) {
      return null
    }

    return (
      <div style={{ position: 'relative' }}>
        <DatePickerPopup onClose={() => this.closeAt()} style={this.popupStyle()}>
          <CustomDatePicker
            passedState={this.props.metaKeyForm.data.stateAt}
            monthCallback={d => this.setMonthAt(d)}
            callback={d => this.selectAt(d)}
          />
        </DatePickerPopup>
      </div>
    )
  }

  renderFromToDatePickers() {
    if (!this.props.metaKeyForm.data.showFromTo) {
      return null
    }

    return (
      <div style={{ position: 'relative' }}>
        <DatePickerPopup onClose={() => this.closeFromTo()} style={this.popupStyle()}>
          {this.renderFrom()}
          <div
            style={{
              float: 'left',
              padding: '100px 30px 0px 30px',
              fontSize: '30px',
              color: '#bbb'
            }}>
            -
          </div>
          {this.renderTo()}
        </DatePickerPopup>
      </div>
    )
  }

  focus(event) {
    event.preventDefault()
    this.showAt()
  }

  renderValueDate() {
    if (!this.props.editable) {
      return this.props.metaKeyForm.data.text
    }

    return (
      <div>
        <div style={{ display: 'inline-block', width: 'calc(100% - 200px)' }}>
          <div style={{ display: 'block' }}>
            <input
              style={{
                borderRadius: '5px',
                border: '1px solid #ddd',
                padding: '5px',
                boxSizing: 'border-box',
                width: '100%',
                height: '30px',
                fontSize: '12px'
              }}
              value={this.props.metaKeyForm.data.text}
              onChange={e => this.setText(e)}
              onFocus={e => this.focus(e)}
            />
          </div>
          {this.renderAtDatePicker()}
        </div>
        <div style={{ display: 'inline-block' }}>
          <div onClick={() => this.showFromTo()} className="button" style={{ marginLeft: '10px' }}>
            <i className="fa fa-calendar"></i>
            {' - '}
            <i className="fa fa-calendar"></i>
          </div>
          {this.renderFromToDatePickers()}
        </div>
      </div>
    )
  }
}

module.exports = BoxBatchDatumTextDate
