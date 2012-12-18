###

FormBehaviour for MetaDatumDate

###

FormBehaviours = {} unless FormBehaviours?
class FormBehaviours.MetaDatumDate

  constructor: (options)->
    @el = options.el
    do @setupDatepickers
    do @delegateEvents

  setupDatepickers: ->
    @el.find(".ui-form-group[data-type='meta_datum_date'] input.ui-datepicker").datepicker
      changeMonth: true
      changeYear: true
      onSelect: (date, el)=>
        @setDate date, $(el.input)

  setDate: (date, datepicker)->
    formGroup = datepicker.closest ".ui-form-group"

    # SET FREE INPUT
    if datepicker.hasClass "input-on"
      formGroup.find("input.input-free").val date
    else if datepicker.hasClass "input-from"
      formGroup.find("input.input-free").val "#{date} - #{formGroup.find("input.input-to").val()}"
    else if datepicker.hasClass "input-to"
      formGroup.find("input.input-free").val "#{formGroup.find("input.input-from").val()} - #{date}"

    # SET OTHER DATEPICKERS
    if datepicker.hasClass "input-on"
      formGroup.find("input.input-from").val date
    else if datepicker.hasClass "input-from"
      formGroup.find("input.input-on").val date

    # SET MIN DATE FOR INPUT TO
    unless datepicker.hasClass "input-to"
      formGroup.find("input.input-to").datepicker "option", "minDate", $.datepicker.parseDate $.datepicker._defaults.dateFormat, date

  delegateEvents: ->
    @el.on "change", ".ui-form-group[data-type='meta_datum_date'] select", (e)=> @changeInput $(e.currentTarget)

  changeInput: (select_el)->
    option = select_el.find("option:selected")
    formGroup = select_el.closest ".ui-form-group"
    formGroup.find(".form-date").hide()
    formGroup.find(".form-date#{option.data("input")}").show()
      
window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.MetaDatumDate = FormBehaviours.MetaDatumDate