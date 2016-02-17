#!/usr/bin/env node
'use strict'

const fs = require('fs')
const path = require('path')
const f = require('active-lodash')
const YAML = require('js-yaml')
const CSV = require('babyparse')

// conf
const localeDir = './locale'

// helpers
const readLocales = (dir) => {
  let result = {langs: [], strings: {}}

  f.chain(fs.readdirSync(dir))
    .filter((i) => i.match(/.yml$/)) // => [ 'de.yml', 'en.yml' ]
    .map((i) => fs.readFileSync(path.join(localeDir, i)).toString())
    .map(YAML.safeLoad) // => [{de: {…}}, {en: {…}}]
    .reduce((i, m) => f.merge(i, m)) // => {de: {…}, en: {…}}
    .tap((locales) => result.langs = f.keys(locales))
    .each((list, lang) => {
      f.each(list, (val, key) => {
        if (f.isString(val)) { // filters out rails stuff
          f.set(result.strings, [key, lang], val)
        }
      })
    })
    .run()
  return result
}

const buildTableFromLocales = (locales) => {
  const header = ['key'].concat(locales.langs)
  const list = f.map(locales.strings, (values, key) => {
    return [key].concat(f.map(locales.langs, (lang) => values[lang] || null))
  })
  return [header].concat(list)
}

// main
const locales = readLocales(localeDir)
const output = CSV.unparse(buildTableFromLocales(locales))
process.stdout.write(output)
