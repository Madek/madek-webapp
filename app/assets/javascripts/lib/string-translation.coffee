f = require('./fun.coffee')
translations = require('../translations.tmp.yaml')

module.exports = t = (marker)->
  f(translations[marker]).presence() or "⟨#{marker}⟩"
