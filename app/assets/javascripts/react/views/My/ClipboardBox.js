const React = require('react')
const ui = require('../../lib/ui.coffee')
const t = ui.t('de')

const MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')

const fallbackMessage = (
  <div className='pvh mth mbl'>
    <div className='by-center'>
      <p className='title-l mbm'>
        {t('clipboard_empty_message')}
      </p>
    </div>
  </div>
)

module.exports = props =>
  !props.get ? fallbackMessage : <MediaResourcesBox {...props} />
