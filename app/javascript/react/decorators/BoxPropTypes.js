import React from 'react'
import { pick } from 'active-lodash'

module.exports = {
  filterConfigProps() {
    return React.PropTypes.shape({
      search: React.PropTypes.string,
      meta_data: React.PropTypes.arrayOf(
        React.PropTypes.shape({
          key: React.PropTypes.string.isRequired,
          match: React.PropTypes.string,
          value: React.PropTypes.string,
          type: React.PropTypes.string // must be sub-type of MetaDatum
        })
      ),
      media_file: React.PropTypes.arrayOf(
        React.PropTypes.shape({
          key: React.PropTypes.string.isRequired,
          value: React.PropTypes.string
        })
      ),
      permissions: React.PropTypes.arrayOf(
        React.PropTypes.shape({
          key: React.PropTypes.string.isRequired,
          value: React.PropTypes.oneOfType([React.PropTypes.string, React.PropTypes.bool])
        })
      )
    })
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
      showAddSetButton: React.PropTypes.bool,
      get: React.PropTypes.shape({
        type: React.PropTypes.oneOf(['MediaEntries', 'Collections', 'MediaResources']),
        has_user: React.PropTypes.bool, // toggles actions, hover, flyout
        can_filter: React.PropTypes.bool, // if true, get.resources can be filtered
        config: React.PropTypes.shape(viewConfigProps), // <- config that is part of the URL!
        user_config: React.PropTypes.shape(pick(viewConfigProps, 'layout', 'order', 'show_filter')) // <- subset that is *also* stored per session
      })
    }
  }
}
