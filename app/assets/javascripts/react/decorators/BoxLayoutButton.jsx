import React from 'react'
import ReactDOM from 'react-dom'
import f from 'lodash'
import ResourceThumbnail from './ResourceThumbnail.cjsx'
import Preloader from '../ui-components/Preloader.cjsx'
import Button from '../ui-components/Button.cjsx'
import Link from '../ui-components/Link.cjsx'
import SideFilter from '../ui-components/ResourcesBox/SideFilter.cjsx'
import RailsForm from '../lib/forms/rails-form.cjsx'
import setUrlParams from '../../lib/set-params-for-url.coffee'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import ButtonGroup from '../ui-components/ButtonGroup.cjsx'
import Icon from '../ui-components/Icon.cjsx'
import SortDropdown from './resourcesbox/SortDropdown.cjsx'

class BoxLayoutButton extends React.Component {

  constructor(props) {
    super(props)
  }

  onClick(event) {
    this.props.onLayoutClick(event, this.props.layout)
  }

  render({layout} = this.props) {
    var mods = cx('small', 'ui-toolbar-vis-button', layout.mods)
    return (
      <Button
        mode={layout.mode} title={layout.title} icon={layout.icon}
        href={layout.href} onClick={(e) => this.onClick(e)}
        mods={mods} key={layout.mode}>
        <Icon i={layout.icon} title={layout.title}/>
      </Button>
    )

  }
}

module.exports = BoxLayoutButton
