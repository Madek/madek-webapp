React = require('react')
FileDrop = 'div' # server-side fallback, see #componentDidMount

module.exports = React.createClass
  displayName: 'FileDropBox'
  propTypes:
    onFilesDrop: React.PropTypes.func.isRequired
    onFilesDrag: React.PropTypes.func

  getInitialState: ()-> {dragging: false}
  componentDidMount: ()->
    FileDrop = require('react-file-drop')
  onDragOver: (event)-> @setState(dragging: true)
  onDragLeave: (event)-> @setState(dragging: false)
  onFilesDrop: (files, event)->
    @setState(dragging: false)
    @props.onFilesDrop(event, files)

  render: ({props, state} = @)->
    <FileDrop
      onDrop={@onFilesDrop}
      onDragOver={@onDragOver}
      onDragLeave={@onDragLeave}
      targetAlwaysVisible={true}>
      {@props.children}
    </FileDrop>
