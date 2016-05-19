React = require('react')
ReactDOM = require('react-dom')

module.exports = React.createClass
  displayName: 'Modal'

  getInitialState: () -> { active: false }

  componentDidMount: () ->
    @setState(active: true)
    $('body').css('overflow', 'hidden')

  componentWillUnmount: () ->
    $('body').css('overflow', 'auto')


  render: () ->

    backdropStyle = {
      zIndex: '2000'
      position: 'absolute'
      top: '0px'
      bottom: '0px'
      left: '0px'
      right: '0px'
    }

    if @state.active == true
      modalStyle = {
        position: 'static'
        zIndex: '1000000'
        margin: 'auto'
        width: '200px'
      }
      fixedStyle = {
        position: 'fixed'
        zIndex: '1000000'
        width: '100%'
        height: '100%'
        overflow: 'scroll'
      }
      staticStyle = {
        position: 'static'
        marginTop: '100px'
        marginBottom: '100px'
        overflow: 'visible'
      }
    else
      modalStyle = {
        zIndex: '1000000',
        top: '100px',
        position: 'absolute'
      }
      fixedStyle = {}
      staticStyle = {}

    if @props.widthInPixel and @state.active == false
      modalStyle.width = @props.widthInPixel + 'px'
      modalStyle.marginLeft = '-' + (@props.widthInPixel / 2) + 'px'
    else
      modalStyle.width = @props.widthInPixel + 'px'


    wrapperStyle = {
      position: 'absolute'
      top: '0px'
      bottom: '0px'
      left: '0px'
      right: '0px'
      zIndex: '100000'
    }



    <div style={wrapperStyle}>
      <div className="modal-backdrop" stye={backdropStyle}></div>
      <div style={fixedStyle}>
        <div style={staticStyle}>
          <div className='modal' style={modalStyle}>
            {@props.children}
          </div>
        </div>
      </div>
    </div>
