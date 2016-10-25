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
f = require('active-lodash')
libUi = require('../lib/ui.coffee')
cx = libUi.classnames
t = libUi.t('de')

jQuery = require('jquery')
require('@eins78/typeahead.js/dist/typeahead.jquery.js')

searchResources = require('../../lib/search.coffee')

initTypeahead = (domNode, resourceType, params, conf, onSelect, onAdd)->
  localData = conf.dataSource
  unless (searchBackend = searchResources(resourceType, params, localData))
    throw new Error "No search backend for '#{resourceType}'!"

  typeaheadConfig = {
    hint: false,
    highlight: true,
    minLength: conf.minLength,
    classNames: { # madek style:
      wrapper: 'ui-autocomplete-holder'
      input: 'ui-typeahead-input',
      hint: 'ui-autocomplete-hint',
      menu: 'ui-autocomplete ui-menu',
      cursor: 'ui-autocomplete-cursor',
      suggestion: 'ui-menu-item'
    }
  }

  dataSet = f.merge(searchBackend, {
    # HTML (not React!) templates
    templates: {
      pending: '<div class="ui-preloader small" style="height: 1.5em"></div>',
      notFound: '<div class="paragraph-l by-center">' + t('app_autocomplete_no_results') + '</div>',
    }
  })

  # init typeahead.js plugin via jQuery
  $input = jQuery(domNode)
  typeahead = $input.typeahead(typeaheadConfig, dataSet)

  # add events (browser/jquery events, NOT from react!):
  typeahead.on 'keypress', (event)->
    if event.keyCode is 13 # on ENTER key
      event.preventDefault() # NEVER trigger submit
      # but do (optional) callback IF any value
      if (value = f.presence($input.typeahead('val')))
        if f.isFunction(onAdd)
          onAdd(value)
          $input.typeahead('val', '') # reset input field text
    return null # otherwise we will get stupid warning

  typeahead.on 'typeahead:select typeahead:autocomplete', (event, item)->
    event.preventDefault()
    $input.typeahead('val', '') # reset input field text
    onSelect(item)

module.exports = React.createClass
  displayName: 'AutoComplete'
  propTypes:
    name: PropTypes.string.isRequired
    resourceType: PropTypes.string.isRequired
    onSelect: PropTypes.func.isRequired
    onAddValue: PropTypes.func
    value: PropTypes.string
    placeholder: PropTypes.string
    className: PropTypes.string
    autoFocus: PropTypes.bool
    searchParams: PropTypes.object
    config: PropTypes.shape
      minLength: PropTypes.number

  componentDidMount: ()->
    {resourceType, searchParams, autoFocus, config, onSelect, onAddValue} = @props
    conf = f.defaults config,
      minLength: 1
    inputDOM = ReactDOM.findDOMNode(@refs.InputField)
    initTypeahead(inputDOM, resourceType, searchParams, conf, onSelect, onAddValue)
    if autoFocus then @focus()

  focus: ()->
    jQuery(ReactDOM.findDOMNode(@refs.InputField)).focus()

  render: ()->
    {name, value, placeholder, className} = @props

    # NOTE: not a serializable <input> field, so 'name' attribute must be empty!
    #       (but we add it as a data prop for debugging/testing)

    <input ref="InputField"
      type="text"
      className={cx('typeahead', className)}
      defaultValue={value or ''}
      placeholder={placeholder || 'search…'}
      data-autocomplete-for={name} />
