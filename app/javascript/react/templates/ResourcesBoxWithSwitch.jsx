/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Box for search result pages, allows switching the *route*!

import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import { t } from '../lib/ui.js'
import { parse as parseUrl } from 'url'
import { parse as parseQuery } from 'qs'
import Button from '../ui-components/Button.jsx'
import ButtonGroup from '../ui-components/ButtonGroup.jsx'
import MediaResourcesBox from '../decorators/MediaResourcesBox.jsx'
import boxSetUrlParams from '../decorators/BoxSetUrlParams.jsx'

const TYPES = ['entries', 'sets'] // see `typeBbtns`, types are defined there

module.exports = createReactClass({
  displayName: 'ResourcesBoxWithSwitch',
  propTypes: {
    switches: PropTypes.shape({
      currentType: PropTypes.oneOf(TYPES),
      otherTypes: PropTypes.arrayOf(PropTypes.oneOf(TYPES))
    }),
    for_url: PropTypes.string.isRequired,
    // all other props are just passed through to ResourcesBox:
    get: PropTypes.object.isRequired
  },

  forUrl() {
    return this.props.for_url
  },

  render(props, state) {
    if (props == null) {
      ;({ props } = this)
    }
    if (state == null) {
      ;({ state } = this)
    }
    const { currentType, otherTypes } = props.switches
    const types = f.flatten([currentType, otherTypes])

    const renderSwitcher = boxUrl => {
      // NOTE: order of switches is defined here – should be consistent between views!
      const typeBbtns = f.compact([
        { key: 'entries', name: t('sitemap_entries') },
        { key: 'sets', name: t('sitemap_collections') }
      ])

      return (
        <ButtonGroup data-test-id="resource-type-switcher">
          {typeBbtns.map(btn => {
            if (!f.include(types, btn.key)) {
              return null
            } // only show mentioned types
            const isActive = btn.key === currentType // set active is current type
            return (
              <Button
                href={urlByType(boxUrl, currentType, btn.key)}
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

    return (
      <MediaResourcesBox
        {...Object.assign({}, props, {
          resourceTypeSwitcherConfig: { customRenderer: renderSwitcher }
        })}
      />
    )
  }
})

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
          // eslint-disable-next-line no-unused-vars
        } catch (e) {
          // silently fall back
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

  return boxSetUrlParams(
    currentUrl.pathname.replace(RegExp(`/${currentType}$`), `/${newType}`),
    newParams
  )
}
