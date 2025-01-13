/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const f = require('active-lodash')
const classnames = require('classnames/dedupe')
const i18nTranslate = require('../../lib/i18n-translate.js')

const parseModsfromProps = function(param) {
  const { className, mods } = param
  return [mods, className]
}

module.exports = {
  parseMods: parseModsfromProps,
  classnames,
  cx: classnames,
  t: i18nTranslate
}
