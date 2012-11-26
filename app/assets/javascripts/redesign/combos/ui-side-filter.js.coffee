$(document).ready ->

  # Hide Accordion Body Items on pageload

  $(".ui-accordion-body").hide()

  # Enable Accordion

  $(".ui-accordion-toggle").click ->
    $(this).toggleClass("active")
    $(this).siblings(".ui-accordion-body").slideToggle "fast"

