/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Box for search result pages, allows switching the *route*!

const React = require('react')
const f = require('active-lodash')
const ui = require('../lib/ui.js')
const { t } = ui
const parseUrl = require('url').parse
const stringifyUrl = require('url').format
const parseQuery = require('qs').parse

const Button = require('../ui-components/Button.jsx')
const ButtonGroup = require('../ui-components/ButtonGroup.jsx')
const ResourcesBox = require('../decorators/MediaResourcesBox.jsx')
const { boxSetUrlParams } = ResourcesBox

const TYPES = ['entries', 'sets'] // see `typeBbtns`, types are defined there

module.exports = React.createClass({
  displayName: 'ResourcesBoxWithSwitch',
  propTypes: {
    switches: React.PropTypes.shape({
      currentType: React.PropTypes.oneOf(TYPES),
      otherTypes: React.PropTypes.arrayOf(React.PropTypes.oneOf(TYPES))
    }),
    for_url: React.PropTypes.string.isRequired,
    // all other props are just passed through to ResourcesBox:
    get: React.PropTypes.object.isRequired
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
                {...Object.assign({}, btn, {
                  href: urlByType(boxUrl, currentType, btn.key),
                  mods: isActive ? 'active' : undefined
                })}>
                {btn.name}
              </Button>
            )
          })}
        </ButtonGroup>
      )
    }

    return (
      <ResourcesBox
        {...Object.assign({}, props, {
          resourceTypeSwitcherConfig: { customRenderer: renderSwitcher }
        })}
      />
    )
  }
})

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
          // eslint-disable-next-line no-empty
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

  return boxSetUrlParams(
    currentUrl.pathname.replace(RegExp(`/${currentType}$`), `/${newType}`),
    newParams
  )
}
