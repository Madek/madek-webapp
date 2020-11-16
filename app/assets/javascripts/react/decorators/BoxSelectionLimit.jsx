import React from 'react'
import ReactDOM from 'react-dom'
import f from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import boxSetUrlParams from './BoxSetUrlParams.jsx'
import Modal from '../ui-components/Modal.cjsx'

class BoxSelectionLimit extends React.Component {

  constructor(props) {
    super(props)
  }


  renderText() {
    if(this.props.showSelectionLimit == 'page-selection') {
      return t('resources_box_selection_limit_page_1') + this.props.selectionLimit + t('resources_box_selection_limit_page_2')
    }
    else if(this.props.showSelectionLimit == 'single-selection') {
      return t('resources_box_selection_limit_single_1') + this.props.selectionLimit + t('resources_box_selection_limit_single_2')
    }
    else {
      throw new Error('Unexpected show selection limit: ' + this.props.showSelectionLimit)
    }
  }

  render() {
    return (
      <Modal widthInPixel={400}>
        <div style={{margin: '20px', marginBottom: '20px', textAlign: 'center'}}>
          {this.renderText()}
        </div>
        <div style={{margin: '20px', marginBottom: '20px', textAlign: 'center'}}>
          <div className="ui-actions">
            <a onClick={this.props.onClose} className="primary-button">{t('resources_box_selection_limit_ok')}</a>
          </div>
        </div>
      </Modal>
    )
  }
}

module.exports = BoxSelectionLimit
