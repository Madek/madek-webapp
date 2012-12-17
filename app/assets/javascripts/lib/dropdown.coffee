###

Workaround for making Bootstrap dropdowns work in Chrome.

###

jQuery -> $('.dropdown-menu').on 'touchstart.dropdown.data-api', (e) -> e.stopPropagation()