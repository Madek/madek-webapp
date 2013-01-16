class MetaDatumPeople

  @formattedValue: (metaDatum)->
    person = new App.Person metaDatum
    person.toString()

window.App.MetaDatumPeople = MetaDatumPeople