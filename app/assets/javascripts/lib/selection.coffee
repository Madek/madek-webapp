f = require('lodash')

toExport =

  createEmpty: (callback) ->
    {
      selection: []

      contains: (resource) ->
        !!f.find(@selection, {uuid: resource.uuid})

      toggle: (resource) ->
        if @contains(resource)
          @remove(resource)
        else
          @add(resource)

      add: (resource) ->
        if not @contains(resource)
          @selection.push(resource)
        callback()

      empty: () ->
        f.isEmpty(@selection)

      remove: (resource) ->
        @selection = f.filter @selection, (r) ->
          r.uuid != resource.uuid
        callback()

      toggleAll: (all) ->
        if @empty()
          @selection = f.map all, (r) -> r
        else
          @selection = []
        callback()

      clear: () ->
        @selection = []
        callback()

      length: () ->
        f.size(@selection)

    }


module.exports = toExport
