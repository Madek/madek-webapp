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

class BoxTitlebarRender extends React.Component {

  constructor(props) {
    super(props)
  }

  render({heading, centerActions, layouts, mods, onSortItemClick, dropdownItems, selectedSort, enableOrdering} = this.props) {
    var style = {minHeight: '1px'} // Make sure col2of6 fills its space (min height ensures that following float left are blocked)

    var classes = cx('ui-container inverted ui-toolbar pvx', mods)
    style = {minHeight: '1px'} // Make sure col2of6 fills its space (min height ensures that following float left are blocked)

    var renderCenterActions = () => {
      if(f.isEmpty(centerActions)) {
        return null
      }

      return (
        <ButtonGroup mods='tertiary small center mls'>
          {centerActions}
        </ButtonGroup>
      )
    }

    var renderOrdering = () => {
      if(!enableOrdering) {
        return null
      }

      return (
        <SortDropdown items={dropdownItems} selectedKey={selectedSort}
          onItemClick={onSortItemClick} />
      )
    }

    return (

      <div className={classes}>
        <h2 className='ui-toolbar-header pls col2of6' style={style}>{heading}</h2>
        <div className='col2of6' style={{textAlign: 'center'}}>
          {/* Action Buttons: */}
          {renderCenterActions()}
        </div>
        <div className='ui-toolbar-controls by-right'> {/* removed col2of6 because of minimum width */}
          {/* Layout Switcher: */}
          <ButtonGroup mods='tertiary small right mls'>
            {
              layouts.map((layout) => {
                var mods = cx('small', 'ui-toolbar-vis-button', layout.mods)
                return (
                  <Button
                    mode={layout.mode} title={layout.title} icon={layout.icon}
                    href={layout.href} onClick={layout.onClick}
                    mods={mods} key={layout.mode}>
                    <Icon i={layout.icon} title={layout.title}/>
                  </Button>
                )
              })
            }
          </ButtonGroup>
          {renderOrdering()}
        </div>
      </div>
    )

  }
}

module.exports = BoxTitlebarRender
