import l from 'lodash'
import BoxResource from './BoxResource.js'
import BoxStatePrecalculate from './BoxStatePrecalculate.js'
import BoxStateFetchNextPage from './BoxStateFetchNextPage.js'

module.exports = merged => {
  const { event, trigger, initial, components, data, nextProps, path } = merged
  const { willFetch, todoLoadMetaData } = BoxStatePrecalculate(merged)

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
        resources: nextResources()
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

  const nextResources = () => {
    const nextResourceProps = resource => {
      return {
        resource: resource,
        loadMetaData: todoLoadMetaData[resource.uuid] ? true : false,
        thumbnailMetaData: null,
        resetListMetaData: false
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
