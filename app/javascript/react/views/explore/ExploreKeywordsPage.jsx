import React from 'react'
import Keyword from '../../ui-components/Keyword.jsx'

const ExploreKeywordsPage = ({ get }) => {
  return (
    <div>
      <div className="app-body-ui-container pts context-home">
        <h1 className="title-xl mtl mbm">{get.content.data.title}</h1>
        <div className="ui-resources-holder pal">
          <ul className="ui-tag-cloud" style={{ marginBottom: '40px' }}>
            {get.content.data.list.map((resource, n) => (
              <Keyword
                key={`key_${n}`}
                label={resource.keyword.label}
                hrefUrl={resource.keyword.url}
                count={resource.keyword.usage_count}
              />
            ))}
          </ul>
        </div>
      </div>
    </div>
  )
}

export default ExploreKeywordsPage
module.exports = ExploreKeywordsPage
