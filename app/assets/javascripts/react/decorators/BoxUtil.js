import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'

module.exports = {

  boxClasses(mods) {
    return cx(
      { // defaults first, mods last so they can override
        'ui-container': true,
        'midtone': true,
        'bordered': true,
      },
      mods,
      'ui-polybox' // but base class can't be overridden!
    )
  }

}
