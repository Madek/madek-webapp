import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'

module.exports = {

  allowedLayoutModes(disableListMode) {
    return [
      {mode: 'tiles', title: t('layout_mode_tiles'), icon: 'vis-pins'},
      {mode: 'grid', title: t('layout_mode_grid'), icon: 'vis-grid'}
    ].concat(
      (
        !disableListMode ?
          [
            {mode: 'list', title: t('layout_mode_list'), icon: 'vis-list'}
          ]
        :
          []
      )
    ).concat(
      {mode: 'miniature', title: t('layout_mode_miniature'), icon: 'vis-miniature'}
    )
  },

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
