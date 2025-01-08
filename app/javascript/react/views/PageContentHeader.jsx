/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')

// This is just a wrapper around PageHader.js in order to map `children` to `actions` prop
const PageHeader = require('../ui-components/PageHeader.js')

module.exports = React.createClass({
  displayName: 'PageContentHeader',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { icon, title, children, workflow, banner, sectionLabels } = param
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
})
