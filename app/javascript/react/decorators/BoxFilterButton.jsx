import React from 'react'
import ReactDOM from 'react-dom'
import f from 'active-lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import Icon from '../ui-components/Icon.cjsx'
import Button from '../ui-components/Button.cjsx'



class BoxFilterButton extends React.Component {

  constructor(props) {
    super(props)
  }

  shouldComponentUpdate(nextProps, nextState) {
    var l = require('lodash')
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  renderResetFilterLink() {
    if(this.props.resetFilterLink) {
      return this.props.resetFilterLink
    } else {
      return null
    }
  }

  render() {

    var get = this.props.get
    var config = this.props.config

    if(!get.can_filter) {
      return null
    }

    var name = t('resources_box_filter')

    return (
      <div>
        <Button data-test-id='filter-button' name={name} mods={{'active': config.show_filter}}
          href={this.props.filterToggleLink} onClick={(e) => this.props._onFilterToggle(e, !config.show_filter)}>
          <Icon i='filter' mods='small'/> {name}
        </Button>
        {this.renderResetFilterLink()}
      </div>

    )
  }
}

module.exports = BoxFilterButton
