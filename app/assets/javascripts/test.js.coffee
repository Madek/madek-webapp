#= require_self
#= require_tree ./test
#
window.Test=
  Visualization: {}

$ -> 
  # enable autocomplete in browsers wo focus, i.e. headless ones
  # you need to trigger change manually
  $(document).on "change", "input.ui-autocomplete-input", ->
    $(this).autocomplete("search",$(this).val())

