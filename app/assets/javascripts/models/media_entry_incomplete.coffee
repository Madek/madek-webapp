class MediaEntryIncomplete

  constructor: (data)->
    for k,v of data
      @[k] = v
    @

  delete: (callback)->
    $.ajax
      url: "/import.json"
      type: "DELETE"
      data:
        media_entry_incomplete: 
          id: @id
      success: =>
        do callback if callback?

window.App.MediaEntryIncomplete = MediaEntryIncomplete