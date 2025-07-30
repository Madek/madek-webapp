import { fetchPage, fetchListMetadata } from './dataFetchers.js'

function nextState({ state = {}, context = {}, event, triggerEvent }) {
  // Dispatch page load
  if (event.action == 'load-next-page' && !state.loadingNextPage) {
    const currentPage = event.clear ? 0 : Math.ceil(state.resourceStates.length / context.pageSize)

    fetchPage({
      currentUrl: context.currentUrl,
      sparsePath: context.getJsonPath(),
      page: currentPage + 1,
      onFetched: ({ success, resources }) => {
        triggerEvent({
          action: success ? 'page-loaded' : 'page-load-failed',
          currentRequestSeriesId: state.currentRequestSeriesId,
          resources
        })
      }
    })
  }

  // Dispatch list metadata loading
  const resourceStates = (function () {
    if (
      context.layout === 'list' &&
      ['load-list-metadata', 'page-loaded', 'load-list-metadata-success'].includes(event.action)
    ) {
      // fetch up to 6 resource's metadata in parallel
      const alreadyLoadingCount = state.resourceStates.filter(rs => rs.loadingListMetadata).length
      const skip = alreadyLoadingCount > 1
      const uuidsToLoadFor = skip
        ? []
        : state.resourceStates
            .filter(rs => !rs.listMetadata && !rs.loadingListMetadata)
            .slice(0, 6)
            .map(rs => {
              fetchListMetadata({
                resourceUrl: rs.resource.list_meta_data_url,
                onFetched: ({ success, json }) => {
                  triggerEvent({
                    action: success ? 'load-list-metadata-success' : 'load-list-metadata-failure',
                    resource: rs.resource,
                    json
                  })
                }
              })
              return rs.resource.uuid
            })

      return state.resourceStates.map(rs =>
        uuidsToLoadFor.includes(rs.resource.uuid) ? { ...rs, loadingListMetadata: true } : rs
      )
    } else {
      return state.resourceStates
    }
  })()

  const reducers = {
    ['init']: () => ({
      resourceStates: event.resources.map(resource => ({
        resource,
        listMetadata: resource.list_meta_data
      })),
      loadingNextPage: false,
      selectedResources: [],
      currentRequestSeriesId: Math.random()
    }),
    ['mount']: () => ({
      ...state,
      selectedResources: []
    }),

    // lazy page loading
    'load-next-page': () => ({
      ...state,
      loadingNextPage: true,
      resourceStates: event.clear ? [] : resourceStates,
      currentRequestSeriesId: event.clear ? Math.random() : state.currentRequestSeriesId
    }),
    'page-loaded': () => ({
      ...state,
      loadingNextPage: false,
      resourceStates: [].concat(
        resourceStates,
        event.currentRequestSeriesId === state.currentRequestSeriesId
          ? event.resources.map(resource => ({ resource, listMetadata: resource.list_meta_data }))
          : []
      )
    }),
    'page-load-failed': () => ({ ...state, loadingListMetadata: false }),

    // selection
    'toggle-resource-selection': () => {
      return {
        ...state,
        selectedResources: (function () {
          if (state.selectedResources.find(sr => sr.uuid === event.resourceUuid)) {
            return state.selectedResources.filter(sr => sr.uuid !== event.resourceUuid)
          } else {
            return [].concat(
              state.selectedResources,
              resourceStates.find(rs => rs.resource.uuid === event.resourceUuid).resource
            )
          }
        })()
      }
    },
    'select-resources': () => {
      return {
        ...state,
        selectedResources: (function () {
          return [].concat(
            state.selectedResources,
            event.resourceUuids.map(
              rid => resourceStates.find(rs => rs.resource.uuid === rid).resource
            )
          )
        })()
      }
    },
    'unselect-resources': () => ({
      ...state,
      selectedResources: state.selectedResources.filter(
        sr => !event.resourceUuids.includes(sr.uuid)
      )
    }),

    // list metadata fetching
    'load-list-metadata': () => ({ ...state, resourceStates: resourceStates }),
    'load-list-metadata-success': () => ({
      ...state,
      resourceStates: resourceStates.map(rs => {
        return rs.resource.uuid === event.resource.uuid
          ? {
              ...rs,
              listMetadata: event.json,
              loadingListMetadata: false
            }
          : rs
      })
    }),
    'load-list-metadata-failure': () => ({
      ...state,
      resourceStates: resourceStates.map(rs => {
        return rs.resource.uuid === event.resource.uuid
          ? {
              ...rs,
              loadingListMetadata: false
            }
          : rs
      })
    })
  }

  const reduce = reducers[event.action]
  if (!reduce) {
    throw new Error(`unexpected action ${event.action}`)
  }
  return reduce()
}

module.exports = { nextState }
