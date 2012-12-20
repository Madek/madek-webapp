jQuery ()->

  $.datepicker.setDefaults
    closeText: "schliessen"
    prevText: '&lt;'
    nextText: '&gt;'
    currentText: "Heute"
    monthNames: ["Januar", "Februar", 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember']
    monthNamesShort: ['Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez']
    dayNames: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag']
    dayNamesShort: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa']
    dayNamesMin: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa']
    weekHeader: 'Wo'
    dateFormat: "dd.mm.yy"
    firstDay: 1
    isRTL: false
    showMonthAfterYear: false
    yearSuffix: ''