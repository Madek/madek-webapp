import React from 'react'
import RenderDatePickerMadek from './RenderDatePickerMadek.jsx'

class CustomDatePicker extends React.Component {
  constructor(props) {
    super(props)
  }

  _previous(event) {
    event.preventDefault()

    var date = new Date(this.props.passedState.year, this.props.passedState.month, 1)
    date.setMonth(date.getMonth() - 1)

    this.props.monthCallback({
      month: date.getMonth(),
      year: date.getFullYear()
    })
  }

  _next(event) {
    event.preventDefault()

    var date = new Date(this.props.passedState.year, this.props.passedState.month, 1)
    date.setMonth(date.getMonth() + 1)

    this.props.monthCallback({
      month: date.getMonth(),
      year: date.getFullYear()
    })
  }

  _select(event, index) {
    event.preventDefault()

    var year = this.props.passedState.year
    var month = this.props.passedState.month
    var day = index

    this.props.callback({
      day: day,
      month: month,
      year: year
    })
  }

  render() {
    return (
      <RenderDatePickerMadek
        month={this.props.passedState.month}
        year={this.props.passedState.year}
        selected={this.props.selected}
        _previous={e => this._previous(e)}
        _next={e => this._next(e)}
        _select={(e, i) => this._select(e, i)}
      />
    )
  }
}

module.exports = CustomDatePicker
