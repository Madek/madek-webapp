###

  MediaSetArcsHighlights
  
  This script provides functionalities for selecting arcs and save them as highlights

###
      
class MediaSetArcsHighlights extends MediaSetArcsSelection
  
  constructor: (options)->
    @highlightedResourcesIds = _.map options.highlightedResources.media_resources, (resource)-> resource.id
    super
        
window.MediaSetArcsHighlights = MediaSetArcsHighlights