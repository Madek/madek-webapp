React = require('react')
ReactDOM = require('react-dom')

module.exports = React.createClass
  displayName: 'Modal'

  getInitialState: () -> { active: false }

  componentDidMount: () ->
    @setState(active: true)

  render: () ->

    backdropStyle = {
      zIndex: '2000'
      position: 'absolute'
      top: '0px'
      bottom: '0px'
      left: '0px'
      right: '0px'
    }

    modalStyle = {
      zIndex: '1000000',
      top: '20%',
      position: 'absolute'
    }

    if @props.widthInPixel
      modalStyle.width = @props.widthInPixel + 'px'
      modalStyle.marginLeft = '-' + (@props.widthInPixel / 2) + 'px'

    wrapperStyle = {
      position: 'absolute'
      top: '0px'
      bottom: '0px'
      left: '0px'
      right: '0px'
      zIndex: 100000
    }

    <div style={wrapperStyle}>
      <div className="modal-backdrop" stye={backdropStyle}></div>
      <div className='modal' style={modalStyle}>
        {@props.children}
      </div>
    </div>
