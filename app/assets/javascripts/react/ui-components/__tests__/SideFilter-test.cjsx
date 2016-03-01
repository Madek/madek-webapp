jest.dontMock '../SideFilter.cjsx'

# We must not mock the Link, otherwise the DOM is just rendered until
# Link. Since we have children embedded in Link, we also want
# to test these children.
jest.dontMock '../Link.cjsx'
jest.dontMock '../Icon.cjsx'

React = require('react')
ReactDOM = require('react-dom')
ReactDOMServer = require('react-dom/server')
TestUtils = require('react-addons-test-utils')
SideFilter = require('../SideFilter.cjsx')
Icon = require('../Icon.cjsx')


# Run it on shell:
# webapp> npm test
describe 'SideFilter', ->

  # Perhaps needed once:
  # afterEach(function(done) {
  #   React.unmountComponentAtNode(document.body)
  #   document.body.innerHTML = ""
  #   setTimeout(done)
  # })

  it 'check empty filters', ->

    dynamicFilters = []
    currentFilters = {}
    accordion = {}
    onChange = ->

    sideFilter = TestUtils.renderIntoDocument(
      <SideFilter dynamic={dynamicFilters} current={currentFilters}
        accordion={accordion} onChange={onChange} />
    )

    root = ReactDOM.findDOMNode(sideFilter)
    expect(root.tagName).toBe('UL')
    expect(root.hasChildNodes()).toBe(false)

  it 'check select all', ->

    { sideFilter, toCheck, dynamicFilters, reactElement } = initializeSideFilter(
      createDynamicFiltersExample(true),
      {}
    )

    root = getRoot(sideFilter)
    section = getSection(root, 0)
    clickSection(section)
    subSection = getSubSection(section, 0)
    clickSubSection(subSection)
    checkSubSection(subSection, false, true)

    filterType = 'filtertype_section_1'
    clickSelectOrDeleteAll(subSection)
    expect(toCheck.current[filterType].length).toBe(1)
    filter = toCheck.current[filterType][0]
    expect(filter.key).toBe('uuid_subsection_1_1')
    expect(filter.value).toBe(undefined)

  it 'check delete all', ->

    { sideFilter, toCheck, dynamicFilters, reactElement } = initializeSideFilter(
      createDynamicFiltersExample(true),
      { 'filtertype_section_1': [
        {"key":"uuid_subsection_1_1","value":"item_a_uuid"},
        {"key":"uuid_subsection_1_1","value":"item_b_uuid"}
      ]}
    )

    root = getRoot(sideFilter)
    section = getSection(root, 0)
    clickSection(section)
    subSection = getSubSection(section, 0)
    clickSubSection(subSection)
    checkSubSection(subSection, true, false)

    filterType = 'filtertype_section_1'
    expect(toCheck.current[filterType].length).toBe(2)
    clickSelectOrDeleteAll(subSection)
    expect(toCheck.current[filterType].length).toBe(0)

  it 'check prevent adding same filter twice', ->

    { sideFilter, toCheck, dynamicFilters } = initializeSideFilter(createDynamicFiltersExample(true), {})

    root = getRoot(sideFilter)
    section = getSection(root, 0)
    clickSection(section)
    checkSubSection(section, false, false)
    checkSubSectionsCount(section, 1)
    subSection = getSubSection(section, 0)
    clickSubSection(subSection)
    checkItemsCount(subSection, 2)

    item0 = getItem(subSection, 0)
    item1 = getItem(subSection, 1)

    # Check that filter is not added twice.
    filterType = dynamicFilters[0].filter_type
    expect(toCheck.current[filterType]).toBe(undefined)
    clickItem(item0)

    expect(toCheck.current[filterType].length).toBe(1)
    clickItem(item0)
    expect(toCheck.current[filterType].length).toBe(1)
    clickItem(item1)
    expect(toCheck.current[filterType].length).toBe(2)

  it 'check basic side filter interactions', ->

    { sideFilter, toCheck, dynamicFilters } = initializeSideFilter(createDynamicFiltersExample(false), {})

    # Check that the dynamic filters have been filled into the
    # tree structure correctly.
    root = getRoot(sideFilter)
    checkSectionsCount(root, 2)

    section0 = getSection(root, 0)
    checkSection(section0)
    section1 = getSection(root, 1)
    checkSection(section1)

    checkSubSectionsCount(section0, 0)
    clickSection(section0)
    checkSubSectionsCount(section0, 1)

    section0_subSection0 = getSubSection(section0, 0)
    checkSubSection(section0_subSection0, false, false)
    checkItemsCount(section0_subSection0, 0)
    clickSubSection(section0_subSection0)
    checkItemsCount(section0_subSection0, 2)

    section0_subSection0_item0 = getItem(section0_subSection0, 0)
    checkItem(section0_subSection0_item0,
      'item_a_label',
      'item_a_count')

    # Check that the accorion is closed when clicking on section.
    clickSection(section0)
    checkSubSectionsCount(section0, 0)

    # Check that the accordion is opened again with the whole sub tree
    # opened as it was before.
    clickSection(section0)
    checkSubSectionsCount(section0, 1)
    section0_subSection0 = getSubSection(section0, 0)
    checkSubSection(section0_subSection0, false, false)
    checkItemsCount(section0_subSection0, 2) # detached, but still correct count
    section0_subSection0_item0 = getItem(section0_subSection0, 0)
    checkItem(section0_subSection0_item0,
      'item_a_label',
      'item_a_count')

    # Check that there are not current filters.
    section0_filterType = dynamicFilters[0].filter_type
    expect(toCheck.current[section0_filterType]).toBe(undefined)

    # Click on an item in the first section.
    clickItem(section0_subSection0_item0)
    checkSubSection(section0_subSection0, false, false)

    # Check that there is a current filter now.
    expect(toCheck.current[section0_filterType].length).toBe(1)
    section0_filter0 = toCheck.current[section0_filterType][0]

    # Check that the current filter matches the clicked item.
    expect(section0_filter0.key).toBe(dynamicFilters[0].children[0].uuid)
    expect(section0_filter0.value).toBe(dynamicFilters[0].children[0].children[0].uuid)

    # Check that there are no current filters for the filter type of
    # the second section.
    clickSection(section1)
    section1_subSection0 = getSubSection(section1, 0)
    clickSubSection(section1_subSection0)
    section1_subSection0_item0 = getItem(section1_subSection0, 0)
    section1_filterType = dynamicFilters[1].filter_type
    expect(toCheck.current[section1_filterType]).toBe(undefined)

    # Click on an item in the second section.
    clickItem(section1_subSection0_item0)

    # Check that there is now a current filter too with the according
    # entry.
    expect(toCheck.current[section1_filterType].length).toBe(1)
    section1_filter0 = toCheck.current[section1_filterType][0]
    expect(section1_filter0.key).toBe(dynamicFilters[1].children[0].uuid)
    expect(section1_filter0.value).toBe(dynamicFilters[1].children[0].children[0].uuid)

  initializeSideFilter = (dynamicFilters, currentFilters) ->

    accordion = {}
    toCheck = {
      current: currentFilters
    }
    onChange = (event)->
      toCheck.current = event.current


    reactElement = <SideFilter dynamic={dynamicFilters} current={currentFilters}
      accordion={accordion} onChange={onChange} />

    sideFilter = TestUtils.renderIntoDocument(reactElement)

    return {
      sideFilter: sideFilter,
      toCheck: toCheck,
      dynamicFilters: dynamicFilters,
      reactElement: reactElement
    }

  getRoot = (sideFilter) ->
    root = ReactDOM.findDOMNode(sideFilter)
    expect(root.tagName).toBe('UL')
    return root

  checkSectionsCount = (root, count) ->
    expect(root.children.length).toBe(count)

  getSection = (root, index) ->
    section = root.children[index]
    return section

  checkSection = (section) ->
    expect(section.tagName).toBe('LI')
    expect(section.children.length).toBe(2)
    a = section.children[0]
    ul = section.children[1]
    expect(a.tagName).toBe('A')
    expect(ul.tagName).toBe('UL')

  clickSection = (section) ->
    TestUtils.Simulate.click(section.children[0])

  getSubSection = (section, index) ->
    subSection = section.children[1].children[index]
    return subSection

  checkSubSection = (subSection, deleteAll, selectAll) ->
    expect(subSection.tagName).toBe('LI')
    childCount = if deleteAll or selectAll then 3 else 2
    expect(subSection.children.length).toBe(childCount)
    a = subSection.children[0]
    ulIndex = if deleteAll or selectAll then 2  else 1
    ul = subSection.children[ulIndex]
    expect(a.tagName).toBe('A')
    expect(ul.tagName).toBe('UL')
    if deleteAll or selectAll
      span = subSection.children[1]
      expect(span.tagName).toBe('SPAN')
      expect(span.children.length).toBe(1)
      icon = span.children[0]
      if deleteAll
        expect(icon.className).toContain('icon-close')
      if selectAll
        expect(icon.className).toContain('icon-checkbox')

  clickSelectOrDeleteAll = (subSection) ->
    TestUtils.Simulate.click(subSection.children[1])

  clickSubSection = (subSection) ->
    TestUtils.Simulate.click(subSection.children[0])

  checkSubSectionsCount = (section, count) ->
    expect(section.children[1].children.length).toBe(count)

  checkItemsCount = (subSection, count) ->
    ulIndex = 1
    ulIndex = 2 if subSection.children.length is 3
    expect(subSection.children[ulIndex].children.length).toBe(count)

  getItem = (subSection, index) ->
    ulIndex = 1
    ulIndex = 2 if subSection.children.length is 3
    item = subSection.children[ulIndex].children[index]
    expect(item.tagName).toBe('LI')
    expect(item.children.length).toBe(1)
    span = item.children[0]
    expect(span.tagName).toBe('SPAN')
    expect(span.children.length).toBe(3)
    span0 = span.children[0]
    span2 = span.children[2]
    expect(span0.tagName).toBe('SPAN')
    expect(span2.tagName).toBe('SPAN')
    return item

  checkItem = (item, label, count) ->
    expect(item.children[0].children[0].textContent).toBe(label)
    expect(item.children[0].children[2].textContent).toBe(count)

  clickItem = (item) ->
    TestUtils.Simulate.click(item.children[0])

  createDynamicFiltersExample = (multi) ->

    [
      {
        uuid: 'uuid_section_1'
        filter_type: 'filtertype_section_1'
        label: 'label_section_1'
        children: [
          {
            uuid: 'uuid_subsection_1_1'
            label: 'label_subsection_1_1'
            multi: multi
            children: [
              {
                uuid: 'item_a_uuid'
                count: 'item_a_count'
                label: 'item_a_label'
              },
              {
                uuid: 'item_b_uuid'
                count: 'item_b_count'
                label: 'item_b_label'
              }
            ]
          }
        ]
      },
      {
        uuid: 'uuid_section_2'
        filter_type: 'filtertype_section_2'
        label: 'label_section_2'
        children: [
          {
            uuid: 'uuid_subsection_2_1'
            label: 'label_subsection_2_1'
            multi: multi
            children: [
              {
                uuid: 'uuid_item_2_1_1'
                count: 'count_item_2_1_1'
                label: 'label_item_2_1_1'
              }
            ]
          }
        ]
      }
    ]
