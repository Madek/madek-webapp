import React from 'react'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import f from 'active-lodash'

module.exports = {

  filterConfigProps() {
    return React.PropTypes.shape({
      search: React.PropTypes.string,
      meta_data: React.PropTypes.arrayOf(React.PropTypes.shape({
        key: React.PropTypes.string.isRequired,
        match: React.PropTypes.string,
        value: React.PropTypes.string,
        type: React.PropTypes.string // must be sub-type of MetaDatum
      })),
      media_file: React.PropTypes.arrayOf(React.PropTypes.shape({
        key: React.PropTypes.string.isRequired,
        value: React.PropTypes.string
      })),
      permissions: React.PropTypes.arrayOf(React.PropTypes.shape({
        key: React.PropTypes.string.isRequired,
        value: React.PropTypes.oneOfType([React.PropTypes.string, React.PropTypes.bool])
      }))
    });
  },

  viewConfigProps() {
    // view Config - bound to the URL (params)!
    return {
      show_filter: React.PropTypes.bool,
      filter: this.filterConfigProps(),
      layout: React.PropTypes.oneOf(['tiles', 'miniature', 'grid', 'list']),
      pagination: React.PropTypes.shape({
        prev: React.PropTypes.shape({
          page: React.PropTypes.number.isRequired
        }),
        next: React.PropTypes.shape({
          page: React.PropTypes.number.isRequired
        })
      }),
      for_url: React.PropTypes.shape({
        pathname: React.PropTypes.string.isRequired,
        query: React.PropTypes.object
      })
    }
  },

  propTypes() {

    var viewConfigProps = this.viewConfigProps()
    return {
      initial: React.PropTypes.shape(viewConfigProps),
      fallback: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.node]),
      heading: React.PropTypes.node,
      // toolBarMiddle: React.PropTypes.node,
      authToken: React.PropTypes.string.isRequired,
      draftsView: React.PropTypes.bool,
      disableListMode: React.PropTypes.bool,
      get: React.PropTypes.shape({
        // resources: React.PropTypes.array # TODO: array of ampersandCollection
        type: React.PropTypes.oneOf(['MediaEntries', 'Collections', 'FilterSets', 'MediaResources']),
        has_user: React.PropTypes.bool, // toggles actions, hover, flyout
        can_filter: React.PropTypes.bool, // if true, get.resources can be filtered
        config: React.PropTypes.shape(viewConfigProps), // <- config that is part of the URL!
        user_config: React.PropTypes.shape(f.pick(viewConfigProps, 'layout', 'order', 'show_filter')) // <- subset that is *also* stored per session
      })
    }


  }

}
