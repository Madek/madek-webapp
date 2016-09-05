React = require('react')

module.exports = React.createClass
  displayName: 'InputFieldText'
  propTypes:
    name: React.PropTypes.string
    type: React.PropTypes.string
    value: React.PropTypes.string
    placeholder: React.PropTypes.string
    className: React.PropTypes.string

  render: ({name, type, value, placeholder, className, contextKey} = @props) ->

    Element =
      if contextKey and contextKey.text_element and contextKey.text_element == 'textarea'
        'textarea'
      else
        'input'

    style =
      textIndent: '0em'
      paddingLeft: '8px'

    if @props.onChange
      <Element type={type or 'text'} className={className + ' block'}
        name={name} value={value or ''} placeholder={placeholder}
        onChange={@props.onChange} style={style} />
    else
      <Element type={type or 'text'} className={className + ' block'}
        name={name} defaultValue={value or ''} placeholder={placeholder}
        style={style} />
