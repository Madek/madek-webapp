import React from 'react'

const ExploreMenu = ({ children }) => {
  return (
    <div className="app-body-sidebar bright ui-container table-cell bordered-right rounded-bottom-left table-side">
      <div className="ui-container rounded-left phm pvl">
        <ul className="ui-side-navigation">
          {children.map((child, index) => {
            const list = []
            const separator = <li key={`separator_${index}`} className="separator mini" />
            if (index > 0) {
              list.push(separator)
            }
            list.push(child)
            return list
          })}
        </ul>
      </div>
    </div>
  )
}

export default ExploreMenu
module.exports = ExploreMenu
