import React from 'react'
import MetaDataList from '../../decorators/MetaDataList.jsx'
import ResourceShowOverview from '../../templates/ResourceShowOverview.jsx'
import SimpleResourceThumbnail from '../../decorators/SimpleResourceThumbnail.jsx'

const CollectionDetailOverview = ({ get }) => {
  const summary_context = get.action === 'show' ? get.summary_meta_data : get.context_meta_data

  const overview = {
    content: (
      <MetaDataList list={summary_context} type="table" showTitle={false} showFallback={true} />
    ),
    preview: (
      <div className="ui-set-preview">
        <SimpleResourceThumbnail
          type={get.type}
          title={get.title}
          authors_pretty={get.authors_pretty}
          image_url={get.image_url}
        />
      </div>
    )
  }

  return (
    <div className="bright  pal rounded-top-right ui-container">
      <ResourceShowOverview {...overview} />
    </div>
  )
}

export default CollectionDetailOverview
module.exports = CollectionDetailOverview
