###

MediaResources#Edit

Controller for MediaResources Edit

###

MediaResourcesController = {} unless MediaResourcesController?
class MediaResourcesController.Edit

  el: "#edit-media-resource"

  constructor: ->
    @el = $(@el)
    new App.FormWidgets.Defaults {el: @el}
    new App.FormWidgets.Person {el: @el}
    new App.FormAutocompletes.Person {el: @el}
    new App.FormWidgets.Keywords {el: @el}
    new App.FormAutocompletes.Keywords {el: @el}
    new App.FormBehaviours.MetaDatumDate {el: @el}
    new App.FormAutocompletes.ExtensibleList {el: @el}
    new App.FormBehaviours.Collapse {el: @el}
    new App.FormBehaviours.Copyrights {el: @el}
    new App.FormAutocompletes.Departments {el: @el}
    new App.FormBehaviours.WarnOnLeave
    new App.FormBehaviours.AcceptOnlyButtonSubmit {el: @el}

window.App.MediaResourcesController = {} unless window.App.MediaResourcesController
window.App.MediaResourcesController.Edit = MediaResourcesController.Edit