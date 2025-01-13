import React from 'react'
import DatePickerUtil from './DatePickerUtil.jsx'

class RenderDatePicker extends React.Component {
  constructor(props) {
    super(props)
  }

  _monthTexts() {
    return [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember'
    ]
  }

  _getMonthText() {
    return this._monthTexts()[this.props.month]
  }

  _renderNumber(index, row, rowCount, col, colCount, isValidDay) {
    var date = new Date()
    var currentYear = date.getFullYear()
    var currentMonth = date.getMonth()
    var currentDay = date.getDate() - 1

    var today =
      currentYear == this.props.year && currentMonth == this.props.month && currentDay == index

    // var selected = false
    // debugger
    // if(this.props.value) {
    //   var dayMonthYear = this.props.value
    //   selected = dayMonthYear.year == this.props.passedState.year && dayMonthYear.month == this.props.passedState.month && dayMonthYear.day == index
    // }

    var style = {
      width: '25px',
      height: '35px',
      textAlign: 'center',
      padding: '5px',
      borderStyle: 'solid',
      borderWidth: '1px 0px 0px 1px',
      borderRadius: '0px',
      borderColor: '#ccc',
      margin: '0px'
    }

    if (row == 0) {
      if (col == colCount - 1) {
        style = {
          width: '25px',
          height: '35px',
          textAlign: 'center',
          padding: '5px',
          borderStyle: 'solid',
          borderWidth: '0px 1px 0px 1px',
          borderRadius: '0px',
          borderColor: '#ccc',
          margin: '0px'
        }
      } else {
        style = {
          width: '25px',
          height: '35px',
          textAlign: 'center',
          padding: '5px',
          borderStyle: 'solid',
          borderWidth: '0px 0px 0px 1px',
          borderRadius: '0px',
          borderColor: '#ccc',
          margin: '0px'
        }
      }
    } else if (row == rowCount - 1) {
      if (col == 0) {
        style = {
          width: '25px',
          height: '35px',
          textAlign: 'center',
          borderStyle: 'solid',
          borderWidth: '1px 0px 1px 1px',
          borderRadius: '0px 0px 0px 10px',
          padding: '5px',
          borderColor: '#ccc',
          margin: '0px'
        }
      } else if (col == colCount - 1) {
        style = {
          width: '25px',
          height: '35px',
          textAlign: 'center',
          borderStyle: 'solid',
          borderWidth: '1px',
          borderRadius: '0px 0px 10px 0px',
          padding: '5px',
          borderColor: '#ccc',
          margin: '0px'
        }
      } else {
        style = {
          width: '25px',
          height: '35px',
          textAlign: 'center',
          padding: '5px',
          borderStyle: 'solid',
          borderWidth: '1px 0px 1px 1px',
          borderRadius: '0px',
          borderColor: '#ccc',
          margin: '0px'
        }
      }
    } else if (col == colCount - 1) {
      style = {
        width: '25px',
        height: '35px',
        textAlign: 'center',
        padding: '5px',
        borderStyle: 'solid',
        borderWidth: '1px 1px 0px 1px',
        borderRadius: '0px',
        borderColor: '#ccc',
        margin: '0px'
      }
    }

    if (today) {
      style.backgroundColor = '#efefef'
    }

    if (isValidDay) {
      var todayStyle = {
        textDecoration: 'none',
        color: '#333',
        fontSize: '12px',
        fontFamily: 'sans-serif'
      }
      // if(selected) {
      //   todayStyle = {
      //     color: '#333',
      //     textDecoration: 'none',
      //     border: '2px solid grey',
      //     borderRadius: '5px',
      //     fontSize: '12px',
      //     fontFamily: 'sans-serif',
      //     padding: '4px'
      //   }
      // }

      // if(selected) {
      return (
        <td style={style} key={index}>
          <a style={todayStyle} href="#" onClick={event => this.props._select(event, index)}>
            {index + 1}
          </a>
        </td>
      )

      // } else {
      //
      //   return (
      //     <td style={style} key={index}><a style={todayStyle} href='#' onClick={(event) => this._select(event, index)}>{index + 1}</a></td>
      //   )
      //
      // }
    } else {
      return (
        <td style={style} key={index}>
          <span style={{ fontSize: '12px', fontFamily: 'sans-serif' }}>&nbsp;</span>
        </td>
      )
    }
  }

  util() {
    return DatePickerUtil.createUtil(this.props.year, this.props.month)
  }

  renderWeekDays(week) {
    return this.util().renderWeekDays(week, (index, row, rowCount, col, colCount, isValidDay) => {
      return this._renderNumber(index, row, rowCount, col, colCount, isValidDay)
    })
  }

  _renderCalendar() {
    return this.util().renderWeeks(week => {
      return <tr key={week}>{this.renderWeekDays(week)}</tr>
    })
  }

  render() {
    const props = this.props

    var middle = {
      width: '25px',
      height: '35px',
      borderRadius: '0px',
      borderWidth: '1px 0px 1px 1px',
      borderStyle: 'solid',
      padding: '5px',
      textAlign: 'center',
      fontSize: '12px',
      fontFamily: 'sans-serif',
      backgroundColor: '#d8d8d8',
      color: '#6b6b6b',
      borderColor: '#d8d8d8'
    }
    var topLeft = {
      width: '25px',
      height: '35px',
      borderRadius: '10px 0px 0px 0px',
      borderWidth: '1px 0px 1px 1px',
      borderStyle: 'solid',
      padding: '5px',
      textAlign: 'center',
      fontSize: '12px',
      fontFamily: 'sans-serif',
      backgroundColor: '#d8d8d8',
      color: '#6b6b6b',
      borderColor: '#d8d8d8'
    }
    var topRight = {
      width: '25px',
      height: '35px',
      borderRadius: '0px 10px 0px 0px',
      borderWidth: '1px',
      borderStyle: 'solid',
      padding: '5px',
      textAlign: 'center',
      fontSize: '12px',
      fontFamily: 'sans-serif',
      backgroundColor: '#d8d8d8',
      color: '#6b6b6b',
      borderColor: '#d8d8d8'
    }

    return (
      <div style={{ display: 'inline-block' }}>
        <div style={{ fontSize: '12px', fontFamily: 'sans-serif' }}>
          <div
            style={{
              width: '30px',
              textAlign: 'left',
              display: 'inline-block',
              fontSize: '20px',
              color: '#777',
              padding: '10px'
            }}>
            <a onClick={e => props._previous(e)}>
              <span>&lt;</span>
            </a>
          </div>
          <div style={{ width: '153px', display: 'inline-block', textAlign: 'center' }}>
            <span>{this._getMonthText()}</span>&nbsp;<span>{props.year}</span>
          </div>
          <div
            style={{
              width: '30px',
              textAlign: 'right',
              display: 'inline-block',
              fontSize: '20px',
              color: '#777',
              padding: '10px'
            }}>
            <a onClick={e => props._next(e)}>
              <span>&gt;</span>
            </a>
          </div>
        </div>
        <table style={{ borderSpacing: '0px' }}>
          <thead>
            <tr>
              <th scope="col" style={topLeft}>
                <span title="Montag">Mo</span>
              </th>
              <th scope="col" style={middle}>
                <span title="Dienstag">Di</span>
              </th>
              <th scope="col" style={middle}>
                <span title="Mittwoch">Mi</span>
              </th>
              <th scope="col" style={middle}>
                <span title="Donnerstag">Do</span>
              </th>
              <th scope="col" style={middle}>
                <span title="Freitag">Fr</span>
              </th>
              <th scope="col" style={middle}>
                <span title="Samstag">Sa</span>
              </th>
              <th scope="col" style={topRight}>
                <span title="Sonntag">So</span>
              </th>
            </tr>
          </thead>
          <tbody>{this._renderCalendar()}</tbody>
        </table>
      </div>
    )
  }
}

module.exports = RenderDatePicker
