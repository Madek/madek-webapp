React = require('react')

module.exports = React.createClass
  displayName: 'InputFieldText'
  propTypes:
    name: React.PropTypes.string.isRequired
  render: ({name, type, value, placeholder, className, autofocus, autocomplete} = @props)->
    <input type={type or 'text'} className={className + ' block'}
      name={name} defaultValue={value or ''} placeholder={placeholder} autoFocus={autofocus} autoComplete={autocomplete}/>
