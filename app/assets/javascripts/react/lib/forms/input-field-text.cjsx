React = require('react')

module.exports = React.createClass
  displayName: 'InputFieldText'
  propTypes:
    name: React.PropTypes.string.isRequired
  render: ({name, type, value, placeholder} = @props)->
    <input type={type or 'text'} className='block'
      name={name} defaultValue={value or ''} placeholder={placeholder}/>
