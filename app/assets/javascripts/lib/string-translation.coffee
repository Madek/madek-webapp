f = require('active-lodash')

translations = f.merge(
  require('../../../../locale/en.yml'),
  require('../../../../locale/de.yml'))

module.exports = tFactory = (lang)->
  if not f.any(f.keys(translations), ((l)-> l is lang))
    throw new Error 'Unknown language!'

  t = (marker)->
    f(translations[lang][marker]).presence() or "⟨#{marker}⟩"
