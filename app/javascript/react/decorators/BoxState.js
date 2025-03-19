import l from 'lodash'
import BoxBatchEdit from './BoxBatchEdit.js'
import BoxResource from './BoxResource.js'
import BoxStatePrecalculate from './BoxStatePrecalculate.js'
import BoxStateFetchNextPage from './BoxStateFetchNextPage.js'

module.exports = merged => {
  const { event, trigger, initial, components, data, nextProps, path } = merged
  const {
    // cachedToApplyMetaData,
    willFetch,
    willStartApply,
    anyApplyAction,
    todoLoadMetaData
  } = BoxStatePrecalculate(merged)

  const next = () => {
    if (willFetch) {
      BoxStateFetchNextPage(merged, nextResources().length)
    }

    return {
      props: nextProps,
      path: path,
      data: {
        loadingNextPage: nextLoadingNextPage(),
        selectedResources: nextSelectedResources(),
        currentRequestSeriesId:
          event.action === 'force-fetch-next-page' || event.action === 'mount'
            ? event.currentRequestSeriesId
            : data.currentRequestSeriesId
      },
      components: {
        resources: nextResources(),
        batch: nextBatch()
      }
    }
  }

  const nextSelectedResources = () => {
    if (initial) {
      return null
    }

    if (
      event.action == 'mount' &&
      l.includes(['MediaResources', 'MediaEntries', 'Collections'], nextProps.get.type)
    ) {
      return []
    } else if (event.action == 'toggle-resource-selection') {
      if (l.find(data.selectedResources, sr => sr.uuid == event.resourceUuid)) {
        return l.reject(data.selectedResources, sr => sr.uuid == event.resourceUuid)
      } else {
        return l.concat(
          data.selectedResources,
          l.find(components.resources, cr => cr.data.resource.uuid == event.resourceUuid).data
            .resource
        )
      }
    } else if (event.action == 'unselect-resources') {
      return l.reject(data.selectedResources, sr => l.includes(event.resourceUuids, sr.uuid))
    } else if (event.action == 'select-resources') {
      return l.concat(
        data.selectedResources,
        l.map(
          event.resourceUuids,
          rid => l.find(components.resources, cr => cr.data.resource.uuid == rid).data.resource
        )
      )
    } else {
      return data.selectedResources
    }
  }

  const nextLoadingNextPage = () => {
    if (initial) {
      return false
    }

    if (willFetch) {
      return true
    } else if (event.action == 'page-loaded') {
      return false
    } else {
      return data.loadingNextPage
    }
  }

  const nextBatch = () => {
    const applyResources = () => {
      if (!willStartApply) {
        return null
      }

      if (event.action == 'apply') {
        return l.map(components.resources, rs => rs.data.resource)
      } else if (event.action == 'apply-selected') {
        return l.map(data.selectedResources, r => r)
      } else {
        return l.map(
          l.filter(components.resources, rs => rs.event.action == 'apply'),
          rs => rs.data.resource
        )
      }
    }

    const retryResources = () => {
      return l.map(
        l.filter(components.resources, rs => rs.event.action == 'retry'),
        rs => rs.data.resource
      )
    }

    const props = {
      mount: event.action == 'mount',
      // cachedToApplyMetaData: cachedToApplyMetaData,
      willStartApply: willStartApply,
      anyApplyAction: anyApplyAction,
      applyResources: applyResources(),
      retryResources: retryResources(),
      cancelAll: event.action == 'cancel-all',
      ignoreAll: event.action == 'ignore-all'
    }

    return BoxBatchEdit({
      event: initial ? {} : components.batch.event,
      trigger: trigger,
      initial: initial,
      components: initial ? {} : components.batch.components,
      data: initial ? {} : components.batch.data,
      nextProps: props,
      path: ['batch']
    })
  }

  const nextResources = () => {
    const nextResourceProps = resource => {
      const thumbnailMetaData = () => {
        if (components.batch && components.batch.event.action == 'apply-success') {
          const event = components.batch.event
          if (event.resourceId == resource.uuid) {
            return event.thumbnailMetaData
          }
        }
        return null
      }

      return {
        resource: resource,
        loadMetaData: todoLoadMetaData[resource.uuid] ? true : false,
        thumbnailMetaData: thumbnailMetaData(),
        resetListMetaData:
          willStartApply &&
          (event.action == 'apply' ||
            (event.action == 'apply-selected' &&
              l.find(data.selectedResources, r => r.uuid == resource.uuid)) ||
            l.find(
              components.resources,
              rs => rs.data.resource.uuid == resource.uuid && rs.event.action == 'apply'
            ))
      }
    }

    const mapResourceState = resourceState => {
      const resource = resourceState.data.resource
      const resourceProps = nextResourceProps(resource)

      return BoxResource({
        event: resourceState.event,
        trigger: trigger,
        initial: false,
        components: resourceState.components,
        data: resourceState.data,
        nextProps: resourceProps,
        path: resourceState.path
      })
    }

    const mapResource = (resource, index) => {
      const resourceProps = nextResourceProps(resource)

      return BoxResource({
        event: {},
        trigger: trigger,
        initial: true,
        components: {},
        data: {},
        nextProps: resourceProps,
        path: l.concat([], [['resources', index]])
      })
    }

    if (initial) {
      return l.map(nextProps.get.resources, (r, i) => mapResource(r, i))
    } else if (event.action == 'force-fetch-next-page') {
      return []
    } else if (event.action == 'page-loaded') {
      if (event.currentRequestSeriesId === data.currentRequestSeriesId) {
        return l.concat(
          l.map(components.resources, rs => mapResourceState(rs)),
          l.map(event.resources, (r, i) => mapResource(r, components.resources.length + i))
        )
      } else {
        // ignore newly loaded resources when they come from an expired request series
        // (e.g. when sorting was changed while resources where still loading)
        return l.map(components.resources, rs => mapResourceState(rs))
      }
    } else {
      return l.map(components.resources, rs => mapResourceState(rs))
    }
  }

  return next()
}
