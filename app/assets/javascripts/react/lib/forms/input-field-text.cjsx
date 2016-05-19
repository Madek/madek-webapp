React = require('react')

module.exports = React.createClass
  displayName: 'InputFieldText'
  propTypes:
    name: React.PropTypes.string
    type: React.PropTypes.string
    value: React.PropTypes.string
    placeholder: React.PropTypes.string
    className: React.PropTypes.string

  render: ({name, type, value, placeholder, className} = @props)->
    <input type={type or 'text'} className={className + ' block'}
      name={name} defaultValue={value or ''} placeholder={placeholder} />
