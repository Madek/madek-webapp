#!/usr/bin/env node

import path from 'path'
import fs from 'fs'
import { fileURLToPath } from 'url'
import f from 'active-lodash'
import YAML from 'js-yaml'
import parseTranslationsFromCSV from '../app/javascript/lib/parse-translations-from-csv.js'

// ESM equivalent of __dirname
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const CONFIG = {
  translationFile: path.join(__dirname, '../config/locale/translations.csv'),
  outputDir: path.join(__dirname, '../public/assets/_rails_locales'),
  // NOTE: we still keep some rails stuff around, to be removed.
  localePresetsDir: path.join(__dirname, '../config/locale')
}

// helpers

// ensures directory exists (replacement for fs-extra's outputFileSync)
const ensureDirSync = dirPath => {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true })
  }
}

// merges translations with presets
const mergeTranslationsWithPresets = (locales, presetsDir) => {
  return f.map(locales, item => {
    let presetContent
    //try {
    const presetFile = path.join(presetsDir, `${item.lang}.yml`)
    presetContent = YAML.load(fs.readFileSync(presetFile).toString())
    //} catch (err) { throw new Error('Can not read locale YAML preset!', err) }

    return f.extend(item, {
      mapping: f.merge(presetContent, f.set({}, item.lang, item.mapping))
    })
  })
}

// writes translations to Rails' locale files (YAML)
const writeToLocaleFiles = (locales, outputDir) => {
  // Ensure output directory exists
  ensureDirSync(outputDir)

  f.each(locales, item => {
    const outputFile = path.join(outputDir, `${item.lang}.yml`)
    const text = YAML.dump(item.mapping)
    try {
      fs.writeFileSync(outputFile, text, 'utf8')
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
  languages: f.map(locales, 'lang'),
  translationsCount: Object.keys(translations[0].mapping).length
})
