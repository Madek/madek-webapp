/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * DS208: Avoid top-level this
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React, { Component } from 'react'

import urlModule from 'url'
import localLinks from 'local-links'
import f from 'active-lodash'
import _ from 'lodash'
import defaultsDeep from 'lodash/defaultsDeep'
import History from 'history/lib/createBrowserHistory'
import useBeforeUnload from 'history/lib/useBeforeUnload'

import { t } from '../lib/ui.js'
import setUrlParams from '../../lib/set-params-for-url.js'
import appRequest from '../../lib/app-request.js'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import simpleXhr from '../../lib/simple-xhr.js'
import railsFormPut from '../../lib/form-put-with-errors.js'
import { resourceTypeSwitcher } from '../lib/resource-type-switcher.jsx'

import resourceListParams from '../../shared/resource_list_params.js'

import { Icon, Link } from '../ui-components/index.js'
import BoxToolBar from '../ui-components/ResourcesBox/BoxToolBar.jsx'
import Preloader from '../ui-components/Preloader.jsx'

import ActionsDropdown from './resourcesbox/ActionsDropdown.jsx'
import Clipboard from './resourcesbox/Clipboard.jsx'
import InfoHeader from './resourcesbox/InfoHeader.jsx'

import CreateCollectionModal from '../views/My/CreateCollectionModal.jsx'

import BoxUtil from './BoxUtil.js'
import BoxSetUrlParams from './BoxSetUrlParams.jsx'
import BoxBatchEditForm from './BoxBatchEditForm.jsx'
import BoxRedux from './BoxRedux.js'
import BoxState from './BoxState.js'
import BoxTitlebar from './BoxTitlebar.jsx'
import BoxFilterButton from './BoxFilterButton.jsx'
import BoxSetFallback from './BoxSetFallback.jsx'
import BoxDestroy from './BoxDestroy.jsx'
import BoxRenderResources from './BoxRenderResources.jsx'
import BoxSidebar from './BoxSidebar.jsx'
import BoxPaginationNav from './BoxPaginationNav.jsx'
import BoxTransfer from './BoxTransfer.jsx'
import BoxSelectionLimit from './BoxSelectionLimit.jsx'
import BatchAddToSetModal from './BatchAddToSetModal.jsx'
import BatchRemoveFromSetModal from './BatchRemoveFromSetModal.jsx'
import BatchEditTitleModal from './BatchEditTitleModal.jsx'

// Props/Config overview:
// - props.get.has_user = should the UI offer any interaction
// - state.isClient = is component in client-side mode
// - props.get.can_filter = is it possible to filter the resources
// - props.get.filter = the currently active filter
// - props.get.config.show_filter = if the filterBar should be shown

const getLocalLink = function (event) {
  return localLinks.pathname(event)
}

const routerGoto = function (path) {
  const history = useBeforeUnload(History)()
  const url = urlModule.parse(path)
  return history.push(url ? url.path : undefined)
}

const isNewTab = function (event) {
  if (localLinks.pathname(event)) {
    return false
  } else {
    return true
  }
}

class MediaResourcesBox extends Component {
  static defaultProps = { fallback: true }

  constructor(props) {
    super(props)
    this.state = {
      isClient: false,
      clipboardModal: 'hidden',
      batchAddToSet: false,
      batchRemoveFromSet: false,
      batchEditTitleResourceIds: undefined,
      savedLayout: props.collectionData ? props.collectionData.layout : undefined,
      savedOrder: props.collectionData ? props.collectionData.order : undefined,
      savedContextId: f.get(props, 'collectionData.defaultContextId'),
      savedResourceType:
        props.collectionData != null ? props.collectionData.defaultResourceType : undefined,
      showBatchTransferResponsibility: false,
      batchTransferResponsibilityResources: [],
      batchDestroyResourcesModal: false,
      batchDestroyResourcesWaiting: false,
      showSelectionLimit: false,
      boxState: this.initialBoxState(props),
      showCreateCollectionModal: false
    }

    this.doOnUnmount = [] // to be filled with functions to be called on unmount
    this.requestId = Math.random()
  }

  componentWillUnmount() {
    return f.each(f.compact(this.doOnUnmount), function (fn) {
      if (f.isFunction(fn)) {
        return fn()
      } else {
        return console.error('Not a Function!', fn)
      }
    })
  }

  initialBoxState = props => {
    return BoxState({
      event: {},
      trigger: this.triggerComponentEvent,
      initial: true,
      components: {},
      data: {},
      nextProps: { get: props.get },
      path: []
    })
  }

  nextBoxState = events => {
    //console.log('nextBoxState', events.length, events[0].path, events[0].event)
    const merged = BoxRedux.mergeStateAndEventsRoot(this.state.boxState, events)

    const props = {
      get: this._mergeGet(this.props, this.state),
      currentUrl: this._currentUrl(),
      getJsonPath: this.getJsonPath
    }

    const boxState = BoxState({
      event: merged.event,
      trigger: this.triggerComponentEvent,
      initial: false,
      components: merged.components,
      data: merged.data,
      nextProps: props,
      path: []
    })

    this.setState({ boxState })
  }

  triggerRootEvent = event => {
    const events = [
      {
        path: [],
        event
      }
    ]
    this.nextBoxState(events)
  }

  triggerComponentEvent = (component, event) => {
    const events = [
      {
        path: component.path,
        event
      }
    ]
    this.nextBoxState(events)
  }

  onBatchButton = () => {
    this.triggerComponentEvent(this.state.boxState.components.batch, { action: 'toggle' })
  }

  onClickKey = (event, metaKeyId, contextKey) => {
    this.triggerComponentEvent(this.state.boxState.components.batch, {
      action: 'select-key',
      metaKeyId,
      contextKey
    })
  }

  onClickApplyAll = () => {
    this.triggerRootEvent({ action: 'apply' })
  }

  onClickApplySelected = () => {
    this.triggerRootEvent({ action: 'apply-selected' })
  }

  onClickCancel = () => {
    this.triggerRootEvent({ action: 'cancel-all' })
  }

  onClickIgnore = () => {
    this.triggerRootEvent({ action: 'ignore-all' })
  }

  getResources = () => {
    return f.map(this.state.boxState.components.resources, r => r.data.resource)
  }

  getJsonPath = () => {
    if (this.props.get.json_path) {
      return this.props.get.json_path
    }

    const path = urlModule.parse(this._currentUrl()).pathname
    if (
      path.indexOf('/relations/children') > 0 ||
      path.indexOf('/relations/siblings') > 0 ||
      path.indexOf('/relations/parents') > 0
    ) {
      return 'relation_resources.resources'
    }

    if (path.indexOf('/vocabulary') === 0 && path.indexOf('/content') > 0) {
      return 'resources.resources'
    }

    if (path.indexOf('/my/groups') === 0) {
      return 'resources.resources'
    }

    if (path.indexOf('/vocabulary/keyword') === 0) {
      return 'keyword.resources.resources'
    }

    if (path.indexOf('/people') === 0) {
      return 'resources.resources'
    }

    if (this.props.get.type === 'MediaResources') {
      if (this.props.get.config.for_url.pathname === this.props.get.clipboard_url) {
        return 'resources'
      } else {
        return 'child_media_resources.resources'
      }
    } else if (this.props.get.type === 'MediaEntries') {
      return 'resources'
    } else if (this.props.get.type === 'Collections') {
      return 'resources'
    }
  }

  fetchListData = () => {
    return this.triggerRootEvent({ action: 'fetch-list-data' })
  }

  componentDidMount = () => {
    if (this._mergeGet(this.props, this.state).config.layout === 'list') {
      this.fetchListData()
    }

    this.setState({
      isClient: true,
      config: resourceListParams(window.location)
    })

    return this.triggerRootEvent({ action: 'mount' })
  }

  forceFetchNextPage = () => {
    return this.triggerRootEvent({ action: 'force-fetch-next-page' })
  }

  // - custom actions:
  _onFetchNextPage = () => {
    if (this.state.boxState.data.loadingNextPage) {
      return
    }
    this.triggerRootEvent({ action: 'fetch-next-page' })
  }

  _onFilterChange = (event, newParams) => {
    if (event && f.isFunction(event.preventDefault)) {
      event.preventDefault()
    }

    // make sure that the new result starts on page 1
    const newLocation = BoxSetUrlParams(this._currentUrl(), newParams, { list: { page: 1 } })
    window.location = newLocation
  } // SYNC!

  _onFilterToggle = (event, showFilter) => {
    if (isNewTab(event)) {
      return
    }

    event.preventDefault()
    const href = getLocalLink(event)

    routerGoto(href)
    this.setState(
      {
        config: f.merge(this.state.config, { show_filter: showFilter }),
        windowHref: href
      },
      () => {
        return this._persistListConfig({ list_config: { show_filter: showFilter } })
      }
    )
  }

  _onSearch = (event, refValues) => {
    const searchFilter = () => {
      if (!this._supportsFilesearch() || refValues.searchTypeFulltextChecked) {
        return {
          search: refValues.filterSearchValue
        }
      } else {
        return {
          search: ''
        }
      }
    }

    const filenameFilter = () => {
      if (this._supportsFilesearch() && refValues.searchTypeFilenameChecked) {
        return {
          media_files: [
            {
              key: 'filename',
              value: refValues.filterSearchValue
            }
          ]
        }
      } else {
        return {}
      }
    }

    const buildFilter = () => f.merge(searchFilter(), filenameFilter())

    this._onFilterChange(event, {
      list: {
        filter: buildFilter(),
        accordion: {}
      }
    })
  }

  _onSideFilterChange = event => {
    return this._onFilterChange(event, {
      list: {
        filter: event.current,
        accordion: event.accordion
      }
    })
  }

  _selectionLimit = () => {
    return 256
  }

  _onSelectResource = (resource, event) => {
    // toggles selection item
    event.preventDefault()
    const selection = this.state.boxState.data.selectedResources
    if (
      !f.find(selection, s => s.uuid === resource.uuid) &&
      selection.length > this._selectionLimit() - 1
    ) {
      this._showSelectionLimit('single-selection')
    } else {
      this.triggerRootEvent({
        action: 'toggle-resource-selection',
        resourceUuid: resource.uuid
      })
    }
  }

  handlePositionChange = (resourceId, direction, event) => {
    event.preventDefault()

    if (this.state.boxState.data.loadingNextPage) {
      return
    }

    const currentOrder = f.get(this.state.config, 'order', this.props.collectionData.order)

    const targetOrder = f.includes(['manual ASC', 'manual DESC'], currentOrder)
      ? currentOrder
      : 'manual ASC'

    const newConfig = f.extend({}, this.state.config)
    const prevOrder = newConfig.order

    newConfig.positionChange = {
      prevOrder,
      resourceId,
      direction
    }

    const persistPosition = () => {
      return simpleXhr(
        {
          method: 'PATCH',
          url: this.props.collectionData.changePositionUrl,
          body: `positionChange=${JSON.stringify(this.state.config.positionChange)}`
        },
        error => {
          if (error) {
            return alert(error)
          } else {
            this._persistListConfig({ list_config: { order: targetOrder } })
            return this.forceFetchNextPage()
          }
        }
      )
    }

    const href = urlModule.parse(
      BoxSetUrlParams(this._currentUrl(), { list: { order: targetOrder } })
    )
    routerGoto(href)

    return this.setState(
      {
        config: f.merge(newConfig, { order: targetOrder }), //,
        windowHref: href
      },
      persistPosition
    )
  }

  _showSelectionLimit = version => {
    return this.setState({ showSelectionLimit: version })
  }

  _closeSelectionLimit = () => {
    return this.setState({ showSelectionLimit: false })
  }

  // eslint-disable-next-line no-unused-vars
  _onHoverMenu = (menu_id, event) => {
    // NOTE: Do not delete the `event` parameter although it seems to be unused!
    //       Removing it will crash the menu rendering. I don't understand how this is
    //       possible. Try it however if you don't believe it.
    this.setState({ hoverMenuId: menu_id })
  }

  _currentUrl = () => {
    if (this.state.isClient && this.state.windowHref) {
      return this.state.windowHref
    } else {
      return BoxSetUrlParams(this.props.get.config.for_url)
    }
  }

  _showBatchTransferResponsibility = resources => {
    return this.setState({
      showBatchTransferResponsibility: true,
      batchTransferResponsibilityResources: resources
    })
  }

  _hideBatchTransferResponsibility = () => {
    return this.setState({
      showBatchTransferResponsibility: false,
      batchTransferResponsibilityResources: []
    })
  }

  _sharedOnBatch = (resources, event, path) => {
    event.preventDefault()
    const selected = f.map(resources, 'uuid')

    const html =
      `<form method="post" acceptCharset="UTF-8" action="${path}">` +
      '<input type="hidden" name="authenticity_token" value="' +
      getRailsCSRFToken() +
      '"></input>' +
      '<input type="hidden" name="return_to" value="' +
      this._currentUrl() +
      '"></input>' +
      '<button type="button"></button>' +
      _.join(
        f.map(selected, s => {
          return `<input type="hidden" name="id[]" value="${s}"></input>`
        }),
        ''
      ) +
      '</form>'

    const form = $(html)
    document.body.appendChild(form[0])
    return form.submit()
  }

  _sharedOnBatchAll = (event, type) => {
    event.preventDefault()
    const id = this.props.collectionData.uuid
    const path = `/sets/${id}/batch_edit_all`
    const url = setUrlParams(path, { type, return_to: this._currentUrl() })
    return (window.location = url)
  }

  _persistListConfig = config => {
    const req = appRequest(
      { method: 'PATCH', url: this._routeUrl('session_list_config'), json: config },
      function (err) {
        if (err) {
          return console.error(err)
        }
      }
    )
    return this.doOnUnmount.push(function () {
      if (req && req.abort) {
        return req.abort()
      }
    })
  }

  _onBatchEditAll = event => {
    this._sharedOnBatchAll(event, 'media_entry')
  }

  _onBatchEdit = (resources, event) => {
    this._sharedOnBatch(
      resources,
      event,
      this._routeUrl('batch_edit_meta_data_by_context_media_entries')
    )
  }

  _onBatchEditAllSets = event => {
    this._sharedOnBatchAll(event, 'collection')
  }

  _onBatchEditSets = (resources, event) => {
    this._sharedOnBatch(
      resources,
      event,
      this._routeUrl('batch_edit_meta_data_by_context_collections')
    )
  }

  _onBatchDeleteResources = (resources, event) => {
    event.preventDefault()
    this.setState({
      batchDestroyResourcesModal: true,
      batchDestroyResourcesWaiting: false,
      batchDestroyResourcesError: false,
      batchDestroyResourceIdsWithTypes: resources.map(model => ({
        uuid: model.uuid,
        type: model.type
      }))
    })
    return false
  }

  _onExecuteBatchDeleteResources = () => {
    this.setState({ batchDestroyResourcesWaiting: true })
    const resourceIds = this.state.batchDestroyResourceIdsWithTypes
    const url = setUrlParams(this._routeUrl('batch_destroy_resources'), {})
    railsFormPut.byData({ resource_id: resourceIds }, url, result => {
      if (result.result === 'error') {
        window.scrollTo(0, 0)
        return this.setState({
          batchDestroyResourcesError: result.message,
          batchDestroyResourcesWaiting: false
        })
      } else {
        return location.reload()
      }
    })
    return false
  }

  _onBatchPermissionsEdit = (resources, event) => {
    this._sharedOnBatch(resources, event, this._routeUrl('batch_edit_permissions_media_entries'))
  }

  _onBatchPermissionsSetsEdit = (resources, event) => {
    this._sharedOnBatch(resources, event, this._routeUrl('batch_edit_permissions_collections'))
  }

  _onBatchTransferResponsibilityEdit = (resources, event) => {
    this._showBatchTransferResponsibility(resources, event)
  }

  _onBatchTransferResponsibilitySetsEdit = (resources, event) => {
    this._showBatchTransferResponsibility(resources, event)
  }

  _onBatchAddToSet = (resources, event) => {
    event.preventDefault()
    this.setState({ batchAddToSet: true })
    return false
  }

  _onBatchRemoveFromSet = (resources, event) => {
    event.preventDefault()
    this.setState({ batchRemoveFromSet: true })
    return false
  }

  _onBatchEditTitle = (resourceIds, event) => {
    event.preventDefault()
    this.setState({
      batchEditTitleResourceIds: this._selectedResourceIdsWithTypes().filter(resource =>
        resourceIds.includes(resource.uuid)
      )
    })
    return false
  }

  _selectedResourceIdsWithTypes = () => {
    return this.state.boxState.data.selectedResources.map(model => ({
      uuid: model.uuid,
      type: model.type
    }))
  }

  _onBatchAddAllToClipboard = event => {
    event.preventDefault()
    this.setState({ clipboardModal: 'add_all' })
  }

  _onBatchAddSelectedToClipboard = (resources, event) => {
    event.preventDefault()
    this.setState({ clipboardModal: 'add_selected' })
  }

  _onBatchRemoveAllFromClipboard = event => {
    event.preventDefault()
    this.setState({ clipboardModal: 'remove_all' })
  }

  _onBatchRemoveFromClipboard = (resources, event) => {
    event.preventDefault()
    this.setState({ clipboardModal: 'remove_selected' })
  }

  _onCloseModal = () => {
    this.setState({ clipboardModal: 'hidden' })
    this.setState({ batchAddToSet: false })
    this.setState({ batchRemoveFromSet: false })
    this.setState({ batchEditTitleResourceIds: undefined })
    this.setState({ batchDestroyResourcesModal: false })
  }

  /**
   * Returns `props.get`, adding default data from various sources to `props.get.config`
   */
  _mergeGet = (props, state) => {
    return f.extend(props.get, {
      config: defaultsDeep(
        // first wins!
        {},
        state.config,
        props.get.config,
        props.initial,
        {
          layout: state.savedLayout,
          order: state.savedOrder
        },
        props.get.config.user,
        {
          layout: 'grid',
          order: 'last_change DESC',
          show_filter: false
        }
      )
    })
  }

  _supportsFilesearch = () => {
    const { get } = this.props
    return (
      !get.disable_file_search &&
      !(get.config && get.config.for_url && get.config.for_url.query.type === 'collections')
    )
  }

  _routeUrl = name => {
    return this.props.get.route_urls[name]
  }

  _resetFilterLink = config => {
    const resetFilterHref = BoxSetUrlParams(this._currentUrl(), {
      list: { page: 1, filter: {}, accordion: {} }
    })

    if (resetFilterHref) {
      if (f.present(config.filter) || f.present(config.accordion)) {
        return (
          <Link mods="mlx weak" href={resetFilterHref}>
            <Icon i="undo" /> {t('resources_box_reset_filter')}
          </Link>
        )
      }
    }
  }

  unselectResources = resources => {
    return this.triggerRootEvent({
      action: 'unselect-resources',
      resourceUuids: f.map(resources, r => r.uuid)
    })
  }

  selectResources = resources => {
    return this.triggerRootEvent({
      action: 'select-resources',
      resourceUuids: f.map(resources, r => r.uuid)
    })
  }

  onSortItemClick = (event, itemKey) => {
    if (isNewTab(event)) {
      return
    }

    event.preventDefault()

    const href = getLocalLink(event)
    routerGoto(href)

    return this.setState(
      {
        config: f.merge(this.state.config, { order: itemKey }),
        windowHref: href
      },
      () => {
        // @state.resources.clearPages({
        //   pathname: url.pathname,
        //   query: url.query
        // })

        this.forceFetchNextPage()
        return this._persistListConfig({ list_config: { order: itemKey } })
      }
    )
  }

  onLayoutClick = (event, layoutMode) => {
    if (isNewTab(event)) {
      return
    }
    event.preventDefault()
    const href = getLocalLink(event)
    routerGoto(href)
    return this.setState(
      {
        config: f.merge(this.state.config, { layout: layoutMode.mode }),
        windowHref: href
      },
      () => {
        if (layoutMode.mode === 'list') {
          this.fetchListData()
        }
        return this._persistListConfig({ list_config: { layout: layoutMode.mode } })
      }
    )
  }

  layoutSave = event => {
    event.preventDefault()
    const { config } = this._mergeGet(this.props, this.state)
    const { layout } = config
    const { order } = config
    const contextId = f.get(this.props, 'collectionData.contextId')
    const typeFilter = f.get(this.props, 'collectionData.typeFilter')

    const requestBody = []
    requestBody.push(`collection[layout]=${layout}`)
    requestBody.push(`collection[sorting]=${order}`)
    if (contextId) {
      requestBody.push(`collection[default_context_id]=${contextId}`)
    }
    requestBody.push(`collection[default_resource_type]=${typeFilter}`)

    simpleXhr(
      {
        method: 'PATCH',
        url: this.props.collectionData.url,
        body: requestBody.join('&')
      },
      error => {
        if (error) {
          return alert(error)
        } else {
          return this.setState({
            savedLayout: layout,
            savedOrder: order,
            savedContextId: contextId,
            savedResourceType: typeFilter
          })
        }
      }
    )
    return false
  }

  render() {
    let { get, mods, fallback, heading, listMods, saveable, authToken, children } = this.props

    get = this._mergeGet(this.props, this.state)

    const resources = this.getResources()

    const { config } = get

    const currentQuery = f.merge(
      { list: f.merge(f.omit(config, 'for_url', 'user')) },
      {
        list: { filter: config.filter, accordion: config.accordion }
      }
    )
    const currentUrl = this._currentUrl()

    const boxTitleBar = () => {
      const { layout, order } = config
      const totalCount = f.get(get, 'pagination.total_count')

      const layouts = BoxUtil.allowedLayoutModes(this.props.disableListMode).map(layoutMode => {
        const href = BoxSetUrlParams(currentUrl, { list: { layout: layoutMode.mode } })
        return f.merge(layoutMode, {
          mods: { active: layoutMode.mode === layout },
          href
        })
      })

      return (
        <BoxTitlebar
          actionName={this.props.actionName}
          enableOrderByTitle={this.props.enableOrderByTitle}
          layout={layout}
          order={order}
          savedLayout={this.state.savedLayout}
          savedOrder={this.state.savedOrder}
          savedContextId={this.state.savedContextId}
          savedResourceType={this.state.savedResourceType}
          defaultTypeFilter={
            this.props.collectionData != null
              ? this.props.collectionData.defaultTypeFilter
              : undefined
          }
          layoutSave={this.layoutSave}
          collectionData={this.props.collectionData}
          heading={heading}
          totalCount={totalCount}
          mods={mods}
          layouts={layouts}
          onSortItemClick={this.onSortItemClick}
          selectedSort={order}
          enableOrdering={this.props.enableOrdering}
          enableOrderByManual={this.props.enableOrderByManual}
          currentUrl={currentUrl}
          onLayoutClick={this.onLayoutClick}
        />
      )
    }

    const actionsDropdownParameters = {
      totalCount: this.props.get.pagination ? this.props.get.pagination.total_count : undefined,
      withActions: get.has_user,
      selection: this.state.boxState.data.selectedResources || false,
      saveable: saveable || false,
      draftsView: this.props.draftsView,
      isClient: this.state.isClient,
      collectionData: this.props.collectionData,
      config,
      featureToggles: get.feature_toggles,
      isClipboard: this.props.initial ? this.props.initial.is_clipboard : false,
      content_type: this.props.get.content_type,
      showAddSetButton: f.get(this.props, 'showAddSetButton', false)
    }

    const boxToolBar = () => {
      const actionsDropdown = (
        <ActionsDropdown
          parameters={actionsDropdownParameters}
          callbacks={{
            onBatchAddAllToClipboard: this._onBatchAddAllToClipboard,
            onBatchAddSelectedToClipboard: this._onBatchAddSelectedToClipboard,
            onBatchRemoveAllFromClipboard: this._onBatchRemoveAllFromClipboard,
            onBatchRemoveFromClipboard: this._onBatchRemoveFromClipboard,
            onBatchAddToSet: this._onBatchAddToSet,
            onBatchRemoveFromSet: this._onBatchRemoveFromSet,
            onBatchEditTitle: this._onBatchEditTitle,
            onBatchEditAll: this._onBatchEditAll,
            onBatchEdit: this._onBatchEdit,
            onBatchEditAllSets: this._onBatchEditAllSets,
            onBatchEditSets: this._onBatchEditSets,
            onBatchDeleteResources: this._onBatchDeleteResources,
            onBatchPermissionsEdit: this._onBatchPermissionsEdit,
            onBatchPermissionsSetsEdit: this._onBatchPermissionsSetsEdit,
            onBatchTransferResponsibilityEdit: this._onBatchTransferResponsibilityEdit,
            onBatchTransferResponsibilitySetsEdit: this._onBatchTransferResponsibilitySetsEdit,
            onHoverMenu: this._onHoverMenu,
            onQuickBatch: this.onBatchButton,
            onShowCreateCollectionModal: () => this.setState({ showCreateCollectionModal: true })
          }}
        />
      )

      const filterToggleLink = BoxSetUrlParams(currentUrl, {
        list: { show_filter: !config.show_filter }
      })

      const filterBarProps = {
        left: (
          <BoxFilterButton
            get={get}
            config={config}
            _onFilterToggle={this._onFilterToggle}
            filterToggleLink={filterToggleLink}
            resetFilterLink={f.present(config.filter) ? this._resetFilterLink(config) : undefined}
          />
        ),

        right: actionsDropdown ? <div>{actionsDropdown}</div> : undefined,

        middle: this.props.resourceTypeSwitcherConfig
          ? this.props.resourceTypeSwitcherConfig.customRenderer
            ? this.props.resourceTypeSwitcherConfig.customRenderer(currentUrl)
            : resourceTypeSwitcher(
                currentUrl,
                this.props.collectionData != null
                  ? this.props.collectionData.defaultTypeFilter
                  : undefined,
                this.props.resourceTypeSwitcherConfig.showAll,
                null
              )
          : undefined
      }

      return <BoxToolBar {...Object.assign({}, filterBarProps)} />
    }

    const sidebar = (({ config, dynamic_filters }, { isClient }) => {
      if (!config.show_filter) {
        return null
      }
      return (
        <BoxSidebar
          config={config}
          dynamic_filters={dynamic_filters}
          isClient={isClient}
          currentQuery={currentQuery}
          currentUrl={this._currentUrl()}
          onSearch={this._onSearch}
          supportsFilesearch={this._supportsFilesearch()}
          onlyFilterSearch={get.only_filter_search}
          parentState={this.state}
          onSideFilterChange={this._onSideFilterChange}
          jsonPath={this.getJsonPath()}
        />
      )
    })(get, this.state)

    const paginationNav = (resources, staticPagination) => {
      return (
        <BoxPaginationNav
          resources={resources}
          staticPagination={staticPagination}
          onFetchNextPage={this._onFetchNextPage}
          loadingNextPage={this.state.boxState.data.loadingNextPage}
          isClient={this.state.isClient}
          permaLink={BoxSetUrlParams(this._currentUrl(), currentQuery)}
          currentUrl={currentUrl}
          perPage={this.props.get.config.per_page}
        />
      )
    }

    // component:
    return (
      <div data-test-id="resources-box" className={BoxUtil.boxClasses(mods)}>
        {(() => {
          if (this.state.showBatchTransferResponsibility) {
            const actionUrls = {
              MediaEntry: this._routeUrl('batch_update_transfer_responsibility_media_entries'),
              Collection: this._routeUrl('batch_update_transfer_responsibility_collections')
            }
            return React.createElement(BoxTransfer, {
              authToken: this.props.authToken,
              transferResources: this.state.batchTransferResponsibilityResources,
              onClose: this._hideBatchTransferResponsibility,
              onSaved() {
                return location.reload()
              },
              actionUrls: actionUrls,
              currentUser: this.props.get.current_user
            })
          }
        })()}
        {(() => {
          if (this.state.showSelectionLimit) {
            return (
              <BoxSelectionLimit
                showSelectionLimit={this.state.showSelectionLimit}
                selectionLimit={this._selectionLimit()}
                onClose={this._closeSelectionLimit}
              />
            )
          }
        })()}
        {boxTitleBar()}
        {get.info_header ? (
          <div className="mam">
            <InfoHeader {...Object.assign({}, get.info_header)} />
          </div>
        ) : undefined}
        {boxToolBar()}
        {this.state.showCreateCollectionModal ? (
          <CreateCollectionModal
            get={get.new_collection}
            async={false}
            authToken={authToken}
            onClose={() => this.setState({ showCreateCollectionModal: false })}
            newCollectionUrl={f.get(this.props, 'collectionData.newCollectionUrl')}
          />
        ) : undefined}
        <div className="ui-resources-holder pam">
          <div className="ui-container table auto">
            {sidebar}
            <div className="ui-container table-cell table-substance">
              {children}
              <BoxBatchEditForm
                onClose={e => this.onBatchButton(e)}
                stateBox={this.state.boxState}
                onClickKey={(e, k, ck) => this.onClickKey(e, k, ck)}
                onClickApplyAll={e => this.onClickApplyAll(e)}
                onClickApplySelected={e => this.onClickApplySelected(e)}
                onClickCancel={e => this.onClickCancel(e)}
                onClickIgnore={e => this.onClickIgnore(e)}
                totalCount={this.props.get.pagination.total_count}
                allLoaded={
                  this.props.get.pagination &&
                  this.state.boxState.components.resources.length ===
                    this.props.get.pagination.total_count
                }
                trigger={this.triggerComponentEvent}
              />
              {(() => {
                if (resources.length === 0 && this.state.boxState.data.loadingNextPage) {
                  return <Preloader />
                } else if (!f.present(resources) || resources.length === 0) {
                  return (() => {
                    return (
                      <BoxSetFallback
                        fallback={fallback}
                        try_collections={get.try_collections}
                        currentUrl={this._currentUrl()}
                        usePathUrlReplacement={this.props.usePathUrlReplacement}
                        resetFilterLink={this._resetFilterLink(config)}
                      />
                    )
                  })()
                } else {
                  const positionProps = {
                    handlePositionChange: this.handlePositionChange,
                    changeable: f.get(this.props, 'collectionData.position_changeable', false),
                    disabled: this.state.boxState.data.loadingNextPage
                  }

                  return (
                    <BoxRenderResources
                      resources={f.map(this.state.boxState.components.resources, r => r)}
                      applyJob={this.state.boxState.components.batch.data.applyJob}
                      actionsDropdownParameters={actionsDropdownParameters}
                      selectedResources={this.state.boxState.data.selectedResources}
                      isClient={this.state.isClient}
                      showSelectionLimit={this._showSelectionLimit}
                      selectionLimit={this._selectionLimit()}
                      onSelectResource={this._onSelectResource}
                      positionProps={positionProps}
                      config={config}
                      hoverMenuId={this.state.hoverMenuId}
                      authToken={authToken}
                      withActions={get.has_user}
                      listMods={listMods}
                      pagination={this.props.get.pagination}
                      perPage={this.props.get.config.per_page}
                      showBatchButtons={{
                        editMode:
                          this.state.boxState.components.batch.data.open &&
                          this.state.boxState.components.batch.components.metaKeyForms.length > 0
                      }}
                      unselectResources={this.unselectResources}
                      selectResources={resources => this.selectResources(resources)}
                      trigger={this.triggerComponentEvent}
                      selectionMode={this.state.boxState.components.batch.data.open}
                    />
                  )
                }
              })()}
              {paginationNav(resources, get.pagination)}
            </div>
          </div>
        </div>
        {this.state.clipboardModal !== 'hidden' ? (
          <Clipboard
            type={this.state.clipboardModal}
            onClose={() => this.setState({ clipboardModal: 'hidden' })}
            resources={this.getResources()}
            selectedResources={this.state.boxState.data.selectedResources}
            pagination={this.props.get.pagination}
            forUrl={this.props.for_url}
            jsonPath={this.getJsonPath()}
          />
        ) : undefined}
        {this.state.batchAddToSet ? (
          <BatchAddToSetModal
            resourceIds={this._selectedResourceIdsWithTypes()}
            authToken={this.props.authToken}
            get={null}
            onClose={this._onCloseModal}
            returnTo={currentUrl}
          />
        ) : undefined}
        {this.state.batchRemoveFromSet ? (
          <BatchRemoveFromSetModal
            collectionUuid={this.props.collectionData.uuid}
            resourceIds={this._selectedResourceIdsWithTypes()}
            authToken={this.props.authToken}
            get={null}
            onClose={this._onCloseModal}
            returnTo={currentUrl}
          />
        ) : undefined}
        {this.state.batchEditTitleResourceIds ? (
          <BatchEditTitleModal
            resourceIds={this.state.batchEditTitleResourceIds}
            authToken={this.props.authToken}
            onClose={this._onCloseModal}
            returnTo={currentUrl}
          />
        ) : undefined}
        {(() => {
          if (this.state.batchDestroyResourcesModal) {
            return (
              <BoxDestroy
                loading={this.state.batchDestroyResourcesWaiting}
                error={this.state.batchDestroyResourcesError}
                idsWithTypes={this.state.batchDestroyResourceIdsWithTypes}
                onClose={this._onCloseModal}
                onOk={this._onExecuteBatchDeleteResources}
              />
            )
          }
        })()}
      </div>
    )
  }
}

MediaResourcesBox.propTypes = require('./BoxPropTypes.js').propTypes()
module.exports = MediaResourcesBox
