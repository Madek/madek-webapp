React = require('react')
ReactDOM = require('react-dom')

module.exports = React.createClass
  displayName: 'Modal'

  getInitialState: () -> { active: false }

  handleResize: (event) ->
    modalBody = document.getElementsByClassName('ui-modal-body')[0]
    heightConsumers = document.getElementsByClassName('height-consumer')
    modalBody = document.getElementsByClassName('ui-modal-body')[0]

    consumedHeight = 0
    consumedHeight += hc.offsetHeight for hc in heightConsumers

    topPercentage = 20
    bottomPercentage = 20
    topPercentage = parseInt(@props.topPercentage) if @props.topPercentage
    bottomPercentage = parseInt(@props.bottomPercentage) if @props.bottomPercentage

    height = window.innerHeight - window.innerHeight * (topPercentage + bottomPercentage) / 100 - consumedHeight
    if height < 0
      height = 0
    modalBody.style.height = height + 'px'
    modalBody.style.maxHeight = 'unset'
    modalBody.style.minHeight = 'unset'

  componentDidMount: () ->
    @setState(active: true)
    window.addEventListener('resize', this.handleResize)
    @handleResize()

    # This hack is needed to prevent scrolling behind modal.
    @position = document.body.style.position
    document.body.style.position = 'fixed'

  componentWillUnmount: () ->
    window.removeEventListener('resize', this.handleResize)

    # This hack is needed to revert the other hack above.
    document.body.style.position = @position

  render: () ->

    backdropStyle = {
      zIndex: '2000'
    }

    modalStyle = {
      zIndex: '1000000',
      top: '20%',
      position: 'absolute'
    }

    wrapperStyle = {
      position: 'fixed'
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
