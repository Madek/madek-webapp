React = require('react')
ReactDOM = require('react-dom')
Preloader = require('./Preloader.cjsx')

module.exports = React.createClass
  displayName: 'Modal'

  getInitialState: () -> { active: false }

  componentDidMount: () ->
    @setState(active: true)
    $('body').css('overflow', 'hidden')

  componentWillUnmount: () ->
    $('body').css('overflow', 'auto')


  render: () ->

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
        overflow: 'scroll'
        top: '0px'
        left: '0px'
        bottom: '0px'
        right: '0px'
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
      <div className="modal-backdrop"></div>
      {
        if @props.loading
          <Preloader />
        else
          <div style={fixedStyle}>
            <div style={staticStyle}>
              <div className='modal' style={modalStyle}>
                {@props.children}
              </div>
            </div>
          </div>
      }
    </div>
