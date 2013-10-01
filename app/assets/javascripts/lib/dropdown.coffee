###

Workaround for making Bootstrap dropdowns work in Chrome.

###

jQuery -> 
  $('.dropdown-menu').on 'touchstart.dropdown.data-api', (e) -> e.stopPropagation()

  $("*:not(.ui-dropup) > .dropdown-toggle").on "click", (e)->
    target = $(e.currentTarget)
    dropdown = target.closest ".dropdown"
    dropdownMenu = dropdown.find ".dropdown-menu"
    if (dropdown.offset().top-$(window).scrollTop()+dropdown.height()+dropdownMenu.height()) > $(window).height()
      dropdownMenu.css "top", "auto"
      dropdownMenu.css "bottom", "100%"
    else
      dropdownMenu.css "top", "100%"
      dropdownMenu.css "bottom", "auto"

