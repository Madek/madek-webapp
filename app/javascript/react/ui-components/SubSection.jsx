// Collapsible Subsection, a wrapper around <details> element
import React from 'react'

class SubSection extends React.Component {
  constructor(props) {
    super(props)
    this.toggleOpen = this.toggleOpen.bind(this)
  }
  toggleOpen(event) {
    if (this.props.isBlocked) event.preventDefault()
  }
  render({ children, startOpen } = this.props) {
    const { title, content } = splitTitleFromContent(children)
    return (
      <details className="ui-subsection" open={startOpen} onClick={this.toggleOpen}>
        {!!title && title}
        {content}
      </details>
    )
  }
}
SubSection.defaultProps = { startOpen: true, isBlocked: false }

const SubSectionTitle = ({ tag, ...props }) => {
  const Tag = tag
  return (
    <summary>
      <Tag {...props} style={{ display: 'inline-block', ...props.style }} />
    </summary>
  )
}
SubSectionTitle.displayName = 'SubSection.Title'

SubSection.Title = SubSectionTitle

export default SubSection

function splitTitleFromContent(children) {
  const { titles, content } = React.Children.toArray(children).reduce(
    (res, child) => {
      if (child.type === SubSection.Title) res.titles.push(child)
      else res.content.push(child)
      return res
    },
    { titles: [], content: [] }
  )
  if (titles.length > 1) throw new Error('Given too many titles!')
  const title = titles[0]
  return { title, content }
}
