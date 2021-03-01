# decorates: DynamicFilters
# fallback: no # only used interactive (client-side)

React = require('react')
f = require('active-lodash')
t = require('../../../lib/i18n-translate.js')
css = require('classnames')
ui = require('../../lib/ui.coffee')
MadekPropTypes = require('../../lib/madek-prop-types.coffee')

Icon = require('../Icon.cjsx')
Link = require('../Link.cjsx')
UserFilter = require('./UserFilter.cjsx')

Preloader = require('../Preloader.cjsx')

parseQuery = require('qs').parse
setUrlParams = require('../../../lib/set-params-for-url.coffee')

loadXhr = require('../../../lib/load-xhr.coffee')

module.exports = React.createClass
  displayName: 'SideFilter'
  propTypes:
    dynamic: React.PropTypes.array
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
    sectionGroups: [
      {
        key: 'section_group_media_files',
        loaded: false,
        dynamic: null
      },
      {
        key: 'section_group_permissions',
        loaded: false,
        dynamic: null
      },
      {
        key: 'section_group_meta_data',
        loaded: false,
        dynamic: null
      }
    ]


  componentDidMount: () ->
    @setState(javascript: true)

    @_loadData()


  _loadData: () ->

    currentUrl = @props.forUrl

    currentParams = parseQuery(currentUrl.query)
    newParams = f.cloneDeep(currentParams)

    unless newParams.list
      newParams.list = {}

    newParams.list.sparse_filter = true
    newParams.list.show_filter = true


    f.each(
      @state.sectionGroups,
      (group) =>
        key = group.key

        jsonPath = @props.jsonPath
        jsonPath = jsonPath.substring(0, jsonPath.length - 'resources'.length)
        jsonPath += 'dynamic_filters.' + key

        loadXhr(
          {
            method: 'GET'
            url: setUrlParams(
              currentUrl,
              newParams,
              {
                ___sparse: JSON.stringify(f.set({}, jsonPath, {}))
              }
            )
          },
          (result, json) =>
            return unless @isMounted()
            if result == 'success'

              newSectionGroups = f.clone(@state.sectionGroups)
              element = f.get(json, jsonPath)

              sectionGroup = f.find(newSectionGroups, {key: key})
              sectionGroup.dynamic = element
              sectionGroup.loaded = true

              @setState(sectionGroups: newSectionGroups)

              @_updateAccordion(
                f.flatten(f.compact(f.map(newSectionGroups, (sectionGroup) -> sectionGroup.dynamic)))
              )
            else
              console.log('Could not load side filter data.')
        )
      )

  _updateAccordion: (dynamic) ->
    f.each(
      [
        @props.current.media_files,
        @props.current.meta_data,
        @props.current.permissions
      ],
      (array) =>
        f.each(array, (media_file_or_meta_datum_or_permission) =>
          f.each(dynamic, (section) =>
            f.each(section.children, (subSection) =>
              f.each(subSection.children, (filter) =>
                if filter.uuid == media_file_or_meta_datum_or_permission.value
                  prefix = section.filter_type || filter.uuid
                  @getAccordionSection(prefix + '-' + section.uuid).isOpen = true
                  @getAccordionSubSection(prefix + '-' + section.uuid, subSection.uuid).isOpen = true
              )
            )
          )
        )
    )
    @setState(accordion: @state.accordion)



  render: ({current, accordion} = @props)->
    # # TMP: ignore invalid dynamicFilters
    # if !(f.isArray(dynamic) and f.present(f.isArray(dynamic)))
    #   return null


    dynamic = f.flatten(f.compact(f.map(@state.sectionGroups, (sectionGroup) -> sectionGroup.dynamic)))

    if f.isEmpty(dynamic)
      if !f.isEmpty(f.filter(@state.sectionGroups, {loaded: false}))
        return (
          <ul className={baseClass} data-test-id='side-filter'>
            <Preloader mods='small' />
          </ul>
        )
      else
        return null


    # Clone the current filters, so as we can manipulate them
    # to give the result back to the parent component.
    current = f.clone(current)

    baseClass = ui.cx(ui.parseMods(@props), 'ui-side-filter-list')

    <ul className={baseClass} data-test-id='side-filter'>
      {
        f.flatten(f.compact(
          f.map(
            @state.sectionGroups,
            (sectionGroup) =>
              if !sectionGroup.loaded
                <Preloader key={'preloader_' + sectionGroup.key} mods='small' />
              else unless sectionGroup.dynamic
                null
              else
                filters = initializeFilterTreeFromProps(sectionGroup.dynamic, current)
                f.map filters, (filter) =>
                  @renderSection(current, filter)

          )
        ))
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
      {
        @createMultiSelectBox(child, current, filterType,
          !(parent.uuid == 'permissions'))
      }

      {
        if parent.uuid == 'permissions' && f.includes(['responsible_user', 'entrusted_to_user', 'entrusted_to_group', 'entrusted_to_api_client'], child.uuid)
          if isOpen
            @renderResponsibleUser(child, parent.uuid, current, child, filterType, togglebodyClass)
          else
            <ul className={togglebodyClass}></ul>

        else
          <ul className={togglebodyClass}>
            {
              if isOpen
                if child.hasRoles
                  f.map(f.groupBy(child.children, 'type'), (children, type) =>
                    @renderGroupedItems(parent.uuid, current, child, type, children, filterType)
                  )
                else
                  f.map(child.children, (item)=>
                    @renderItem(parent.uuid, current, child, item, filterType)
                  )
            }
          </ul>
      }
    </li>

  renderResponsibleUser: (node, parentUuid, current, parent, filterType, togglebodyClass) ->

    userChanged = (user, action) =>
      onChange = @props.onChange
      if user.selected
        @removeItemFilter(onChange, current, parent, user, filterType)
      else
        @addItemFilter(onChange, current, parent, user, filterType)

    placeholders = {
      responsible_user: t('dynamic_filters_search_for_user_placeholder'),
      entrusted_to_user: t('dynamic_filters_search_for_user_placeholder'),
      entrusted_to_group: t('dynamic_filters_search_for_group_placeholder'),
      entrusted_to_api_client: t('dynamic_filters_search_for_api_client_placeholder')
    }

    placeholder = placeholders[parent.uuid]

    <UserFilter node={node} userChanged={userChanged} placeholder={placeholder} togglebodyClass={togglebodyClass} />

  renderItem: (parentUuid, current, parent, item, filterType) ->

    onChange = @props.onChange
    addRemoveClick = () =>
      if item.selected then @removeItemFilter(onChange, current, parent, item, filterType) else @addItemFilter(onChange, current, parent, item, filterType)

    <FilterItem parentUuid={parentUuid} {...item} key={item.uuid} onClick={addRemoveClick}/>

  renderGroupedItems: (parentUuid, current, child, type, children, filterType) ->
    items = f.map(children, (item) =>
      @renderItem(parentUuid, current, child, item, filterType)
    )
    items.unshift(<li className='ui-side-filter-lvl3-item ptx plm' style={{'fontSize': '12px'}}><strong>{t("dynamic_filters_#{type}_header")}</strong></li>)
    items

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

  createMultiSelectBox: (child, current, filterType, allowSelectAll) ->

    showRemoveAll = f.any(child.children, 'selected')
    showSelectAll = child.multi and not showRemoveAll
    style = {display: 'inline-block', position: 'absolute', padding: 0}
    keyBtnClass = 'ui-any-value'

    multiSelectBox = undefined
    if showRemoveAll
      title = t('dynamic_filters_remove_all_title')
      onChange = @props.onChange
      removeClick = () =>
        @removeSubSectionFilter(onChange, current, child, filterType)
      icon = 'close'
      multiSelectBox = <Link style={style} className={keyBtnClass} title={title} onClick={removeClick}>
        <Icon i={icon}/>
      </Link>

    if showSelectAll && allowSelectAll
      title = t('dynamic_filters_any_values_title')
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

FilterItem = ({parentUuid, label, uuid, selected, type, href, count, onClick} = @props) ->
  label = f.presence(label or uuid) or (
    console.error('empty FilterItem label!') and '(empty)')
  <li className={css('ui-side-filter-lvl3-item', active: selected)}>
    <Link mods='weak' onClick={onClick}>
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
      hasRoles: filter.has_roles
    }
    subSections.push(subSection)
  return subSections

initializeItems = (filters) ->
  items = []
  for i, filter of filters
    item = {
      label: (if filter.detailed_name then filter.detailed_name else filter.label)
      uuid: filter.uuid
      count: filter.count
      selected: false
      type: filter.type
    }
    items.push(item)
  return items
