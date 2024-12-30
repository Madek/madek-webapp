import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.coffee'
import BoxBatchTextInput from './BoxBatchTextInput.js'
import BoxBatchTextDateInput from './BoxBatchTextDateInput.js'
import BoxBatchKeywords from './BoxBatchKeywords.js'
import BoxBatchPeople from './BoxBatchPeople.js'
import BoxBatchLoadMetaMetaData from './BoxBatchLoadMetaMetaData.js'
import BoxRedux from './BoxRedux.js'
import BoxStateApplyMetaData from './BoxStateApplyMetaData.js'


module.exports = (merged) => {

  if(merged.initial) {
    return []
  }

  var validateForm = (f) => {

    var validateText = () => {
      return !l.isEmpty(f.data.text)
    }

    var validateKeywords = () => {
      return !l.isEmpty(f.data.keywords)
    }

    var decideValidation = (type) => {
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
    (mkf) => mkf.event.action != 'close' && !validateForm(mkf)
  )
}
