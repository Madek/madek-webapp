###

# AutoComplete

Component that wraps the jQuery.typeahead and provides search functionality
for Resources that we have a search backend for.

Example:
callback = (data)-> alert(data.uuid)
<AutoComplete name='foo[person]' resourceType='People' onSelect={callback}/>

FIXME: fails if even required on server (jQuery)!
###

React = require('react')
ReactDOM = require('react-dom')
PropTypes = React.PropTypes
jQuery = require('jquery')
require('@eins78/typeahead.js/dist/typeahead.jquery.js')

searchResources = require('../../lib/search.coffee')

initTypeahead = (domNode, resourceType, params, callback)->
  unless (dataSource = searchResources(resourceType, params))
    throw new Error "No search backend for '#{resourceType}'!"

  # init typeahead.js plugin via jQuery
  $input = jQuery(domNode)
  $input.typeahead({
    hint: false,
    highlight: true,
    minLength: 1,
    classNames: { # madek style:
      wrapper: 'ui-autocomplete-holder'
      input: 'ui-typeahead-input',
      hint: 'ui-autocomplete-hint',
      menu: 'ui-autocomplete ui-menu',
      cursor: 'ui-autocomplete-cursor',
      suggestion: 'ui-menu-item'
    }
  },
  dataSource) # add events (browser/jquery events, NOT from react!):
    .on 'keypress', (event)->
      # dont trigger submit on ENTER key:
      if event.keyCode is 13 then event.preventDefault()
      return null # otherwise we will get stupid warning

    .on 'typeahead:select typeahead:autocomplete', (event, item)->
      event.preventDefault()
      $input.typeahead('val', '') # reset input field text
      callback(item)

module.exports = React.createClass
  displayName: 'AutoComplete'
  propTypes:
    name: PropTypes.string.isRequired
    resourceType: PropTypes.string.isRequired
    onSelect: PropTypes.func.isRequired
    value: PropTypes.string
    placeholder: PropTypes.string
    className: PropTypes.string
    autoFocus: PropTypes.bool
    searchParams: PropTypes.object

  componentDidMount: ({resourceType, searchParams, autoFocus, onSelect} = @props)->
    initTypeahead(
      ReactDOM.findDOMNode(@refs.InputField), resourceType, searchParams, onSelect)
    if autoFocus then @focus()

  focus: ()->
    jQuery(ReactDOM.findDOMNode(@refs.InputField)).focus()

  render: ()->
    {name, value, placeholder, className} = @props

    # not a real FORM input field, so change the name:
    name = 'autocomplete_for_' + name

    <input ref="InputField"
      className={className + ' typeahead'}
      type="text"
      defaultValue={value or ''}
      placeholder={placeholder || 'search…'}
      name={name} />
