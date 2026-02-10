import React from 'react'

// This is just a wrapper around PageHader.js in order to map `children` to `actions` prop
import PageHeader from '../ui-components/PageHeader.jsx'

const PageContentHeader = ({ icon, title, children, banner, sectionLabels }) => {
  return (
    <PageHeader
      icon={icon}
      title={title}
      actions={children}
      banner={banner}
      sectionLabels={sectionLabels}
    />
  )
}

export default PageContentHeader
module.exports = PageContentHeader
