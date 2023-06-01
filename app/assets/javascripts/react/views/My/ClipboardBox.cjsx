React = require('react')
ui = require('../../lib/ui.coffee')
t = ui.t
libUrl = require('url')

MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')


module.exports = React.createClass
  displayName: 'ClipboardBox'

  forUrl: () ->
    if @props.get.clipboard_id
      libUrl.format(@props.get.resources.config.for_url)

  render: () ->

    if !@props.get.clipboard_id
      return (
        <div className='pvh mth mbl'>
          <div className='by-center'>
            <p className='title-l mbm'>
              {t('clipboard_empty_message')}
            </p>
          </div>
        </div>
      )

    <MediaResourcesBox {...@props} get={@props.get.resources} resourceTypeSwitcherConfig={{ showAll: true }} collectionData={{uuid: @props.get.clipboard_id}} />
