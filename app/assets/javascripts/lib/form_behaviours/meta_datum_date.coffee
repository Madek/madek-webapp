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
    # for datepicker in @el.find(".ui-form-group[data-type='meta_datum_date'] input.ui-datepicker")
    #   do (datepicker) =>
    #     self = @
    #     datepicker = $(datepicker)
    #     datepicker...
    #       onSelect: -> self.setDate this.getDate(), datepicker

  setDate: (date, datepicker)->
    formGroup = datepicker.closest ".ui-form-group"

    # SET FREE INPUT
    if datepicker.is ".input-on"
      formGroup.find("input.input-free").val date
    else if datepicker.is ".input-from" or datepicker.is ".input-to"
      formGroup.find("input.input-free").val "#{formGroup.find("input.input-from").val()} - #{formGroup.find("input.input-to").val()}"

    # SET OTHER DATEPICKERS
    if datepicker.is ".input-on"
      formGroup.find("input.input-from").val date
    else if datepicker.is ".input-from"
      formGroup.find("input.input-on").val date

  delegateEvents: ->
    @el.on "change", ".ui-form-group[data-type='meta_datum_date'] select", (e)=> @changeInput $(e.currentTarget)

  changeInput: (select_el)->
    option = select_el.find("option:selected")
    formGroup = select_el.closest ".ui-form-group"
    formGroup.find(".form-date").hide()
    formGroup.find(".form-date#{option.data("input")}").show()
      
window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.MetaDatumDate = FormBehaviours.MetaDatumDate