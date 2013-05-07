###

FilterSets

Controller for FilterSets

###

class FilterSetsController

  @create: ->
    dialog = App.render "filter_sets/create_dialog"
    form = dialog.find "form"
    form.bind "submit", (e)-> 
      e.preventDefault()
      filterSet = App.FilterSet.fromForm form
      filterSet["filter"] = App.MediaResourcesController.Index.current.getCurrentFilter()
      if filterSet.validate()
        dialog.remove()
        $(filterSet).bind "created", -> window.location = "/filter_sets/#{filterSet.id}"
        filterSet.create()
      else
        App.DialogErrors.set form, filterSet.errors
      return false
    new App.Modal dialog

  @update: ->
    new App.Modal $("<div></div>")
    do App.BrowserLoadingIndicator.start
    filterSet = new App.FilterSet $(".app.edit-filter-set").data()
    filterSet["filter"] = App.MediaResourcesController.Index.current.getCurrentFilter()
    filterSet.update ->
      window.location = "/filter_sets/#{filterSet.id}"

window.App.FilterSetsController = FilterSetsController

jQuery ->
  $("[data-create-filter-set]").bind "click", -> do FilterSetsController.create
  $("[data-update-filter-set]").bind "click", -> do FilterSetsController.update
