import React from 'react'
import ReactDOM from 'react-dom'
import f from 'lodash'
import BoxTitlebarRender from './BoxTitlebarRender.jsx'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'
import Modal from '../ui-components/Modal.cjsx'
import EditTransferResponsibility from '../views/Shared/EditTransferResponsibility.cjsx'

class BoxTransfer extends React.Component {

  constructor(props) {
    super(props)
  }


  render() {

    var transferResources = this.props.transferResources

    var resource_ids = f.map(transferResources, 'uuid')

    var responsible = transferResources[0].responsible
    var batch_type = transferResources[0].type

    return (
      <Modal widthInPixel={800}>
        <EditTransferResponsibility
          authToken={this.props.authToken}
          batch={true}
          resourceType={batch_type}
          singleResource={null}
          batchResourceIds={resource_ids}
          batchActionUrls={this.props.actionUrls}
          responsible={responsible}
          onClose={this.props.onClose}
          onSaved={this.props.onSaved} />
      </Modal>
    )
  }
}

module.exports = BoxTransfer
