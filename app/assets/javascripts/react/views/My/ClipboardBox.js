const React = require('react')
const MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')

const fallbackMessage = <div className='pvh mth mbl'>
  <div className='by-center'>
    <p className='title-l mbm'>{'Sie haben keine Inhalte für die Stapelverarbeitung ausgewählt.'}</p>
  </div>
</div>

module.exports = (props)=>
  !props.get
    ? fallbackMessage
    : <MediaResourcesBox {...props}/>
