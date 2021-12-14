React = require('react')
MetaDataList = require('../../decorators/MetaDataList.cjsx')
ResourceShowOverview = require('../../templates/ResourceShowOverview.cjsx')
SimpleResourceThumbnail = require('../../decorators/SimpleResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'CollectionDetailOverview'

  render: ({authToken, get} = @props) ->
    summary_context = switch get.action
                      when 'show' then get.summary_meta_data
                      when 'context' then get.context_meta_data

    overview =
      content: <MetaDataList list={summary_context}
                type='table' showTitle={false} showFallback={true}/>
      preview: (
        <div className='ui-set-preview'>
          <SimpleResourceThumbnail type={get.type} title={get.title}
            authors_pretty={get.authors_pretty} image_url={get.image_url} />
        </div>
      )

    <div className="bright  pal rounded-top-right ui-container">
      <ResourceShowOverview {...overview}/>
    </div>
