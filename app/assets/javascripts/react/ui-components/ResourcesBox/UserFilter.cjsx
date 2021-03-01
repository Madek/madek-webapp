React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
css = require('classnames')
ui = require('../../lib/ui.coffee')
MadekPropTypes = require('../../lib/madek-prop-types.coffee')

loadXhr = require('../../../lib/load-xhr.coffee')

Icon = require('../Icon.cjsx')
Link = require('../Link.cjsx')
Preloader = require('../Preloader.cjsx')

jQuery = null

module.exports = React.createClass
  displayName: 'UserFilter'

  componentDidMount: () ->

    jQuery = require('jquery')
    require('@eins78/typeahead.js/dist/typeahead.jquery.js')

    domNode = ReactDOM.findDOMNode(@refs.testInput)
    jNode = jQuery(domNode)
    typeahead = jNode.typeahead({
      hint: false,
      highlight: true,
      minLength: 0,
      classNames: {
        wrapper: 'ui-autocomplete-holder'
        input: 'ui-typeahead-input',
        hint: 'ui-autocomplete-hint',
        menu: 'ui-autocomplete ui-menu ui-autocomplete-open-width ui-autocomplete-top-margin-2',
        cursor: 'ui-autocomplete-cursor',
        suggestion: 'ui-menu-item'
      }
    },
    {
      name: 'users',
      templates: {
        suggestion: (value) ->
          '<div class="ui-autocomplete-override-sidebar">' + value.label + '</div>'
      },
      limit: Number.MAX_SAFE_INTEGER,
      source: (term, callback) =>

        result = if term.length > 0

          termLower = term.toLowerCase()

          f.sortBy(
            f.filter(@props.node.children, (user) ->
              !user.selected && user.label.toLowerCase().indexOf(termLower) >= 0
            )
          )
        else
          f.sortBy(
            f.filter(@props.node.children, (user) ->
              !user.selected
            ),
            'label'
          )

        callback(result)

    });

    onSelect = (value) =>
      @props.userChanged(value, 'add')

    typeahead.on 'typeahead:select typeahead:autocomplete', (event, item)->
      event.preventDefault()
      jNode.typeahead('val', '')
      onSelect(item)

  render: ({node, placeholder} = @props)->

    selection = f.filter(node.children, 'selected')

    hasMore = f.size(selection) < f.size(node.children)

    clear = (selected, event) =>
      event.preventDefault()
      @props.userChanged(selected, 'remove')

    <ul className={@props.togglebodyClass}>
      <li key='input' className={css('ui-side-filter-lvl3-item')}>
        <div style={{position: 'relative'}}>
          <input ref='testInput' type='text' placeholder={placeholder}
            className='typeahead block'
            style={{display: (if !hasMore then 'none' else 'block')}} />
        </div>
      </li>
      {
        f.map(selection, (selected) ->
          <li key={'uuid_' + selected.uuid} className={css('ui-side-filter-lvl3-item', {active: true})}>
            <a className='link weak ui-link' onClick={(event) -> clear(selected, event)}>
              {selected.label}
              {
                if selected.label
                  <span className='ui-lvl3-item-count'>{selected.count}</span>
              }
            </a>
          </li>
        )
      }
    </ul>
