# decorates: DynamicFilters
# fallback: no # only used interactive (client-side)

React = require('react')
f = require('active-lodash')
css = require('classnames')
ui = require('../../lib/ui.coffee')
setUrlParams = require('../../../lib/set-params-for-url.coffee')
MadekPropTypes = require('../../lib/madek-prop-types.coffee')

Icon = require('../Icon.cjsx')
Link = require('../Link.cjsx')

module.exports = React.createClass
  displayName: 'SideFilter'
  propTypes:
    dynamic: React.PropTypes.array.isRequired
    accordion: React.PropTypes.objectOf(React.PropTypes.object).isRequired
    current: MadekPropTypes.resourceFilter.isRequired
    onChange: React.PropTypes.func


  # Note: We list in the menu the sections based on the meta data contexts.
  # But furthermore, we also for example list the media types as a section
  # with an artifical uuid "file". We must make sure, that we have not clash
  # for example, when a context has the id "file". Thats why section uuids must
  # be concatenated with the filter_type.
  # E.g. meta_data:copyright or media_files:file

  getAccordionSection: (sectionUuid) ->
    accordion = @state.accordion
    if not accordion.sections
      accordion.sections = {}

    section = accordion.sections[sectionUuid]
    if not section
      section = {
        isOpen: false,
        subSections: {}
      }
      accordion.sections[sectionUuid] = section
    section

  getAccordionSubSection: (sectionUuid, subSectionUuid) ->
    section = @getAccordionSection(sectionUuid)
    if not section.subSections
      section.subSections = {}
    subSection = section.subSections[subSectionUuid]
    if not subSection
      subSection = { isOpen: false }
      section.subSections[subSectionUuid] = subSection
    subSection

  toggleSection: (sectionUuid) ->
    section = @getAccordionSection(sectionUuid)
    section.isOpen = not section.isOpen
    @setState(accordion: @state.accordion)

  toggleSubSection: (sectionUuid, subSectionUuid)->
    subSection = @getAccordionSubSection(sectionUuid, subSectionUuid)
    subSection.isOpen = not subSection.isOpen
    @setState(accordion: @state.accordion)

  getInitialState: () ->
    javascript: false
    accordion: @props.accordion or {}

  componentDidMount: () ->
    @setState(javascript: true)



  componentWillMount: () ->
    f.each(@props.current.meta_data, (meta_datum) =>
      f.each(@props.dynamic, (section) =>
        f.each(section.children, (subSection) =>
          f.each(subSection.children, (filter) =>
            if filter.uuid == meta_datum.value
              @getAccordionSection(section.filter_type + '-' + section.uuid).isOpen = true
              @getAccordionSubSection(section.filter_type + '-' + section.uuid, subSection.uuid).isOpen = true
          )
        )
      )
    )
    @setState(accordion: @state.accordion)


  render: ({dynamic, current, accordion} = @props)->
    # TMP: ignore invalid dynamicFilters
    if !(f.isArray(dynamic) and f.present(f.isArray(dynamic)))
      return null

    # Clone the current filters, so as we can manipulate them
    # to give the result back to the parent component.
    current = f.clone(current)

    baseClass = ui.cx(ui.parseMods(@props), 'ui-side-filter-list')

    filters = initializeFilterTreeFromProps(dynamic, current)

    <ul className={baseClass}>
      {f.map filters, (filter) =>
        @renderSection(current, filter)
      }
    </ul>

  renderSection: (current, filter) ->

    itemClass = 'ui-side-filter-lvl1-item ui-side-filter-item'

    filterType = filter.filterType
    uuid = filter.uuid
    isOpen = @getAccordionSection(filterType + '-' + uuid).isOpen
    href = null

    toggleOnClick = () => @toggleSection(filterType + '-' + filter.uuid)

    <li className={itemClass} key={filterType + '-' + filter.uuid}>
      <a className={css('ui-accordion-toggle', 'strong', open: isOpen)}
        href={href} onClick={toggleOnClick}>
        {filter.label} <i className='ui-side-filter-lvl1-marker'/>
      </a>

      <ul className={css('ui-accordion-body', 'ui-side-filter-lvl2', open: isOpen)}>
        {if isOpen then f.map filter.children, (child) =>
          @renderSubSection(current, filterType, filter, child)
        }
      </ul>
    </li>

  renderSubSection: (current, filterType, parent, child) ->

    isOpen = @getAccordionSubSection(filterType + '-' + parent.uuid, child.uuid).isOpen

    keyClass = 'ui-side-filter-lvl2-item'
    togglebodyClass = css('ui-accordion-body', 'ui-side-filter-lvl3', open: isOpen)
    <li className={keyClass} key={child.uuid}>
      {@createToggleSubSection(filterType, parent, child, isOpen)}
      {@createMultiSelectBox(child, current, filterType)}
      <ul className={togglebodyClass}>
        {
          if isOpen then f.map(f.sortBy(child.children, (child) -> child.label), (item)=>
            @renderItem(current, child, item, filterType)
          )
        }
      </ul>
    </li>

  renderItem: (current, parent, item, filterType) ->

    onChange = @props.onChange
    addRemoveClick = () =>

      if item.selected then @removeItemFilter(onChange, current, parent, item, filterType) else @addItemFilter(onChange, current, parent, item, filterType)

    <FilterItem {...item} key={item.uuid} onClick={addRemoveClick}/>

  createToggleSubSection: (filterType, parent, child, isOpen) ->

    href = null

    toggleOnClick = (
      () -> @toggleSubSection(filterType + '-' + parent.uuid, child.uuid)
    ).bind(this)

    togglerClass = css('ui-accordion-toggle', 'weak', open: isOpen)
    toggleMarkerClass = css('ui-side-filter-lvl2-marker')

    <a className={togglerClass} href={href} onClick={toggleOnClick}>
      <span className={toggleMarkerClass}/>
      {child.label}
    </a>

  createMultiSelectBox: (child, current, filterType) ->

    showRemoveAll = f.any(child.children, 'selected')
    showSelectAll = child.multi and not showRemoveAll
    style = {display: 'inline-block', position: 'absolute', padding: 0}
    keyBtnClass = 'ui-any-value'

    multiSelectBox = undefined
    if showRemoveAll
      title = 'Alle entfernen'
      onChange = @props.onChange
      removeClick = () =>
        @removeSubSectionFilter(onChange, current, child, filterType)
      icon = 'close'
      multiSelectBox = <Link style={style} className={keyBtnClass} title={title} onClick={removeClick}>
        <Icon i={icon}/>
      </Link>

    if showSelectAll
      title = 'Jegliche Werte'
      icon = 'checkbox'
      iclass = 'active' if child.selected
      onChange = @props.onChange
      addClick = () =>
        if child.selected
          @removeSubSectionFilter(onChange, current, child, filterType)
        else
          @addSubSectionFilter(onChange, current, child, filterType)
      multiSelectBox = <Link style={style} className={keyBtnClass} title={title} onClick={addClick}>
        <Icon i={icon} className={iclass}/>
      </Link>

    return multiSelectBox

  addItemFilter: (onChange, current, parent, item, filterType) ->

    currentPerType = current[filterType] or []
    # When we add a child filter, the parent filter is no longer needed.
    currentPerType = f.reject(
      currentPerType,

      # Remove the filter, if it is in the section and consists only of
      # key, but has no value or match.
      # If multi is false, then we remove all from this section.
      (filter) ->
        preventDuplicate = filter.key is parent.uuid and filter.value is item.uuid
        removeSectionFilter = filter.key is parent.uuid and (not f.present(f.pick(filter, 'value', 'match')) or not parent.multi)
        preventDuplicate or removeSectionFilter

    # Add the Item filter.
    ).concat({ key: parent.uuid, value: item.uuid })

    current[filterType] = currentPerType
    onChange({
      action: 'added item'
      item: item
      current: current
      accordion: @state.accordion
    }) if onChange

  addSubSectionFilter: (onChange, current, parent, filterType) ->

    currentPerType = current[filterType] or []
    # Remove all Item filters in this section.
    currentPerType = f.reject(
      currentPerType,

      # Note: We here also remove an existing section filter actually.
      (filter) -> filter.key is parent.uuid

    # Add the Item filter.
    ).concat({ key: parent.uuid })

    current[filterType] = currentPerType
    onChange({
      action: 'added key'
      current: current
      accordion: @state.accordion
    }) if onChange

  removeItemFilter: (onChange, current, parent, item, filterType) ->

    currentPerType = current[filterType] or []
    # Remove the item filter.
    currentPerType = f.reject(currentPerType, (filter) -> filter.value is item.uuid)
    current[filterType] = currentPerType
    onChange({
      action: 'removed item'
      item: item
      current: current
      accordion: @state.accordion
    }) if onChange

  removeSubSectionFilter: (onChange, current, parent, filterType) ->

    currentPerType = current[filterType] or []
    # Remove the section filter.
    currentPerType = f.reject(currentPerType, (filter) -> filter.key is parent.uuid)
    current[filterType] = currentPerType
    onChange({
      action: 'removed key'
      current: current
      accordion: @state.accordion
    }) if onChange

FilterItem = ({label, uuid, selected, href, count, onClick} = @props) ->
  label = f.presence(label or uuid) or (
    console.error('empty FilterItem label!') and '(empty)')
  <li className={css('ui-side-filter-lvl3-item', active: selected)}>
    <Link mod='weak' onClick={onClick}>
      {label} <span className='ui-lvl3-item-count'>{count}</span>
    </Link>
  </li>

initializeFilterTreeFromProps = (dynamicFilters, current) ->
  tree = initializeSections(dynamicFilters)
  tree = forCurrentFiltersSelectItemsInTree(tree, current)

forCurrentFiltersSelectItemsInTree = (tree, current) ->

  selectItemForFilter = (item, filter) ->
    item.selected = true if item.uuid == filter.value

  selectInSubSection = (subSection, filter) ->
    for i, item of subSection.children
      subSection.selected = true if subSection.uuid == filter.key
      selectItemForFilter(item, filter)

  selectInSection = (section, filter) ->
    for i, subSection of section.children
      selectInSubSection(subSection, filter) if subSection.uuid == filter.key

  selectInTreePerFilter = (filterType, filter) ->
    for i, section of tree
      selectInSection(section, filter) if section.filterType == filterType

  for filterType, filtersPerType of current
    for i, filter of filtersPerType
      selectInTreePerFilter(filterType, filter)

  return tree

initializeSections = (dynamicFilters) ->
  tree = []
  for i, filter of dynamicFilters
    section = {
      filterType: filter.filter_type or filter.uuid
      children: initializeSubSections(filter.children)
      label: filter.label
      uuid: filter.uuid
    }
    tree.push(section)
  return tree

initializeSubSections = (filters) ->
  subSections = []
  for i, filter of filters
    subSection = {
      children: initializeItems(filter.children)
      label: filter.label
      uuid: filter.uuid
      # The default value of multi is true. This means, we only
      # check if the presenter has set the value to false explicitely.
      # If the presenter does not set the value at all, it is undefined,
      # and therefore it is set to true here.
      multi: true unless filter.multi is false
    }
    subSections.push(subSection)
  return subSections

initializeItems = (filters) ->
  items = []
  for i, filter of filters
    item = {
      label: filter.label
      uuid: filter.uuid
      count: filter.count
      selected: false
    }
    items.push(item)
  return items
