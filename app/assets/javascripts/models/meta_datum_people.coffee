class MetaDatumPeople

  @formattedValue: (metaDatum)->
    value = []
    value.push metaDatum.firstname if metaDatum.firstname?
    value.push metaDatum.lastname if metaDatum.lastname?
    value = value.join(", ")
    value += " (#{metaDatum.pseudonym})" if metaDatum.pseudonym?
    value

window.App.MetaDatumPeople = MetaDatumPeople