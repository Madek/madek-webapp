import l from 'lodash'

module.exports = merged => {
  if (merged.initial) {
    return []
  }

  var validateForm = f => {
    var validateText = () => {
      return !l.isEmpty(f.data.text)
    }

    var validateKeywords = () => {
      return !l.isEmpty(f.data.keywords)
    }

    var decideValidation = type => {
      var mapping = {
        'MetaDatum::Text': validateText,
        'MetaDatum::TextDate': validateText,
        'MetaDatum::Keywords': validateKeywords,
        'MetaDatum::People': validateKeywords
      }
      return mapping[type]
    }

    var validator = decideValidation(f.props.metaKey.value_type)
    return validator(f)
  }

  return l.filter(
    merged.components.metaKeyForms,
    mkf => mkf.event.action != 'close' && !validateForm(mkf)
  )
}
