import React from 'react'
import ReactDOM from 'react-dom'

class BoxPopup extends React.Component {
  constructor(props) {
    super(props)
    this._boundHandleClickOutside = this._handleClickOutside.bind(this)
  }

  componentDidMount() {
    document.addEventListener('mousedown', this._boundHandleClickOutside)
  }

  componentWillUnmount() {
    document.removeEventListener('mousedown', this._boundHandleClickOutside)
  }

  _handleClickOutside(event) {
    if (!this.reference.contains(event.target)) {
      this.props.onClose()
    }
  }

  render() {
    return (
      <div ref={ref => (this.reference = ref)} style={this.props.style}>
        {this.props.children}
      </div>
    )
  }
}

module.exports = BoxPopup
