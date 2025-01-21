import React from 'react'
import Button from '../ui-components/Button.jsx'
import cx from 'classnames/dedupe'
import Icon from '../ui-components/Icon.jsx'

class BoxLayoutButton extends React.Component {
  constructor(props) {
    super(props)
  }

  onClick(event) {
    this.props.onLayoutClick(event, this.props.layout)
  }

  render({ layout } = this.props) {
    var mods = cx('small', 'ui-toolbar-vis-button', layout.mods)
    return (
      <Button
        mode={layout.mode}
        title={layout.title}
        icon={layout.icon}
        href={layout.href}
        onClick={e => this.onClick(e)}
        mods={mods}
        key={layout.mode}>
        <Icon i={layout.icon} title={layout.title} />
      </Button>
    )
  }
}

module.exports = BoxLayoutButton
