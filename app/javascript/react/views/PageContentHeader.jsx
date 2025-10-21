import React from 'react'

// This is just a wrapper around PageHader.js in order to map `children` to `actions` prop
import PageHeader from '../ui-components/PageHeader.js'

const PageContentHeader = ({ icon, title, children, workflow, banner, sectionLabels }) => {
  return (
    <PageHeader
      icon={icon}
      title={title}
      actions={children}
      workflow={workflow}
      banner={banner}
      sectionLabels={sectionLabels}
    />
  )
}

export default PageContentHeader
module.exports = PageContentHeader
