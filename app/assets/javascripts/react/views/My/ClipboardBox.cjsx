React = require('react')
ui = require('../../lib/ui.coffee')
t = ui.t
libUrl = require('url')

MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
resourceTypeSwitcher = require('../../lib/resource-type-switcher.cjsx').resourceTypeSwitcher


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

    renderSwitcher = (boxUrl) =>
      resourceTypeSwitcher(boxUrl, true, null)

    <MediaResourcesBox {...@props} get={@props.get.resources} renderSwitcher={renderSwitcher} collectionData={{uuid: @props.get.clipboard_id}} />
