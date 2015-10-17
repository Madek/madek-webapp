path = require('path')
f = require('active-lodash')

translations = f.merge(
  require('../../../../locale/en.yml'),
  require('../../../../locale/de.yml'))

module.exports = tFactory = (lang)->
  t = (marker)->
    f(translations[lang][marker]).presence() or "⟨#{marker}⟩"
