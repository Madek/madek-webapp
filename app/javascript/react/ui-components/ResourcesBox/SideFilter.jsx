import React from 'react'
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

class SideFilter extends React.Component {
  static propTypes = {
    forUrl: PropTypes.object,
    jsonPath: PropTypes.string,
    accordion: PropTypes.objectOf(PropTypes.object).isRequired,
    current: MadekPropTypes.resourceFilter.isRequired,
    onChange: PropTypes.func,
    anyResourcesShown: PropTypes.bool
  }

  // Note: We list in the menu the sections based on the meta data contexts.
  // But furthermore, we also for example list the media types as a section
  // with an artifical uuid "file". We must make sure, that we have not clash
  // for example, when a context has the id "file". Thats why section uuids must
  // be concatenated with the filter_type.
  // E.g. meta_data:copyright or media_files:file

  constructor(props) {
    super(props)
    this.state = {
      javascript: false,
      accordion: this.props.accordion || {},
      sectionGroups: [
        {
          key: 'section_group_media_files',
          status: 'initial',
          data: null
        },
        {
          key: 'section_group_permissions',
          status: 'initial',
          data: null
        },
        {
          key: 'section_group_meta_data',
          status: 'initial',
          data: null
        }
      ]
    }
  }

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
  }

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
  }

  toggleSection(sectionUuid, section) {
    const sectionState = this.getAccordionSection(sectionUuid)
    sectionState.isOpen = !sectionState.isOpen

    if (sectionState.isOpen && section.triggersLoadForGroup) {
      const sectionGroupToLoad = this.state.sectionGroups.find(
        x => x.key === section.triggersLoadForGroup
      )
      const urlAndQuery = this._getUrlAndQuery()
      this._fetchSectionGroup(sectionGroupToLoad, urlAndQuery)
    }

    return this.setState({ accordion: this.state.accordion })
  }

  toggleSubSection(sectionUuid, subSectionUuid) {
    const subSection = this.getAccordionSubSection(sectionUuid, subSectionUuid)
    subSection.isOpen = !subSection.isOpen
    return this.setState({ accordion: this.state.accordion })
  }

  componentDidMount() {
    this._isMounted = true
    this.setState({ javascript: true })

    this._initialFetch()
  }

  componentWillUnmount() {
    return (this._isMounted = false)
  }

  _getUrlAndQuery() {
    const url = this.props.forUrl
    const query = parseQuery(url.query)
    if (!query.list) {
      query.list = {}
    }
    query.list.sparse_filter = true
    query.list.show_filter = true
    return { url, query }
  }

  _fetchSectionGroup(group, { url, query }) {
    const { key } = group

    const jsonPath = getJsonPath(this.props.jsonPath, key)

    return loadXhr(
      {
        method: 'GET',
        url: setUrlParams(url, query, {
          ___sparse: JSON.stringify(f.set({}, jsonPath, {}))
        })
      },
      (result, json) => {
        if (!this._isMounted) {
          return
        }
        if (result === 'success') {
          const data = f.get(json, jsonPath)

          const newSectionGroups = this.state.sectionGroups.map(sectionGroup => {
            if (sectionGroup.key === key) {
              return { ...sectionGroup, data, status: 'loaded' }
            } else {
              return sectionGroup
            }
          })

          this.setState({ sectionGroups: newSectionGroups })

          this._updateAccordion(
            f.flatten(f.compact(f.map(newSectionGroups, sectionGroup => sectionGroup.data)))
          )
        } else {
          return console.error('Could not load side filter data.')
        }
      }
    )
  }

  _stubPermissionGroup() {
    const key = 'section_group_permissions'
    const newSectionGroups = this.state.sectionGroups.map(sectionGroup => {
      if (sectionGroup.key === key) {
        if (this.props.anyResourcesShown) {
          return {
            ...sectionGroup,
            data: [
              {
                label: t('dynamic_filters_authorization'),
                filter_type: 'permissions',
                uuid: 'permissions',
                children: [],
                triggersLoadForGroup: key
              }
            ],
            status: 'stubbed'
          }
        } else {
          return { ...sectionGroup, data: [], status: 'loaded' }
        }
      } else {
        return sectionGroup
      }
    })
    this.setState({ sectionGroups: newSectionGroups })
  }

  _initialFetch() {
    const urlAndQuery = this._getUrlAndQuery()
    this.state.sectionGroups.forEach(sectionGroup => {
      if (sectionGroup.key === 'section_group_permissions' && !this.props.current.permissions) {
        this._stubPermissionGroup()
      } else {
        this._fetchSectionGroup(sectionGroup, urlAndQuery)
      }
    })
  }

  _updateAccordion(data) {
    f.each(
      [
        this.props.current.media_files,
        this.props.current.meta_data,
        this.props.current.permissions
      ],
      array => {
        return f.each(array, media_file_or_meta_datum_or_permission => {
          return f.each(data, section => {
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
  }

  render() {
    let { current } = this.props
    const sectionsData = f.flatten(
      f.compact(f.map(this.state.sectionGroups, sectionGroup => sectionGroup.data))
    )

    if (sectionsData.length === 0) {
      // No sections to show. Check whether we are still loading data
      const someWaiting = this.state.sectionGroups.find(x => x.status === 'initial')
      if (someWaiting) {
        return (
          <ul data-test-id="side-filter">
            <Preloader mods="small" />
          </ul>
        )
      } else {
        return null
      }
    }

    return (
      <ul
        className={ui.cx(ui.parseMods(this.props), 'ui-side-filter-list')}
        data-test-id="side-filter">
        {f.flatten(
          f.compact(
            f.map(this.state.sectionGroups, sectionGroup => {
              if (sectionGroup.status == 'initial') {
                return <Preloader key={`preloader_${sectionGroup.key}`} mods="small" />
              } else if (!sectionGroup.data) {
                return null
              } else {
                const sections = getSections(sectionGroup.data)
                applyCurrentSelectionToFilterTree(sections, current)
                return f.map(sections, section => {
                  return this.renderSection(current, section)
                })
              }
            })
          )
        )}
      </ul>
    )
  }

  renderSection(current, section) {
    const itemClass = 'ui-side-filter-lvl1-item ui-side-filter-item'

    const { filterType, uuid, label, children, triggersLoadForGroup } = section
    const sectionUuid = filterType + '-' + uuid
    const { isOpen } = this.getAccordionSection(sectionUuid)

    const toggleOnClick = () => this.toggleSection(sectionUuid, section)

    return (
      <li className={itemClass} key={sectionUuid}>
        <a
          className={cx('ui-accordion-toggle', 'strong', { open: isOpen })}
          href={null}
          onClick={toggleOnClick}>
          {label} <i className="ui-side-filter-lvl1-marker" />
        </a>
        <ul className={cx('ui-accordion-body', 'ui-side-filter-lvl2', { open: isOpen })}>
          {isOpen &&
            (triggersLoadForGroup && children.length === 0 ? (
              <li>
                <Preloader mods="small" />
              </li>
            ) : (
              f.map(children, child => {
                return this.renderSubSection(current, filterType, section, child)
              })
            ))}
        </ul>
      </li>
    )
  }

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
                            return this.renderItem(current, child, item, filterType)
                          })}
                        </ul>
                      )
                    }
                  })
                default:
                  return (
                    <ul className={togglebodyClass}>
                      {f.map(child.children, item => {
                        return this.renderItem(current, child, item, filterType)
                      })}
                    </ul>
                  )
              }
            }
          }
        })()}
      </li>
    )
  }

  renderPersonSelect(current, child, items, filterType, className, withTitle) {
    const onSelect = person =>
      this.addItemFilter(this.props.onChange, current, child, person, filterType)
    const onClear = person =>
      this.removeItemFilter(this.props.onChange, current, person, filterType)
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
  }

  renderResponsibleUser(node, parentUuid, current, parent, filterType, togglebodyClass) {
    const userChanged = user => {
      const { onChange } = this.props
      if (user.selected) {
        return this.removeItemFilter(onChange, current, user, filterType)
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
  }

  renderItem(current, parent, item, filterType) {
    const { onChange } = this.props
    const onItemClick = () => {
      if (item.selected) {
        return this.removeItemFilter(onChange, current, item, filterType)
      } else {
        return this.addItemFilter(onChange, current, parent, item, filterType)
      }
    }

    return (
      <li key={item.uuid} className={cx('ui-side-filter-lvl3-item', { active: item.selected })}>
        <Link mods="weak" onClick={onItemClick}>
          {item.label || item.uuid || '(empty)'}{' '}
          <span className="ui-lvl3-item-count">{item.count}</span>
        </Link>
      </li>
    )
  }

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
  }

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
  }

  addItemFilter(onChange, current, parent, item, filterType) {
    let currentPerType = current[filterType] || []
    // When we add a child filter, the parent filter is no longer needed.
    currentPerType = f
      .reject(
        currentPerType,

        // Remove the filter, if it is in the section and consists only of
        // key, but has no value or match.
        // If multi is false, then we remove all from this section.
        function (filter) {
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
  }

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
  }

  removeItemFilter(onChange, current, item, filterType) {
    let currentPerType = current[filterType] || []
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
  }

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
}

module.exports = SideFilter

// Tree structure in `data`: sections -> filters -> filter items
// E.g. "File information" -> "Media type" -> "video"

function getSections(data) {
  return data.map(({ filter_type, label, uuid, children, triggersLoadForGroup }) => ({
    filterType: filter_type || uuid,
    children: getFilters(children),
    label,
    uuid,
    triggersLoadForGroup
  }))
}

function getFilters(data) {
  return data.map(
    ({ children, label, uuid, multi, context_key_id, meta_datum_object_type, too_many_hits }) => ({
      children: getFilterItems(children),
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
    })
  )
}

function getFilterItems(data) {
  return data.map(filter => {
    const { uuid, count, type, label, detailed_name } = filter
    return {
      label: detailed_name ? detailed_name : label,
      uuid,
      count,
      selected: false,
      type
    }
  })
}

function applyCurrentSelectionToFilterTree(sections, current) {
  const selectItemForFilter = (item, filter) => {
    if (item.uuid === filter.value) {
      return (item.selected = true)
    }
  }

  const selectInSubSection = (subSection, filter) => {
    const result = []
    for (const i in subSection.children) {
      const item = subSection.children[i]
      if (subSection.uuid === filter.key) {
        subSection.selected = true
      }
      result.push(selectItemForFilter(item, filter))
    }
    return result
  }

  const selectInSection = (section, filter) => {
    const result = []
    for (const i in section.children) {
      const subSection = section.children[i]
      if (subSection.uuid === filter.key) {
        result.push(selectInSubSection(subSection, filter))
      } else {
        result.push(undefined)
      }
    }
    return result
  }

  const selectInTreePerFilter = (filterType, filter) => {
    const result = []
    for (const i in sections) {
      const section = sections[i]
      if (section.filterType === filterType) {
        result.push(selectInSection(section, filter))
      } else {
        result.push(undefined)
      }
    }
    return result
  }

  for (const filterType in current) {
    const filtersPerType = current[filterType]
    for (const i in filtersPerType) {
      const filter = filtersPerType[i]
      selectInTreePerFilter(filterType, filter)
    }
  }

  return sections
}

function getJsonPath(baseJsonPath, key) {
  let jsonPath = baseJsonPath
  jsonPath = jsonPath.substring(0, jsonPath.length - 'resources'.length)
  jsonPath += `dynamic_filters.${key}`
  return jsonPath
}
