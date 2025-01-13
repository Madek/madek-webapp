import React from 'react'
import ReactDOM from 'react-dom'
import f from 'lodash'
import ResourceThumbnail from './ResourceThumbnail.jsx'
import Preloader from '../ui-components/Preloader.jsx'
import Button from '../ui-components/Button.jsx'
import Link from '../ui-components/Link.jsx'
import SideFilter from '../ui-components/ResourcesBox/SideFilter.jsx'
import RailsForm from '../lib/forms/rails-form.jsx'
import setUrlParams from '../../lib/set-params-for-url.js'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import ButtonGroup from '../ui-components/ButtonGroup.jsx'
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
