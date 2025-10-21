import React from 'react'

const TabContent = ({ testId, children }) => {
  return (
    <div
      className="ui-container tab-content bordered bright rounded-right rounded-bottom"
      data-test-id={testId}>
      {children}
    </div>
  )
}

export default TabContent
module.exports = TabContent
