React = require('react')
Keyword = require('../ui-components/Keyword.cjsx')

module.exports = React.createClass
  displayName: 'ResourceKeyword'
  render: ({keyword, hideIcon} = @props)->
    <Keyword label={keyword.label} count={keyword.count}
      hrefUrl={keyword.url} hideIcon={hideIcon} />
