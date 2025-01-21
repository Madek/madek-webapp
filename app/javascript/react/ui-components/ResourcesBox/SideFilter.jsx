/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// decorates: DynamicFilters
// fallback: no # only used interactive (client-side)

import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import t from '../../../lib/i18n-translate.js'
import cx from 'classnames'
import ui from '../../lib/ui.js'
import MadekPropTypes from '../../lib/madek-prop-types.js'
import Icon from '../Icon.jsx'
import Link from '../Link.jsx'
import UserFilter from './UserFilter.jsx'
import PersonFilter from './PersonFilter.js'
import Preloader from '../Preloader.jsx'
import { parse as parseQuery } from 'qs'
import setUrlParams from '../../../lib/set-params-for-url.js'
import loadXhr from '../../../lib/load-xhr.js'

module.exports = createReactClass({
  displayName: 'SideFilter',
  propTypes: {
    dynamic: PropTypes.array,
    accordion: PropTypes.objectOf(PropTypes.object).isRequired,
    current: MadekPropTypes.resourceFilter.isRequired,
    onChange: PropTypes.func
  },

  // Note: We list in the menu the sections based on the meta data contexts.
  // But furthermore, we also for example list the media types as a section
  // with an artifical uuid "file". We must make sure, that we have not clash
  // for example, when a context has the id "file". Thats why section uuids must
  // be concatenated with the filter_type.
  // E.g. meta_data:copyright or media_files:file

  getAccordionSection(sectionUuid) {
    const { accordion } = this.state
    if (!accordion.sections) {
      accordion.sections = {}
    }

    let section = accordion.sections[sectionUuid]
    if (!section) {
      section = {
        isOpen: false,
        subSections: {}
      }
      accordion.sections[sectionUuid] = section
    }
    return section
  },

  getAccordionSubSection(sectionUuid, subSectionUuid) {
    const section = this.getAccordionSection(sectionUuid)
    if (!section.subSections) {
      section.subSections = {}
    }
    let subSection = section.subSections[subSectionUuid]
    if (!subSection) {
      subSection = { isOpen: false }
      section.subSections[subSectionUuid] = subSection
    }
    return subSection
  },

  toggleSection(sectionUuid) {
    const section = this.getAccordionSection(sectionUuid)
    section.isOpen = !section.isOpen
    return this.setState({ accordion: this.state.accordion })
  },

  toggleSubSection(sectionUuid, subSectionUuid) {
    const subSection = this.getAccordionSubSection(sectionUuid, subSectionUuid)
    subSection.isOpen = !subSection.isOpen
    return this.setState({ accordion: this.state.accordion })
  },

  getInitialState() {
    return {
      javascript: false,
      accordion: this.props.accordion || {},
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
    }
  },

  componentDidMount() {
    this._isMounted = true
    this.setState({ javascript: true })

    return this._loadData()
  },

  componentWillUnmount() {
    return (this._isMounted = false)
  },

  _loadData() {
    const currentUrl = this.props.forUrl

    const currentParams = parseQuery(currentUrl.query)
    const newParams = f.cloneDeep(currentParams)

    if (!newParams.list) {
      newParams.list = {}
    }

    newParams.list.sparse_filter = true
    newParams.list.show_filter = true

    return f.each(this.state.sectionGroups, group => {
      const { key } = group

      const jsonPath = getJsonPath(this.props.jsonPath, key)

      return loadXhr(
        {
          method: 'GET',
          url: setUrlParams(currentUrl, newParams, {
            ___sparse: JSON.stringify(f.set({}, jsonPath, {}))
          })
        },
        (result, json) => {
          if (!this._isMounted) {
            return
          }
          if (result === 'success') {
            const newSectionGroups = f.clone(this.state.sectionGroups)
            const element = f.get(json, jsonPath)

            const sectionGroup = f.find(newSectionGroups, { key })
            sectionGroup.dynamic = element
            sectionGroup.loaded = true

            this.setState({ sectionGroups: newSectionGroups })

            return this._updateAccordion(
              f.flatten(f.compact(f.map(newSectionGroups, sectionGroup => sectionGroup.dynamic)))
            )
          } else {
            return console.error('Could not load side filter data.')
          }
        }
      )
    })
  },

  _updateAccordion(dynamic) {
    f.each(
      [
        this.props.current.media_files,
        this.props.current.meta_data,
        this.props.current.permissions
      ],
      array => {
        return f.each(array, media_file_or_meta_datum_or_permission => {
          return f.each(dynamic, section => {
            return f.each(section.children, subSection => {
              return f.each(subSection.children, filter => {
                if (filter.uuid === media_file_or_meta_datum_or_permission.value) {
                  const prefix = section.filter_type || filter.uuid
                  this.getAccordionSection(prefix + '-' + section.uuid).isOpen = true
                  return (this.getAccordionSubSection(
                    prefix + '-' + section.uuid,
                    subSection.uuid
                  ).isOpen = true)
                }
              })
            })
          })
        })
      }
    )
    return this.setState({ accordion: this.state.accordion })
  },

  render(param) {
    // # TMP: ignore invalid dynamicFilters
    // if !(f.isArray(dynamic) and f.present(f.isArray(dynamic)))
    //   return null

    if (param == null) {
      param = this.props
    }
    let { current } = param
    const dynamic = f.flatten(
      f.compact(f.map(this.state.sectionGroups, sectionGroup => sectionGroup.dynamic))
    )

    if (f.isEmpty(dynamic)) {
      if (!f.isEmpty(f.filter(this.state.sectionGroups, { loaded: false }))) {
        return (
          <ul className={baseClass} data-test-id="side-filter">
            <Preloader mods="small" />
          </ul>
        )
      } else {
        return null
      }
    }

    // Clone the current filters, so as we can manipulate them
    // to give the result back to the parent component.
    current = f.clone(current)

    var baseClass = ui.cx(ui.parseMods(this.props), 'ui-side-filter-list')

    return (
      <ul className={baseClass} data-test-id="side-filter">
        {f.flatten(
          f.compact(
            f.map(this.state.sectionGroups, sectionGroup => {
              if (!sectionGroup.loaded) {
                return <Preloader key={`preloader_${sectionGroup.key}`} mods="small" />
              } else if (!sectionGroup.dynamic) {
                return null
              } else {
                const filters = initializeFilterTreeFromProps(sectionGroup.dynamic, current)
                return f.map(filters, filter => {
                  return this.renderSection(current, filter)
                })
              }
            })
          )
        )}
      </ul>
    )
  },

  renderSection(current, filter) {
    const itemClass = 'ui-side-filter-lvl1-item ui-side-filter-item'

    const { filterType } = filter
    const { uuid } = filter
    const { isOpen } = this.getAccordionSection(filterType + '-' + uuid)
    const href = null

    const toggleOnClick = () => this.toggleSection(filterType + '-' + filter.uuid)

    return (
      <li className={itemClass} key={filterType + '-' + filter.uuid}>
        <a
          className={cx('ui-accordion-toggle', 'strong', { open: isOpen })}
          href={href}
          onClick={toggleOnClick}>
          {filter.label} <i className="ui-side-filter-lvl1-marker" />
        </a>
        <ul className={cx('ui-accordion-body', 'ui-side-filter-lvl2', { open: isOpen })}>
          {isOpen
            ? f.map(filter.children, child => {
                return this.renderSubSection(current, filterType, filter, child)
              })
            : undefined}
        </ul>
      </li>
    )
  },

  renderSubSection(current, filterType, parent, child) {
    const { isOpen } = this.getAccordionSubSection(filterType + '-' + parent.uuid, child.uuid)
    const showSearchField = f.includes(
      [
        'responsible_user',
        'responsible_delegation',
        'entrusted_to_user',
        'entrusted_to_group',
        'entrusted_to_api_client'
      ],
      child.uuid
    )

    const keyClass = 'ui-side-filter-lvl2-item'
    const togglebodyClass = cx('ui-accordion-body', 'ui-side-filter-lvl3', { open: isOpen })
    return (
      <li className={keyClass} key={child.uuid}>
        {this.createToggleSubSection(filterType, parent, child, isOpen)}
        {this.createMultiSelectBox(child, current, filterType, !(parent.uuid === 'permissions'))}
        {(() => {
          if (parent.uuid === 'permissions' && showSearchField) {
            if (isOpen) {
              return this.renderResponsibleUser(
                child,
                parent.uuid,
                current,
                child,
                filterType,
                togglebodyClass
              )
            } else {
              return <ul className={togglebodyClass} />
            }
          } else {
            if (isOpen) {
              switch (child.metaDatumObjectType) {
                case 'MetaDatum::People':
                  return this.renderPersonSelect(
                    current,
                    child,
                    child.children,
                    filterType,
                    togglebodyClass,
                    false
                  )
                case 'MetaDatum::Roles':
                  return f.map(['person', 'role'], type => {
                    const items = child.children.filter(x => x.type === type)
                    if (items.length === 0) {
                      return false
                    }
                    if (type === 'person') {
                      return this.renderPersonSelect(
                        current,
                        child,
                        items,
                        filterType,
                        togglebodyClass,
                        true
                      )
                    } else {
                      return (
                        <ul className={togglebodyClass} key="role">
                          <li
                            className="ui-side-filter-lvl3-item ptx plm"
                            style={{ fontSize: '12px' }}>
                            <strong>{t('dynamic_filters_role_header')}</strong>
                          </li>
                          {f.map(items, item => {
                            return this.renderItem(parent.uuid, current, child, item, filterType)
                          })}
                        </ul>
                      )
                    }
                  })
                default:
                  return (
                    <ul className={togglebodyClass}>
                      {f.map(child.children, item => {
                        return this.renderItem(parent.uuid, current, child, item, filterType)
                      })}
                    </ul>
                  )
              }
            }
          }
        })()}
      </li>
    )
  },

  renderPersonSelect(current, child, items, filterType, className, withTitle) {
    const onSelect = person =>
      this.addItemFilter(this.props.onChange, current, child, person, filterType)
    const onClear = person =>
      this.removeItemFilter(this.props.onChange, current, child, person, filterType)
    const jsonPath = getJsonPath(this.props.jsonPath, 'section_group_meta_data')
    return (
      <PersonFilter
        key="person"
        label={child.label}
        contextKeyId={child.contextKeyId}
        tooManyHits={child.tooManyHits}
        staticItems={items}
        onSelect={onSelect}
        onClear={onClear}
        className={className}
        withTitle={withTitle}
        jsonPath={jsonPath}
      />
    )
  },

  renderResponsibleUser(node, parentUuid, current, parent, filterType, togglebodyClass) {
    const userChanged = user => {
      const { onChange } = this.props
      if (user.selected) {
        return this.removeItemFilter(onChange, current, parent, user, filterType)
      } else {
        return this.addItemFilter(onChange, current, parent, user, filterType)
      }
    }

    const placeholders = {
      responsible_user: t('dynamic_filters_search_for_user_placeholder'),
      responsible_delegation: t('dynamic_filters_search_for_delegation_placeholder'),
      entrusted_to_user: t('dynamic_filters_search_for_user_placeholder'),
      entrusted_to_group: t('dynamic_filters_search_for_group_placeholder'),
      entrusted_to_api_client: t('dynamic_filters_search_for_api_client_placeholder')
    }

    const placeholder = placeholders[parent.uuid]

    return (
      <UserFilter
        node={node}
        userChanged={userChanged}
        placeholder={placeholder}
        togglebodyClass={togglebodyClass}
      />
    )
  },

  renderItem(parentUuid, current, parent, item, filterType) {
    const { onChange } = this.props
    const addRemoveClick = () => {
      if (item.selected) {
        return this.removeItemFilter(onChange, current, parent, item, filterType)
      } else {
        return this.addItemFilter(onChange, current, parent, item, filterType)
      }
    }

    return (
      <FilterItem
        {...Object.assign({ parentUuid: parentUuid }, item, {
          key: item.uuid,
          onClick: addRemoveClick
        })}
      />
    )
  },

  createToggleSubSection(filterType, parent, child, isOpen) {
    const href = null

    const toggleOnClick = () => {
      return this.toggleSubSection(filterType + '-' + parent.uuid, child.uuid)
    }

    const togglerClass = cx('ui-accordion-toggle', 'weak', { open: isOpen })
    const toggleMarkerClass = cx('ui-side-filter-lvl2-marker')

    return (
      <a className={togglerClass} href={href} onClick={toggleOnClick}>
        <span className={toggleMarkerClass} />
        {child.label}
      </a>
    )
  },

  createMultiSelectBox(child, current, filterType, allowSelectAll) {
    let icon, onChange, title
    const showRemoveAll = f.any(child.children, 'selected')
    const showSelectAll = child.multi && !showRemoveAll
    const style = { display: 'inline-block', position: 'absolute', padding: 0 }
    const keyBtnClass = 'ui-any-value'

    let multiSelectBox = undefined
    if (showRemoveAll) {
      title = t('dynamic_filters_remove_all_title')
      ;({ onChange } = this.props)
      const removeClick = () => {
        return this.removeSubSectionFilter(onChange, current, child, filterType)
      }
      icon = 'close'
      multiSelectBox = (
        <Link style={style} className={keyBtnClass} title={title} onClick={removeClick}>
          <Icon i={icon} />
        </Link>
      )
    }

    if (showSelectAll && allowSelectAll) {
      let iclass
      title = t('dynamic_filters_any_values_title')
      icon = 'checkbox'
      if (child.selected) {
        iclass = 'active'
      }
      ;({ onChange } = this.props)
      const addClick = () => {
        if (child.selected) {
          return this.removeSubSectionFilter(onChange, current, child, filterType)
        } else {
          return this.addSubSectionFilter(onChange, current, child, filterType)
        }
      }
      multiSelectBox = (
        <Link style={style} className={keyBtnClass} title={title} onClick={addClick}>
          <Icon i={icon} className={iclass} />
        </Link>
      )
    }

    return multiSelectBox
  },

  addItemFilter(onChange, current, parent, item, filterType) {
    let currentPerType = current[filterType] || []
    // When we add a child filter, the parent filter is no longer needed.
    currentPerType = f
      .reject(
        currentPerType,

        // Remove the filter, if it is in the section and consists only of
        // key, but has no value or match.
        // If multi is false, then we remove all from this section.
        function(filter) {
          const preventDuplicate = filter.key === parent.uuid && filter.value === item.uuid
          const removeSectionFilter =
            filter.key === parent.uuid &&
            (!f.present(f.pick(filter, 'value', 'match')) || !parent.multi)
          return preventDuplicate || removeSectionFilter

          // Add the Item filter.
        }
      )
      .concat({ key: parent.uuid, value: item.uuid })

    current[filterType] = currentPerType
    if (onChange) {
      return onChange({
        action: 'added item',
        item,
        current,
        accordion: this.state.accordion
      })
    }
  },

  addSubSectionFilter(onChange, current, parent, filterType) {
    let currentPerType = current[filterType] || []
    // Remove all Item filters in this section.
    currentPerType = f
      .reject(
        currentPerType,

        // Note: We here also remove an existing section filter actually.
        filter => filter.key === parent.uuid
      )
      .concat({ key: parent.uuid })

    current[filterType] = currentPerType
    if (onChange) {
      return onChange({
        action: 'added key',
        current,
        accordion: this.state.accordion
      })
    }
  },

  removeItemFilter(onChange, current, parent, item, filterType) {
    let currentPerType = current[filterType] || []
    // Remove the item filter.
    currentPerType = f.reject(currentPerType, filter => filter.value === item.uuid)
    current[filterType] = currentPerType
    if (onChange) {
      return onChange({
        action: 'removed item',
        item,
        current,
        accordion: this.state.accordion
      })
    }
  },

  removeSubSectionFilter(onChange, current, parent, filterType) {
    let currentPerType = current[filterType] || []
    // Remove the section filter.
    currentPerType = f.reject(currentPerType, filter => filter.key === parent.uuid)
    current[filterType] = currentPerType
    if (onChange) {
      return onChange({
        action: 'removed key',
        current,
        accordion: this.state.accordion
      })
    }
  }
})

var FilterItem = function(param) {
  if (param == null) {
    param = this.props
  }
  let { label, uuid, selected, count, onClick } = param
  label = f.presence(label || uuid) || (console.error('empty FilterItem label!') && '(empty)')
  return (
    <li className={cx('ui-side-filter-lvl3-item', { active: selected })}>
      <Link mods="weak" onClick={onClick}>
        {label} <span className="ui-lvl3-item-count">{count}</span>
      </Link>
    </li>
  )
}

var initializeFilterTreeFromProps = function(dynamicFilters, current) {
  let tree = initializeSections(dynamicFilters)
  return (tree = forCurrentFiltersSelectItemsInTree(tree, current))
}

var forCurrentFiltersSelectItemsInTree = function(tree, current) {
  const selectItemForFilter = function(item, filter) {
    if (item.uuid === filter.value) {
      return (item.selected = true)
    }
  }

  const selectInSubSection = (subSection, filter) =>
    (() => {
      const result = []
      for (var i in subSection.children) {
        var item = subSection.children[i]
        if (subSection.uuid === filter.key) {
          subSection.selected = true
        }
        result.push(selectItemForFilter(item, filter))
      }
      return result
    })()

  const selectInSection = (section, filter) =>
    (() => {
      const result = []
      for (var i in section.children) {
        var subSection = section.children[i]
        if (subSection.uuid === filter.key) {
          result.push(selectInSubSection(subSection, filter))
        } else {
          result.push(undefined)
        }
      }
      return result
    })()

  const selectInTreePerFilter = (filterType, filter) =>
    (() => {
      const result = []
      for (var i in tree) {
        var section = tree[i]
        if (section.filterType === filterType) {
          result.push(selectInSection(section, filter))
        } else {
          result.push(undefined)
        }
      }
      return result
    })()

  for (var filterType in current) {
    var filtersPerType = current[filterType]
    for (var i in filtersPerType) {
      var filter = filtersPerType[i]
      selectInTreePerFilter(filterType, filter)
    }
  }

  return tree
}

var initializeSections = dynamicFilters =>
  f.map(dynamicFilters, function(filter) {
    const { filter_type, label, uuid, children } = filter
    return {
      filterType: filter_type || uuid,
      children: initializeSubSections(children),
      label,
      uuid
    }
  })

var initializeSubSections = filters =>
  f.map(filters, function(filter) {
    const {
      children,
      label,
      uuid,
      multi,
      context_key_id,
      meta_datum_object_type,
      too_many_hits
    } = filter
    return {
      children: initializeItems(children),
      label,
      uuid,
      // The default value of multi is true. This means, we only
      // check if the presenter has set the value to false explicitely.
      // If the presenter does not set the value at all, it is undefined,
      // and therefore it is set to true here.
      multi: multi !== false ? true : undefined,
      contextKeyId: context_key_id,
      metaDatumObjectType: meta_datum_object_type,
      tooManyHits: too_many_hits
    }
  })

var initializeItems = filters =>
  f.map(filters, function(filter) {
    const { uuid, count, type, label, detailed_name } = filter
    return {
      label: detailed_name ? detailed_name : label,
      uuid,
      count,
      selected: false,
      type
    }
  })

var getJsonPath = function(baseJsonPath, key) {
  let jsonPath = baseJsonPath
  jsonPath = jsonPath.substring(0, jsonPath.length - 'resources'.length)
  jsonPath += `dynamic_filters.${key}`
  return jsonPath
}
