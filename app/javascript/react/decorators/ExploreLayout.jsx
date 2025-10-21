import React from 'react'

const ExploreLayout = ({ sections }) => {
  return (
    <div>
      <div className="app-body-ui-container pts context-home" style={{ width: '1000px' }}>
        <a className="strong" style={{ position: 'relative', top: '20px' }} href="/explore">
          Zurück
        </a>
        {sections.map((section, index) => {
          const list = []
          const separator = <hr key={`separator_${index}`} className="separator" />
          if (index > 0) {
            list.push(separator)
          }
          list.push(section)
          return list
        })}
      </div>
    </div>
  )
}

export default ExploreLayout
module.exports = ExploreLayout
