React = require('react')
ReactDOM = require('react-dom')

AutoComplete = null


module.exports = React.createClass
  displayName: 'AutoCompleteWrapper'

  componentDidMount: () ->
    AutoComplete = require('./autocomplete.js')
    @forceUpdate()


  render: () ->
    <div>
      {
        if AutoComplete
          <AutoComplete {...@props} />
      }
    </div>
