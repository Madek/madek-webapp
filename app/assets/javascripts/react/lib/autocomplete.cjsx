React = require('react')
$jQuery = require('jquery')
require('@eins78/typeahead.js/dist/typeahead.jquery.js')

searchResources = require('../../lib/search.coffee')

initTypeahead = (domNode, resourceType, callback)->
  unless (dataSource = searchResources(resourceType))
    return console.error("No search backend for '#{resourceType}'!")

  # init typeahead.js plugin via jQuery
  $input = $jQuery(domNode)
  $input.typeahead({
    hint: false,
    highlight: true,
    minLength: 1,
    classNames: {
      wrapper: 'ui-autocomplete-holder'
      input: 'ui-typeahead-input',
      hint: 'ui-autocomplete-hint',
      menu: 'ui-autocomplete ui-menu',
      cursor: 'ui-autocomplete-cursor',
      suggestion: 'ui-menu-item'
    }
  },
  dataSource) # add events:
    .on 'typeahead:select typeahead:autocomplete', (event, item)=>
      event.preventDefault() # browser/jquery event, NOT a react event!
      $input.typeahead('val', '') # reset input field
      callback(item)


module.exports = React.createClass
  displayName: 'AutoComplete'

  onSelected: (item)->
    @props.onSelected?(item)

  componentDidMount: ()->
    domNode = React.findDOMNode(@refs.InputField)
    if @props.autoFocus then domNode(@refs.InputField).focus()
    if (resourceType = @props.resourceType)
      initTypeahead(domNode, resourceType, @onSelected)

  render: ()->
    {name, placeholder} = @props

    <input
      className="typeahead"
      type="text"
      placeholder={placeholder || 'search…'}
      ref="InputField"
      name={name} />
