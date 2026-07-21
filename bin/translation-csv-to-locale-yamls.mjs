#!/usr/bin/env node
import path from 'node:path'
import fs from 'fs-extra'
import { map, extend, merge, set, each } from 'lodash-es'
import YAML from 'js-yaml'
import parseTranslationsFromCSV from '../app/javascript/lib/parse-translations-from-csv.js'

const CONFIG = {
  translationFile: './config/locale/translations.csv',
  outputDir: './public/assets/_rails_locales',
  // NOTE: we still keep some rails stuff around, to be removed.
  localePresetsDir: './config/locale'
}

// merges translations with presets
const mergeTranslationsWithPresets = (locales, presetsDir) => {
  return map(locales, item => {
    const presetFile = path.join(presetsDir, `${item.lang}.yml`)
    const presetContent = YAML.load(fs.readFileSync(presetFile).toString())
    return extend(item, {
      mapping: merge(presetContent, set({}, item.lang, item.mapping))
    })
  })
}

// writes translations to Rails' locale files (YAML)
const writeToLocaleFiles = (locales, outputDir) => {
  each(locales, item => {
    const outputFile = path.join(outputDir, `${item.lang}.yml`)
    const text = YAML.dump(item.mapping)
    try {
      fs.outputFileSync(outputFile, text, 'utf8')
    } catch (err) {
      throw new Error(`Can't write file '${outputFile}'!`, err)
    }
  })
}

// main ///////////////////////////////////////////////////////////////////////////

// reads CSV and returns list like: `[{lang: 'en', mapping: {key: 'value'}}, …]`
const text = fs.readFileSync(CONFIG.translationFile, 'utf8')
const translations = parseTranslationsFromCSV(text, CONFIG.ignoreColumns)

const locales = mergeTranslationsWithPresets(translations, CONFIG.localePresetsDir)

writeToLocaleFiles(locales, CONFIG.outputDir)

console.error('=> Building translations… OK!', {
  languages: map(locales, 'lang'),
  translationsCount: Object.keys(translations[0].mapping).length
})
