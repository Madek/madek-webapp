// NOTE: it's not only used for collections, but for media entries as well

import React from 'react'
import Modal from '../ui-components/Modal.jsx'
import SelectCollection from './Collection/SelectCollection.jsx'

const SelectCollectionModal = ({ authToken, get }) => {
  return (
    <Modal>
      <SelectCollection get={get} authToken={authToken} />
    </Modal>
  )
}

export default SelectCollectionModal
module.exports = SelectCollectionModal
