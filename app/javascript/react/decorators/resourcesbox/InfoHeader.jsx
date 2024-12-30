import React from 'react'
import t from '../../../lib/i18n-translate.js'
import interpolateSplit from '../../../lib/interpolate-split.js'

class InfoHeader extends React.Component {
  constructor(props) {
    super(props)

    const renderFuncs = {
      entrustment: this._renderEntrustedResourcesInfo
    }
    this.renderFunc =
      renderFuncs[props.type] || (() => <div>No render func for type {props.type}</div>)
  }

  render() {
    return <div>{this.renderFunc(this.props)}</div>
  }

  _renderEntrustedResourcesInfo({ authentication_group_names, groups_url }) {
    return (
      <div>
        {interpolateSplit(t('resources_box_info_header_no_system_groups'), {
          system_groups_name: (
            <a
              href={groups_url}
              title={
                t('resources_box_info_header_system_groups_name') +
                ': ' +
                authentication_group_names.join(', ')
              }
              key="system_groups_name">
              {t('resources_box_info_header_system_groups_name')}
            </a>
          )
        })}
      </div>
    )
  }
}

export default InfoHeader
