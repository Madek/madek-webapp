React = require('react')
MetaDataByListing = require('../../decorators/MetaDataByListing.cjsx')

module.exports = React.createClass
  displayName: 'CollectionMetadata'

  render: ({get} = @props) ->
    <div className="bright pal rounded-bottom rounded-top-right ui-container">
      <div className="ui-container plm">
        <MetaDataByListing list={get.meta_data.by_vocabulary} />
      </div>
    </div>
