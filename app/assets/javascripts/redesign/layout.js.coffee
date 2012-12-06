$ ->

  # Enable pickadate.js datapicker on .ui-datepicker

  $(".ui-datepicker").pickadate
    
    # Strings
    months_full: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
    months_short: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
    weekdays_full: ["Sonntag", "Montag", "Dienstag", "Mitwoch", "Donnerstag", "Freitag", "Samstag"]
    weekdays_short: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
    month_prev: "&#9664;"
    month_next: "&#9654;"
    
    # Date format
    format: "dd.mm.yyyy"
    format_submit: false
    
    # First day of week
    first_day: 1
    
    # Month & year dropdown selectors
    month_selector: true
    year_selector: true
    
    # Calendar events
    onOpen: null
    onClose: null
    onSelect: null
    onChangeMonth: null

  # Enable Bootstrap tooltips
  
  $("body").tooltip selector: ".ui-ttip-toggle"

  # Workaround for making Bootstrap dropdowns work in Chrome.
  
  $('.dropdown-menu').on('touchstart.dropdown.data-api', (e) ->
    e.stopPropagation() )