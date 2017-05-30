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

parseUrl = require('url').parse
parseQuery = require('qs').parse
setUrlParams = require('../../../lib/set-params-for-url.coffee')
libUrl = require('url')
qs = require('qs')

jQuery = null

module.exports = React.createClass
  displayName: 'UserFilter'

  getInitialState: () ->
    {
      pending: true
      node: @props.node
    }

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
            f.filter(@state.node.children, (user) ->
              !user.selected && user.label.toLowerCase().indexOf(termLower) >= 0
            )
          )
        else
          f.sortBy(
            f.filter(@state.node.children, (user) ->
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


    @_loadData()



  _loadData: () ->

    currentUrl = parseUrl(@props.for_url)
    currentParams = parseQuery(currentUrl.query)
    newParams = f.cloneDeep(currentParams)

    unless newParams.list
      newParams.list = {}

    newParams.list.sparse_filter = @props.node.uuid

    loadXhr(
      {
        method: 'GET'
        url: setUrlParams(currentUrl, newParams)
      },
      (result, json) =>
        return unless @isMounted()
        if result == 'success'
          section = f.first(f.filter(
            json.dynamic_filters,
            (dynamic_filter) =>
              dynamic_filter.uuid == @props.parentUuid
          ))

          subSection = f.first(f.filter(
            section.children,
            (child) =>
              child.uuid == @props.node.uuid
          ))


          sectionFilters = @props.currentFilters[@props.parentUuid]

          items = f.map(
            subSection.children,
            (item) =>
              {
                label: (if item.detailed_name then item.detailed_name else item.label)
                uuid: item.uuid
                selected: !f.isEmpty(
                  f.filter(
                    sectionFilters,
                    (sectionFilter) =>
                      sectionFilter.key == @props.node.uuid && sectionFilter.value == item.uuid
                  )
                )
              }

          )



          @setState(node: f.assign(@state.node, {children: items}))

          @setState(pending: false)

        else
          @setState(pending: false)
          console.error('Cannot load dialog: ' + JSON.stringify(json))
    )




  render: ({placeholder} = @props)->

    selection = f.filter(@state.node.children, 'selected')

    hasMore = f.size(selection) < f.size(@state.node.children)

    clear = (selected, event) =>
      event.preventDefault()
      @props.userChanged(selected, 'remove')






    <ul className={@props.togglebodyClass}>


      <li key='preloader'>
        <Preloader mods='small' style={{display: (if @state.pending then 'block' else 'none')}} />
      </li>


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
            </a>
          </li>




        )
      }


    </ul>
