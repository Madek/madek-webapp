###

# AutoComplete

Component that wraps the jQuery.typeahead and provides search functionality
for Resources that we have a search backend for.

Example:
callback = (data)-> alert(data.uuid)
<AutoComplete name='foo[person]' resourceType='People' onSelect={callback}/>

NOTE: fails if even required on server (jQuery)!
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

ui = require('../lib/ui.coffee')
cx = ui.cx
t = ui.t('de')
searchResources = require('../../lib/search.coffee')

initTypeahead = (domNode, resourceType, params, conf, existingValues, valueFilter, onSelect, onAdd, positionRelative)->
  {minLength, localData} = conf
  unless (searchBackend = searchResources(resourceType, params, localData))
    throw new Error "No search backend for '#{resourceType}'!"

  typeaheadConfig = {
    hint: false,
    highlight: true,
    minLength: minLength,
    classNames: { # madek style:
      wrapper: 'ui-autocomplete-holder'
      input: 'ui-typeahead-input',
      hint: 'ui-autocomplete-hint',
      menu: cx('ui-autocomplete ui-menu ui-autocomplete-open-width', {'ui-autocomplete-position-relative': positionRelative}),
      cursor: 'ui-autocomplete-cursor',
      suggestion: 'ui-menu-item'
    }
  }

  dataSet = f.merge(searchBackend, {
    # HTML (not React!) templates
    templates: {
      pending: '<div class="ui-preloader small" style="height: 1.5em"></div>',
      notFound: '<div class="paragraph-l by-center">' + t('app_autocomplete_no_results') + '</div>',
      suggestion: (value) ->
        line = f.get(value, searchBackend.displayKey)

        # wrap/set as disabled if existing value
        if existingValues && f.includes(existingValues(), line) || valueFilter && valueFilter(value)
          line = '<span class="ui-autocomplete-disabled" title="' +
            + t('meta_data_input_keywords_existing') + '">' +
            line + "</span>"

        '<div>' + line + '</div>'
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

    if event.keyCode is 27 # on ESCAPE key
      # If you do not remove the focus explicitly, then only the
      # dropdown disappears, but the focus stays. If you click then
      # on the input again, the focus is already there and the
      # dropdown will not open, since the focus does not change.
      $input.blur()

    return null # otherwise we will get stupid warning

  typeahead.on 'typeahead:select typeahead:autocomplete', (event, item)->
    event.preventDefault()
    # Hack: We want the newly selected value to be greyed out, which needs a redraw.
    # To trigger a redraw, we simulate entering something in the text input.
    # If we would just set it to '' then if the field already was '' there would be
    # no redraw. So we first have to set it to a different value ' '.
    $input.typeahead('val', ' ')
    $input.typeahead('val', '')
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
    {resourceType, searchParams, autoFocus, config, existingValues, valueFilter, onSelect, onAddValue, positionRelative} = @props
    conf = f.defaults config,
      minLength: 1
    inputDOM = ReactDOM.findDOMNode(@refs.InputField)
    initTypeahead(inputDOM, resourceType, searchParams, conf, existingValues, valueFilter, onSelect, onAddValue, positionRelative)
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
