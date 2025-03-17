/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import f from 'active-lodash'
import libUrl from 'url'
import { parse as parseUrl } from 'url'
import { parse as parseQuery } from 'qs'
import t from '../../lib/i18n-translate.js'
import setUrlParams from '../../lib/set-params-for-url.js'
import qs from 'qs'
import Button from '../ui-components/Button.jsx'
import ButtonGroup from '../ui-components/ButtonGroup.jsx'

const resourceTypeSwitcher = function (forUrl, defaultType, showAll, onClick) {
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
            onClick={onClick}
            href={btnUrl}
            mods={isActive ? 'active' : undefined}
            key={btn.key}
            name={btn.name}>
            {btn.name}
          </Button>
        )
      })}
    </ButtonGroup>
  )
}

var urlByType = function (url, currentType, newType) {
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
        } catch (error) {
          // silently fallback
        }
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
