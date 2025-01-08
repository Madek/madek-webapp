import React from 'react'
import f from 'lodash'
import Modal from '../ui-components/Modal.jsx'
import EditTransferResponsibility from '../views/Shared/EditTransferResponsibility.jsx'

class BoxTransfer extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    const transferResources = this.props.transferResources

    const resource_ids = f.map(transferResources, 'uuid')

    // current responsibles occuring in the list, grouped
    const responsibles = extractResponsibles(transferResources)

    const batch_type = transferResources[0].type

    return (
      <Modal widthInPixel={800}>
        <EditTransferResponsibility
          authToken={this.props.authToken}
          batch={true}
          resourceType={batch_type}
          singleResource={null}
          batchResourceIds={resource_ids}
          batchActionUrls={this.props.actionUrls}
          batchResponsibles={responsibles}
          onClose={this.props.onClose}
          onSaved={this.props.onSaved}
          currentUser={this.props.currentUser}
        />
      </Modal>
    )
  }
}

function extractResponsibles(resources) {
  // current responsibles occuring in the list, grouped
  const map = resources.reduce((acc, resource) => {
    const { responsible } = resource
    const { uuid, name } = responsible
    if (acc[uuid]) {
      acc[uuid].nofResources += 1
    } else {
      acc[uuid] = { uuid, name, nofResources: 1 }
    }
    return acc
  }, {})
  return Object.values(map).sort(r => r.name)
}

module.exports = BoxTransfer
