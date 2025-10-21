import React from 'react'
import t from '../../lib/i18n-translate.js'
import Modal from '../ui-components/Modal.jsx'

const BoxSelectionLimit = ({ showSelectionLimit, selectionLimit, onClose }) => {
  const renderText = () => {
    if (showSelectionLimit === 'page-selection') {
      return (
        t('resources_box_selection_limit_page_1') +
        selectionLimit +
        t('resources_box_selection_limit_page_2')
      )
    } else if (showSelectionLimit === 'single-selection') {
      return (
        t('resources_box_selection_limit_single_1') +
        selectionLimit +
        t('resources_box_selection_limit_single_2')
      )
    } else {
      throw new Error('Unexpected show selection limit: ' + showSelectionLimit)
    }
  }

  return (
    <Modal widthInPixel={400}>
      <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>
        {renderText()}
      </div>
      <div style={{ margin: '20px', marginBottom: '20px', textAlign: 'center' }}>
        <div className="ui-actions">
          <a onClick={onClose} className="primary-button">
            {t('resources_box_selection_limit_ok')}
          </a>
        </div>
      </div>
    </Modal>
  )
}

export default BoxSelectionLimit
module.exports = BoxSelectionLimit
