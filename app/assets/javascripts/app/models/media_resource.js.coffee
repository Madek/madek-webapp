class MediaResource

  @pluralize: (type)=>
    switch type
      when "media_set" then "media_sets"
      when "filter_set" then "filter_sets"
      when "media_entry" then "media_entries"

window.App.MediaResource = MediaResource
