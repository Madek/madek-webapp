import React from 'react'
import ReactDOM from 'react-dom'
import l from 'lodash'

module.exports = {
  createUtil(propsYear, propsMonth) {
    return {
      _interval(n) {
        var arr = []
        for (var i = 0; i < n; i++) {
          arr.push(i)
        }
        return arr
      },

      _firstWeekday() {
        return new Date(propsYear, propsMonth, 1).getDay()
      },

      _daysInMonth() {
        return new Date(propsYear, propsMonth + 1, 1 - 1).getDate()
      },

      _firstCol() {
        var weekday = this._firstWeekday()
        // Start with monday as 0
        if (weekday == 0) weekday += 7
        return weekday - 1
      },

      daysInMonth() {
        return new Date(propsYear, propsMonth + 1, 1 - 1).getDate()
      },

      renderWeekDays(row, renderWeekDayCallback) {
        var rowCount = this._rowCount()
        return this._interval(7).map(col => {
          var index = row * 7 + col - this._firstCol()
          var isValidDay = index >= 0 && index < this.daysInMonth()
          return renderWeekDayCallback(index, row, rowCount, col, 7, isValidDay)
        })
      },

      _rowCount() {
        return Math.ceil((this._firstCol() + this._daysInMonth()) / 7.0)
      },

      renderWeeks(renderWeekCallback) {
        var rowCount = this._rowCount()
        return this._interval(rowCount).map(row => {
          return renderWeekCallback(row)
        })
      }
    }
  }
}
