// decorates: DynamicFilters
// fallback: no # only used interactive (client-side)

import React, { useState, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
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
import { isEmpty, get, cloneDeep, presence, present } from '../../../lib/utils.js'

// Note: We list in the menu the sections based on the meta data contexts.
// But furthermore, we also for example list the media types as a section
// with an artifical uuid "file". We must make sure, that we have not clash
// for example, when a context has the id "file". Thats why section uuids must
// be concatenated with the filter_type.
// E.g. meta_data:copyright or media_files:file

const SideFilter = ({ accordion: accordionProp, current, onChange, forUrl, jsonPath }) => {
  const isMountedRef = useRef(true)
  const [accordion, setAccordion] = useState(accordionProp || {})
  const [sectionGroups, setSectionGroups] = useState([
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
  ])

  const getAccordionSection = sectionUuid => {
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
  }

  const getAccordionSubSection = (sectionUuid, subSectionUuid) => {
    const section = getAccordionSection(sectionUuid)
    if (!section.subSections) {
      section.subSections = {}
    }
    let subSection = section.subSections[subSectionUuid]
    if (!subSection) {
      subSection = { isOpen: false }
      section.subSections[subSectionUuid] = subSection
    }
    return subSection
  }

  const toggleSection = sectionUuid => {
    const section = getAccordionSection(sectionUuid)
    section.isOpen = !section.isOpen
    setAccordion({ ...accordion })
  }

  const toggleSubSection = (sectionUuid, subSectionUuid) => {
    const subSection = getAccordionSubSection(sectionUuid, subSectionUuid)
    subSection.isOpen = !subSection.isOpen
    setAccordion({ ...accordion })
  }

  const updateAccordion = dynamic => {
    ;[current.media_files, current.meta_data, current.permissions].forEach(array => {
      if (!array) return
      array.forEach(media_file_or_meta_datum_or_permission => {
        dynamic.forEach(section => {
          if (!section.children) return
          section.children.forEach(subSection => {
            if (!subSection.children) return
            subSection.children.forEach(filter => {
              if (filter.uuid === media_file_or_meta_datum_or_permission.value) {
                const prefix = section.filter_type || filter.uuid
                getAccordionSection(prefix + '-' + section.uuid).isOpen = true
                getAccordionSubSection(prefix + '-' + section.uuid, subSection.uuid).isOpen = true
              }
            })
          })
        })
      })
    })
    setAccordion({ ...accordion })
  }

  const loadData = () => {
    const currentUrl = forUrl
    const currentParams = parseQuery(currentUrl.query)
    const newParams = cloneDeep(currentParams)

    if (!newParams.list) {
      newParams.list = {}
    }

    newParams.list.sparse_filter = true
    newParams.list.show_filter = true

    sectionGroups.forEach(group => {
      const { key } = group
      const jsonPath = getJsonPath(jsonPath, key)

      loadXhr(
        {
          method: 'GET',
          url: setUrlParams(currentUrl, newParams, {
            ___sparse: JSON.stringify(setNestedValue({}, jsonPath, {}))
          })
        },
        (result, json) => {
          if (!isMountedRef.current) {
            return
          }
          if (result === 'success') {
            const newSectionGroups = [...sectionGroups]
            const element = get(json, jsonPath)

            const sectionGroup = newSectionGroups.find(sg => sg.key === key)
            sectionGroup.dynamic = element
            sectionGroup.loaded = true

            setSectionGroups(newSectionGroups)

            updateAccordion(
              newSectionGroups
                .map(sg => sg.dynamic)
                .filter(Boolean)
                .flat()
            )
          } else {
            // eslint-disable-next-line no-console
            console.error('Could not load side filter data.')
          }
        }
      )
    })
  }

  useEffect(() => {
    isMountedRef.current = true
    loadData()

    return () => {
      isMountedRef.current = false
    }
  }, [])

  const addItemFilter = (onChange, current, parent, item, filterType) => {
    let currentPerType = current[filterType] || []
    // When we add a child filter, the parent filter is no longer needed.
    currentPerType = currentPerType
      .filter(filter => {
        const preventDuplicate = filter.key === parent.uuid && filter.value === item.uuid
        const removeSectionFilter =
          filter.key === parent.uuid &&
          (!present(pick(filter, ['value', 'match'])) || !parent.multi)
        return !(preventDuplicate || removeSectionFilter)
      })
      .concat({ key: parent.uuid, value: item.uuid })

    current[filterType] = currentPerType
    if (onChange) {
      return onChange({
        action: 'added item',
        item,
        current,
        accordion
      })
    }
  }

  const addSubSectionFilter = (onChange, current, parent, filterType) => {
    let currentPerType = current[filterType] || []
    // Remove all Item filters in this section.
    currentPerType = currentPerType
      .filter(filter => filter.key !== parent.uuid)
      .concat({ key: parent.uuid })

    current[filterType] = currentPerType
    if (onChange) {
      return onChange({
        action: 'added key',
        current,
        accordion
      })
    }
  }

  const removeItemFilter = (onChange, current, parent, item, filterType) => {
    let currentPerType = current[filterType] || []
    // Remove the item filter.
    currentPerType = currentPerType.filter(filter => filter.value !== item.uuid)
    current[filterType] = currentPerType
    if (onChange) {
      return onChange({
        action: 'removed item',
        item,
        current,
        accordion
      })
    }
  }

  const removeSubSectionFilter = (onChange, current, parent, filterType) => {
    let currentPerType = current[filterType] || []
    // Remove the section filter.
    currentPerType = currentPerType.filter(filter => filter.key !== parent.uuid)
    current[filterType] = currentPerType
    if (onChange) {
      return onChange({
        action: 'removed key',
        current,
        accordion
      })
    }
  }

  const renderSection = (current, filter) => {
    const itemClass = 'ui-side-filter-lvl1-item ui-side-filter-item'

    const { filterType } = filter
    const { uuid } = filter
    const { isOpen } = getAccordionSection(filterType + '-' + uuid)
    const href = null

    const toggleOnClick = () => toggleSection(filterType + '-' + filter.uuid)

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
            ? filter.children.map(child => renderSubSection(current, filterType, filter, child))
            : undefined}
        </ul>
      </li>
    )
  }

  const renderPersonSelect = (current, child, items, filterType, className, withTitle) => {
    const onSelect = person => addItemFilter(onChange, current, child, person, filterType)
    const onClear = person => removeItemFilter(onChange, current, child, person, filterType)
    const jsonPathValue = getJsonPath(jsonPath, 'section_group_meta_data')
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
        jsonPath={jsonPathValue}
      />
    )
  }

  const renderResponsibleUser = (
    node,
    parentUuid,
    current,
    parent,
    filterType,
    togglebodyClass
  ) => {
    const userChanged = user => {
      if (user.selected) {
        return removeItemFilter(onChange, current, parent, user, filterType)
      } else {
        return addItemFilter(onChange, current, parent, user, filterType)
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
  }

  const renderItem = (parentUuid, current, parent, item, filterType) => {
    const addRemoveClick = () => {
      if (item.selected) {
        return removeItemFilter(onChange, current, parent, item, filterType)
      } else {
        return addItemFilter(onChange, current, parent, item, filterType)
      }
    }

    return <FilterItem {...{ ...item, parentUuid, key: item.uuid, onClick: addRemoveClick }} />
  }

  const createToggleSubSection = (filterType, parent, child, isOpen) => {
    const href = null

    const toggleOnClick = () => {
      return toggleSubSection(filterType + '-' + parent.uuid, child.uuid)
    }

    const togglerClass = cx('ui-accordion-toggle', 'weak', { open: isOpen })
    const toggleMarkerClass = cx('ui-side-filter-lvl2-marker')

    return (
      <a className={togglerClass} href={href} onClick={toggleOnClick}>
        <span className={toggleMarkerClass} />
        {child.label}
      </a>
    )
  }

  const createMultiSelectBox = (child, current, filterType, allowSelectAll) => {
    let icon, title
    const showRemoveAll = child.children && child.children.some(c => c.selected)
    const showSelectAll = child.multi && !showRemoveAll
    const style = { display: 'inline-block', position: 'absolute', padding: 0 }
    const keyBtnClass = 'ui-any-value'

    let multiSelectBox = undefined
    if (showRemoveAll) {
      title = t('dynamic_filters_remove_all_title')
      const removeClick = () => {
        return removeSubSectionFilter(onChange, current, child, filterType)
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
      const addClick = () => {
        if (child.selected) {
          return removeSubSectionFilter(onChange, current, child, filterType)
        } else {
          return addSubSectionFilter(onChange, current, child, filterType)
        }
      }
      multiSelectBox = (
        <Link style={style} className={keyBtnClass} title={title} onClick={addClick}>
          <Icon i={icon} className={iclass} />
        </Link>
      )
    }

    return multiSelectBox
  }

  const renderSubSection = (current, filterType, parent, child) => {
    const { isOpen } = getAccordionSubSection(filterType + '-' + parent.uuid, child.uuid)
    const showSearchField = [
      'responsible_user',
      'responsible_delegation',
      'entrusted_to_user',
      'entrusted_to_group',
      'entrusted_to_api_client'
    ].includes(child.uuid)

    const keyClass = 'ui-side-filter-lvl2-item'
    const togglebodyClass = cx('ui-accordion-body', 'ui-side-filter-lvl3', { open: isOpen })

    return (
      <li className={keyClass} key={child.uuid}>
        {createToggleSubSection(filterType, parent, child, isOpen)}
        {createMultiSelectBox(child, current, filterType, !(parent.uuid === 'permissions'))}
        {(() => {
          if (parent.uuid === 'permissions' && showSearchField) {
            if (isOpen) {
              return renderResponsibleUser(
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
                  return renderPersonSelect(
                    current,
                    child,
                    child.children,
                    filterType,
                    togglebodyClass,
                    false
                  )
                case 'MetaDatum::Roles':
                  return ['person', 'role'].map(type => {
                    const items = child.children.filter(x => x.type === type)
                    if (items.length === 0) {
                      return false
                    }
                    if (type === 'person') {
                      return renderPersonSelect(
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
                          {items.map(item =>
                            renderItem(parent.uuid, current, child, item, filterType)
                          )}
                        </ul>
                      )
                    }
                  })
                default:
                  return (
                    <ul className={togglebodyClass}>
                      {child.children &&
                        child.children.map(item =>
                          renderItem(parent.uuid, current, child, item, filterType)
                        )}
                    </ul>
                  )
              }
            }
          }
        })()}
      </li>
    )
  }

  const dynamic = sectionGroups
    .map(sg => sg.dynamic)
    .filter(Boolean)
    .flat()

  if (isEmpty(dynamic)) {
    if (sectionGroups.some(sg => !sg.loaded)) {
      const baseClass = ui.cx(
        ui.parseMods({ accordion: accordionProp, current, onChange }),
        'ui-side-filter-list'
      )
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
  const clonedCurrent = { ...current }

  const baseClass = ui.cx(
    ui.parseMods({ accordion: accordionProp, current, onChange }),
    'ui-side-filter-list'
  )

  return (
    <ul className={baseClass} data-test-id="side-filter">
      {sectionGroups
        .map(sectionGroup => {
          if (!sectionGroup.loaded) {
            return <Preloader key={`preloader_${sectionGroup.key}`} mods="small" />
          } else if (!sectionGroup.dynamic) {
            return null
          } else {
            const filters = initializeFilterTreeFromProps(sectionGroup.dynamic, clonedCurrent)
            return filters.map(filter => renderSection(clonedCurrent, filter))
          }
        })
        .flat()
        .filter(Boolean)}
    </ul>
  )
}

SideFilter.propTypes = {
  dynamic: PropTypes.array,
  accordion: PropTypes.objectOf(PropTypes.object).isRequired,
  current: MadekPropTypes.resourceFilter.isRequired,
  onChange: PropTypes.func,
  forUrl: PropTypes.object,
  jsonPath: PropTypes.string
}

const FilterItem = ({ label, uuid, selected, count, onClick }) => {
  const itemLabel =
    // eslint-disable-next-line no-console
    presence(label || uuid) || (console.error('empty FilterItem label!') && '(empty)')
  return (
    <li className={cx('ui-side-filter-lvl3-item', { active: selected })}>
      <Link mods="weak" onClick={onClick}>
        {itemLabel} <span className="ui-lvl3-item-count">{count}</span>
      </Link>
    </li>
  )
}

const initializeFilterTreeFromProps = (dynamicFilters, current) => {
  let tree = initializeSections(dynamicFilters)
  return forCurrentFiltersSelectItemsInTree(tree, current)
}

const forCurrentFiltersSelectItemsInTree = (tree, current) => {
  const selectItemForFilter = (item, filter) => {
    if (item.uuid === filter.value) {
      item.selected = true
    }
  }

  const selectInSubSection = (subSection, filter) => {
    if (!subSection.children) return
    subSection.children.forEach(item => {
      if (subSection.uuid === filter.key) {
        subSection.selected = true
      }
      selectItemForFilter(item, filter)
    })
  }

  const selectInSection = (section, filter) => {
    if (!section.children) return
    section.children.forEach(subSection => {
      if (subSection.uuid === filter.key) {
        selectInSubSection(subSection, filter)
      }
    })
  }

  const selectInTreePerFilter = (filterType, filter) => {
    tree.forEach(section => {
      if (section.filterType === filterType) {
        selectInSection(section, filter)
      }
    })
  }

  Object.keys(current).forEach(filterType => {
    const filtersPerType = current[filterType]
    if (filtersPerType) {
      filtersPerType.forEach(filter => {
        selectInTreePerFilter(filterType, filter)
      })
    }
  })

  return tree
}

const initializeSections = dynamicFilters =>
  dynamicFilters.map(filter => {
    const { filter_type, label, uuid, children } = filter
    return {
      filterType: filter_type || uuid,
      children: initializeSubSections(children),
      label,
      uuid
    }
  })

const initializeSubSections = filters =>
  filters.map(filter => {
    const { children, label, uuid, multi, context_key_id, meta_datum_object_type, too_many_hits } =
      filter
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

const initializeItems = filters =>
  filters.map(filter => {
    const { uuid, count, type, label, detailed_name } = filter
    return {
      label: detailed_name ? detailed_name : label,
      uuid,
      count,
      selected: false,
      type
    }
  })

const getJsonPath = (baseJsonPath, key) => {
  let jsonPath = baseJsonPath
  jsonPath = jsonPath.substring(0, jsonPath.length - 'resources'.length)
  jsonPath += `dynamic_filters.${key}`
  return jsonPath
}

// Helper function to pick specific keys from an object
const pick = (obj, keys) => {
  const picked = {}
  keys.forEach(key => {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      picked[key] = obj[key]
    }
  })
  return picked
}

// Helper function to set nested value (replacement for f.set)
const setNestedValue = (obj, path, value) => {
  const keys = path.split('.')
  const result = { ...obj }
  let current = result

  for (let i = 0; i < keys.length - 1; i++) {
    const key = keys[i]
    current[key] = current[key] ? { ...current[key] } : {}
    current = current[key]
  }

  current[keys[keys.length - 1]] = value
  return result
}

export default SideFilter
module.exports = SideFilter
