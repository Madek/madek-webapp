# decorates: DynamicFilters
# fallback: no # only used interactive (client-side)
# ---
# TODO: accordion nav (needs async requests for dynamic filters)

React = require('react')
f = require('active-lodash')
css = require('classnames')
parseMods = require('../lib/parse-mods.coffee').fromProps
setUrlParams = require('../../lib/set-params-for-url.coffee')
# UiPropTypes = require('./propTypes.coffee')
MadekPropTypes = require('../lib/madek-prop-types.coffee')

Button = require('./Button.cjsx')
ButtonGroup = require('./ButtonGroup.cjsx')
Icon = require('./Icon.cjsx')
Link = require('./Link.cjsx')

module.exports = React.createClass
  displayName: 'SideFilter'
  propTypes:
    dynamic: React.PropTypes.array.isRequired
    accordion: React.PropTypes.objectOf(React.PropTypes.object).isRequired
    current: MadekPropTypes.resourceFilter
    onChange: React.PropTypes.func

  toggleSection: (section, bool)->
    @buildLinkFromAccordion f.assign(@props.accordion,
      f.set({}, section, (if bool then {} else undefined)))

  toggleSubsection: (section, subsection, bool)->
    current = f.get(@props.accordion, section) or {}
    @buildLinkFromAccordion(f.assign(@props.accordion,
      f.set({}, section, f.assign(current,
        f.set({}, subsection, (if bool then {} else undefined))))))

  addFilterToUrl: (key, parent, item)->
    current = f.presence(f.get @props.current, key) or []
    filter = addMetaDataItemToFilter(current, parent, item)
    @buildLinkFromFilter(key, filter)

  removeFilterFromUrl: (key, parent, item)->
    current = f.presence(f.get @props.current, key) or []
    filter = removeMetaDataItemFromFilter(current, parent, item)
    @buildLinkFromFilter(key, filter)

  buildLinkFromFilter: (key, filter)->
    filter = f.assign(@props.current, f.set({}, key, filter))
    params = {list: {page: 1, filter: JSON.stringify(filter)}}
    setUrlParams(@props.url, @props.query, params)

  buildLinkFromAccordion: (config)->
    params = {list: dyn_filter: JSON.stringify(config)}
    setUrlParams(@props.url, @props.query, params)

  render: ({dynamic, current, accordion} = @props)->
    baseClass = "ui-side-filter-list #{parseMods(@props)}"
    itemClass = 'ui-side-filter-lvl1-item ui-side-filter-item'

    # combine dynamic filter config and current filter state into ui config:
    # (set 'selected' status, sort by counts, etc)
    filters = uiStateFromConfigAndFilters(dynamic, current)

    onClick = null # TMP (event)=>
      # if f.isFunction(@props.onChange)
      #   @props.onChange(event) else undefined

    <ul className={baseClass}>
      {f.map filters, (filter, baseKey)=>
        # type of filter (like 'permissions' or 'meta_data')
        filterType = filter.filterType
        # always open when configured, or if user openened it
        isOpen = true # TMP f.get(@state, filter.uuid) or f.get(accordion, filter.uuid)
        href = null # TMP @toggleSection(filter.uuid, not isOpen)

        <li className={itemClass} key={filter.uuid}>
          <a className={css('ui-accordion-toggle', 'strong', open: isOpen)}
            href={href} onClick={onClick}>
            {filter.label} <i className='ui-side-filter-lvl1-marker'/>
          </a>

          <ul className={css('ui-accordion-body', 'ui-side-filter-lvl2', open: isOpen)}>
            {if isOpen then f.map filter.children, (child)=>
              isOpen = true # TMP f.get(accordion, [filter.uuid, child.uuid])
              href = null # TMP @toggleSubsection(filter.uuid, child.uuid, not isOpen)

              togglerClass = css('ui-accordion-toggle', 'weak', open: isOpen)
              toggleMarkerClass = css('ui-side-filter-lvl2-marker')
              togglebodyClass = css('ui-accordion-body', 'ui-side-filter-lvl3',
                open: isOpen)
              toggler = (
                <a className={togglerClass} href={href} onClick={onClick}>
                  <span className={toggleMarkerClass}/>
                    {child.label}</a>)
              keyClass = 'ui-side-filter-lvl2-item'
              keyBtnClass = 'ui-any-value'
              # make a 'select all/none' toggle
              keySelect = do (key = filterType, isOpen = isOpen, {selected} = child)=>
                btn = switch
                  # 'remove all' if any selected:
                  when f.any(child.children, 'selected')
                    icon: 'close'
                    title: 'Alle entfernen'
                    href: @removeFilterFromUrl(key, child)
                  # or 'toggle filter any for key' button for multi-selects
                  when child.multi
                    icon: 'checkbox'
                    iclass: 'active' if selected
                    title: 'Jegliche Werte'
                    href: @addFilterToUrl(key, child)
                return if not btn
                 # css fix because we are using a link:
                style = {display: 'inline-block', position: 'absolute', padding: 0}
                <Link style={style} className={keyBtnClass} title={btn.title}
                  href={btn.href} onClick={onClick}>
                  <Icon i={btn.icon} className={btn.iclass}/>
                </Link>

              <li className={keyClass} key={child.uuid}>
                {toggler}
                {keySelect}
                <ul className={togglebodyClass}>
                  {if isOpen then f.map child.children, (item)=>
                    linker = if item.selected then @removeFilterFromUrl else @addFilterToUrl
                    <FilterItem {...item} key={item.uuid}
                       href={linker(filterType, child, item)} onClick={onClick}/>
                  }
                </ul></li>}</ul></li>}</ul>

FilterItem = ({label, uuid, selected, href, count} = @props)->
  label = f.presence(label or uuid) or (
    console.error('empty FilterItem label!') and '(empty)')
  <li className={css('ui-side-filter-lvl3-item', active: selected)}>
    <Link mod='weak' href={href}>
      {label} <span className='ui-lvl3-item-count'>{count}</span>
    </Link>
  </li>

#  helpers
cleanupAndSortDynFilters = (dynamicFilters)->
  f.chain(dynamicFilters)
    .map((filter)->
      # type of filter (like 'permissions' or 'meta_data')
      filterType = filter.filter_type or filter.uuid
      keys = buildKeys(filter.children)
      # return if not f.present(keys)
      f.assign(filter,
        children: keys, filterType: filterType, filter_type: undefined))
    .compact()
    # .sortByOrder('position', 'asc')
    .presence().value()

buildKeys = (keys)->
  f.chain(keys)
    .map((key)->
      items = buildItems(key.children)
      #                                #TMP: dont remove if People…
      # return if not f.present(items) #and key.value_type isnt 'MetaDatum::People'
      f.assign(key, children: items))
    .compact().presence().value()

buildItems = (items)->
  f.chain(items)
    # .reject((item)->
    #   # NOTE: count implemented for everything, only filter if it is a number:
    #   return false if not f.isNumber(f.get(item, 'count'))
    #   item.count < 1)
    # .sortByOrder('count', 'desc')
    .compact().presence().value()

uiStateFromConfigAndFilters = (dynamicFilters, current)->
  # create state: cleanup + sort 3rd level keys by count (if present)
  state = cleanupAndSortDynFilters(dynamicFilters)

  # adds 'selected' status of dynamic filters
  # according to current list filter.
  f.each current, (filters, baseKey)-> f.each filters, (filter)->

    # get config for key (2nd level) mentioned in filter:
    key = f.chain(state).where(filterType: baseKey)
      .map('children').flatten()
      .find(uuid: filter.key)

    switch
      # - ignore if key not found in the config (bc of cleanup)
      when not key.present().value() then return
      # - filter has key without value -> filters for key -> set key as selected
      when not f.present(f.pick(filter, 'value', 'match'))
        key.set('selected', true).run()
      # - filter has key and specific value -> filters for value -> set value as selected
      when (id = f.get(filter, 'value'))
        key.get('children')
          .find(uuid: id)
          .set('selected', true).run()
      # - filter has key and match -> fail
      when (id = f.get(filter, 'match'))
        console.error('NOT IMPLEMENTED!', filter)

  return state

addMetaDataItemToFilter = (current, parent, item)->
  switch
    # a key is added without term:
    when parent.uuid and not item
      # remove the filter-by-term and add 1 filter-by-key
      f.reject(current, (filter)-> filter.key is parent.uuid)
        .concat({ key: parent.uuid })
    # a key is added with a term:
    when parent.uuid and item and (typeof item.uuid != 'undefined')
      # # remove any filter-by-key and add 1 filter-by-term
      f.reject(current, (
        (fil)->
          fil.key is parent.uuid and not f.present(f.pick(fil, 'value', 'match'))))
        .concat({ key: parent.uuid, value: item.uuid })
    else
      current

removeMetaDataItemFromFilter = (current, parent, item)->
  return if not current and not parent
  # if the result of the following is an empty list, remove nothing.
  f.presence switch
    # a key is removed:
    when parent.uuid and not item
      # remove any filter-by-key
      f.reject(current, (filter)-> filter.key is parent.uuid)
    # a term is removed:
    when parent.uuid and item and item.uuid
      # remove the filter-by-term
      f.reject(current, (filter)-> filter.value is item.uuid)
    else
      current
