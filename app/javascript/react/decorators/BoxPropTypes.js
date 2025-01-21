import PropTypes from 'prop-types'
import { pick } from 'active-lodash'

module.exports = {
  filterConfigProps() {
    return PropTypes.shape({
      search: PropTypes.string,
      meta_data: PropTypes.arrayOf(
        PropTypes.shape({
          key: PropTypes.string.isRequired,
          match: PropTypes.string,
          value: PropTypes.string,
          type: PropTypes.string // must be sub-type of MetaDatum
        })
      ),
      media_file: PropTypes.arrayOf(
        PropTypes.shape({
          key: PropTypes.string.isRequired,
          value: PropTypes.string
        })
      ),
      permissions: PropTypes.arrayOf(
        PropTypes.shape({
          key: PropTypes.string.isRequired,
          value: PropTypes.oneOfType([PropTypes.string, PropTypes.bool])
        })
      )
    })
  },

  viewConfigProps() {
    // view Config - bound to the URL (params)!
    return {
      show_filter: PropTypes.bool,
      filter: this.filterConfigProps(),
      layout: PropTypes.oneOf(['tiles', 'miniature', 'grid', 'list']),
      pagination: PropTypes.shape({
        prev: PropTypes.shape({
          page: PropTypes.number.isRequired
        }),
        next: PropTypes.shape({
          page: PropTypes.number.isRequired
        })
      }),
      for_url: PropTypes.shape({
        pathname: PropTypes.string.isRequired,
        query: PropTypes.object
      })
    }
  },

  propTypes() {
    var viewConfigProps = this.viewConfigProps()
    return {
      initial: PropTypes.shape(viewConfigProps),
      fallback: PropTypes.oneOfType([PropTypes.bool, PropTypes.node]),
      heading: PropTypes.node,
      // toolBarMiddle: PropTypes.node,
      authToken: PropTypes.string.isRequired,
      draftsView: PropTypes.bool,
      disableListMode: PropTypes.bool,
      showAddSetButton: PropTypes.bool,
      get: PropTypes.shape({
        type: PropTypes.oneOf(['MediaEntries', 'Collections', 'MediaResources']),
        has_user: PropTypes.bool, // toggles actions, hover, flyout
        can_filter: PropTypes.bool, // if true, get.resources can be filtered
        config: PropTypes.shape(viewConfigProps), // <- config that is part of the URL!
        user_config: PropTypes.shape(pick(viewConfigProps, 'layout', 'order', 'show_filter')) // <- subset that is *also* stored per session
      })
    }
  }
}
