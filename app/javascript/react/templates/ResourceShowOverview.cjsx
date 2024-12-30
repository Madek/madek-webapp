React = require('react')
f = require('active-lodash')
classList = require('classnames/dedupe')
parseMods = require('../lib/ui.coffee').parseMods

module.exports = React.createClass
  displayName: 'ResourceShowOverview'
  propTypes:
    content: React.PropTypes.node.isRequired
    preview: React.PropTypes.node
    previewLg: React.PropTypes.node

  render: ({content, preview, previewLg} = @props)->
    <div className={classList('ui-resource-overview', parseMods(@props))}>

      {# left side: the small preview (e.g. Sets)}
      {if preview
        preview
      }

      {# top box, main content (e.g. list of data about the resource)}
      {content}

      {# and on the right: the large preview (e.g. for Entry)}
      {if previewLg
        previewLg
      }
    </div>
