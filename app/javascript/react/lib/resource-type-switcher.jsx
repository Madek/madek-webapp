/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('active-lodash')
const parseUrl = require('url').parse
const stringifyUrl = require('url').format
const parseQuery = require('qs').parse
const t = require('../../lib/i18n-translate.js')
const setUrlParams = require('../../lib/set-params-for-url.js')
const libUrl = require('url')
const qs = require('qs')
const Button = require('../ui-components/Button.jsx')
const ButtonGroup = require('../ui-components/ButtonGroup.jsx')

const resourceTypeSwitcher = function(forUrl, defaultType, showAll, onClick) {
  const currentType = qs.parse(libUrl.parse(forUrl).query).type || defaultType
  const typeBbtns = f.compact([
    showAll ? { key: 'all', name: t('resources_type_all') } : undefined,
    { key: 'entries', name: t('sitemap_entries') },
    { key: 'collections', name: t('sitemap_collections') }
  ])

  return (
    <ButtonGroup data-test-id="resource-type-switcher">
      {typeBbtns.map(btn => {
        const isCurrent = currentType === btn.key
        const isDefault = !currentType
          ? showAll
            ? btn.key === 'all'
            : btn.key === 'entries'
          : undefined
        const isActive = isCurrent || isDefault

        const btnUrl = urlByType(forUrl, currentType, btn.key)

        return (
          <Button
            {...Object.assign({}, btn, {
              onClick: onClick,
              href: btnUrl,
              mods: isActive ? 'active' : undefined
            })}>
            {btn.name}
          </Button>
        )
      })}
    </ButtonGroup>
  )
}

var urlByType = function(url, currentType, newType) {
  if (currentType === newType) {
    return url
  }

  const currentUrl = parseUrl(url)
  const currentParams = parseQuery(currentUrl.query)

  const newParams = f.cloneDeep(currentParams)
  if (newParams.list) {
    if (newParams.list.accordion) {
      newParams.list.accordion = {}
    }

    if (newParams.list.filter) {
      const parsed = (() => {
        try {
          return JSON.parse(newParams.list.filter)
        } catch (error) {}
      })()
      if (parsed) {
        newParams.list.filter = JSON.stringify({ search: parsed.search })
      } else {
        newParams.list.filter = JSON.stringify({})
      }
    }

    newParams.list.page = 1
  }

  return setUrlParams(currentUrl, { list: newParams.list }, { type: newType })
}

module.exports = {
  resourceTypeSwitcher,
  urlByType
}
