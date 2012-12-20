###

FormBehaviour for Collapsing fields of the same type that are listed in a row

###

FormBehaviours = {} unless FormBehaviours?
class FormBehaviours.Collapse

  constructor: (options)->
    @el = options.el
    do @collapse
    do @delegateEvents

  delegateEvents: ->
    @el.on "click", ".form-item-extension-toggle", (e)=> @toggle $(e.currentTarget)

  toggle: (toggle)->
    if toggle.is ".active"
      toggle.removeClass "active"
      toggle.next(".form-item-extension").hide()
    else
      toggle.addClass "active"
      toggle.next(".form-item-extension").show()

  collapse: ->  
    parent = formGroup
    children = []
    for formGroup in @el.find ".ui-form-group[data-type]"
      do (formGroup)->
        formGroup = $(formGroup)
        if not parent?
          parent = formGroup
        else if parent? and 
        (parent.data("meta-key").replace(/\s\w+$/, "") == formGroup.data("meta-key").replace(/\s\w+$/, "") or 
        parent.data("meta-key") == formGroup.data("meta-key").replace(/\s\w+$/, "") or
        parent.data("meta-key") == formGroup.data("meta-key").split(" ")[0] or
        parent.data("meta-key").split(" ")[0] == formGroup.data("meta-key").split(" ")[0])
          children.push formGroup
        else if parent? and children.length > 2
          parent.find(".form-item").append App.render "media_resources/edit/collapsed_fields"
          for child in children
            child = $(child)
            child.removeClass("columned").addClass("rowed")
            parent.find(".form-item-extension").append child
          # reset
          parent = formGroup
          children = []
        else
          # reset
          parent = formGroup
          children = []
        
window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.Collapse = FormBehaviours.Collapse