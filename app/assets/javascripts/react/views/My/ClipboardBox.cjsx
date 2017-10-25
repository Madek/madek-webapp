React = require('react')
ui = require('../../lib/ui.coffee')
t = ui.t
libUrl = require('url')

MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
resourceTypeSwitcher = require('../../lib/resource-type-switcher.cjsx')


module.exports = React.createClass
  displayName: 'ClipboardBox'

  getInitialState: ()-> {
    forUrl: libUrl.format(@props.get.resources.config.for_url) if @props.get.clipboard_id
  }

  componentDidMount: ()->

    return if !@props.get.clipboard_id

    @router =  require('../../../lib/router.coffee')
    @unlistenRouter = @router.listen((location) =>
      # NOTE: `location` has strange format, stringify it!
      @setState(forUrl: libUrl.format(location)))
    @router.start()

  componentWillUnmount: () ->
    return if !@props.get.clipboard_id

    @unlistenRouter && @unlistenRouter()


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

    switcher = resourceTypeSwitcher(@props.get.resources, @state.forUrl, true, null)
    <MediaResourcesBox {...@props} get={@props.get.resources} toolBarMiddle={switcher} collectionData={{uuid: @props.get.clipboard_id, addToSetUrl: @props.collectionData.addToSetUrl, removeFromSetUrl: @props.collectionData.removeFromSetUrl}} />
