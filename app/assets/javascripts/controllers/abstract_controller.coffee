###

Abstract

###

class AbstractController

  constructor: (options)->
    @abstractContainer = options.abstractContainer
    do @delegateEvents

  delegateEvents: ->
    terms = '[data-ui-role="meta_term"] a'
    
    @abstractContainer.on "mouseenter", terms, (e)=>
      target = $(e.currentTarget)
      
      if target.data('term-count') == 0 then return false
      
      if target.data('popover')?
        target.popover "show"
      else
        @loadPreview target

  loadPreview: (target)->
    
    filter = {meta_data: {}}
    filter.meta_data[target.data("meta-datum-name")] = {ids: [target.data("term-id")]}
    App.MediaResource.fetch 
      meta_data: filter.meta_data
      per_page: 3
    , (media_resources, response)=>
      content = App.render("abstracts/preview", {mediaResources: media_resources, total: response.pagination.total})
      target.popover
        trigger: "hover"
        placement: "top"
        html: true
        content: content
        animation: false
        viewport: { selector: 'body', padding: 10 }
      target.popover "show" if target.is ":hover"

window.App.AbstractController = AbstractController
