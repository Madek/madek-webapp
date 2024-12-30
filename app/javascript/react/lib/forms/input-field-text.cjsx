React = require('react')
classNames = require('classnames')
_ = require('lodash')
jQuery = require('jquery')

module.exports = React.createClass
  displayName: 'InputFieldText'
  propTypes:
    name: React.PropTypes.string
    type: React.PropTypes.string
    value: React.PropTypes.string
    placeholder: React.PropTypes.string
    className: React.PropTypes.string
    onChange: React.PropTypes.func

  setInputRef: (element) ->
    @inputRef = element

  componentDidMount: ->
    @initSuggestions() if @inputRef

  initSuggestions: ->
    require('@eins78/typeahead.js/dist/typeahead.jquery.js')

    $input = jQuery(@inputRef)
    $input.typeahead({
      minLength: 0,
      highlight: true,
      classNames: { # madek style:
        wrapper: 'ui-autocomplete-holder ui-autocomplete-position-relative',
        input: 'ui-typeahead-input',
        hint: 'ui-autocomplete-hint',
        menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width',
        cursor: 'ui-autocomplete-cursor',
        suggestion: 'ui-menu-item'
      }
    },
    {
      name: 'templates',
      source: (query, syncResults, asyncResults) =>
        syncResults(@suggestions())
    })
    if @props.onChange
      $input.on('typeahead:select', (event) => @props.onChange(event))

  suggestions: ->
    _.compact(
      _.concat(
        _.get(@props, 'metaKey.copyright_notice_default_text', ''),
        _.get(@props, 'metaKey.copyright_notice_templates', [])
      )
    )

  render: ({name, type, value, placeholder, className, metaKey} = @props) ->

    Element =
      if metaKey and metaKey.text_type and metaKey.text_type is 'block'
        'textarea'
      else
        'input'

    style =
      textIndent: '0em'
      paddingLeft: '8px'

    commonProps =
      name: name
      placeholder: placeholder
      className: classNames(className, 'block')

    if @props.onChange
      _.set(commonProps, 'onChange', @props.onChange)

    if _.get(metaKey, 'uuid') is 'madek_core:copyright_notice'
      defaultValue = _.get(@props, 'metaKey.copyright_notice_default_text', '')

      <input
        ref={@setInputRef}
        type="text"
        defaultValue={value or defaultValue}
        data-autocomplete-for={name}
        {...commonProps} />
    else
      <Element
        type={type or 'text'}
        defaultValue={value or ''}
        style={style}
        {...commonProps} />
