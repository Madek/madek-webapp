React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t('de')

MediaEntryBatchPermissions = require('../../../models/batch/batch-media-entry-permissions.coffee')
ResourcePermissionsForm = require('../../decorators/ResourcePermissionsForm.cjsx')
Preloader = require('../../ui-components/Preloader.cjsx')
ResourcesBatchBox = require('../../decorators/ResourcesBatchBox.cjsx')
TabContent = require('../../views/TabContent.cjsx')
PageContent = require('../../views/PageContent.cjsx')
PageContentHeader = require('../../views/PageContentHeader.cjsx')

xhr = require('xhr')

module.exports = React.createClass
  displayName: 'BatchResourcePermissions'
  propTypes:
    get: React.PropTypes.shape({
      batch_permissions: React.PropTypes.array.isRequired,
      batch_resources: React.PropTypes.shape({ # for thumbs
        resources: React.PropTypes.array.isRequired}),
      actions: React.PropTypes.shape({
        save: React.PropTypes.shape(
          {url: React.PropTypes.string.isRequired, method: React.PropTypes.string.isRequired}),
        cancel: React.PropTypes.shape(
          {url: React.PropTypes.string.isRequired})})
    }).isRequired
    authToken: React.PropTypes.string.isRequired

  # init state model in any case:
  componentWillMount: ()->
    @setState(model: new MediaEntryBatchPermissions(@props.get))

  # NOTE: UI has no fallback, so even though this view only supports
  # 'editing' state, we only activate it on mount to prevent accidental submit
  getInitialState: ()-> isClient: false
  componentDidMount: ()->
    @state.model.on('change', (() => @forceUpdate()))
    @setState(isClient: true)
  componentWillUnmount: ()->
    @state.model.off()

  _loadingMessage: ()-> <div>
    <div className='no-js'><div className='error ui-alert mbm'>{t('app_warning_jsonly')}</div></div>
    <div className='js-only'><Preloader/></div>
  </div>

  _onSubmit: (event)->
    event.preventDefault()
    xhr {
      url: @props.get.actions.save.url
      method: @props.get.actions.save.method,
      json: f.merge(@state.model.serialize(), {return_to: @props.get.actions.cancel.url})
      headers: {'X-CSRF-Token': @props.authToken}
    }, (err, res, body)->
      if (err || res.statusCode > 400 || !body.forward_url)
        alert("Error #{res.statusCode}!")
        console.error(err || body)
      else
        window.location = body.forward_url

  _onCancel: (event)->
    event.preventDefault()
    window.location = @props.get.actions.cancel.url # SYNC!

  render: (props = this.props)->
    batchResources = props.get.batch_resources.resources
    pageTitle = t('permissions_batch_title_pre') + batchResources.length + t('permissions_batch_title_post')

    <PageContent>
      <PageContentHeader icon='pen' title={pageTitle}/>

      <ResourcesBatchBox
        resources={batchResources} authToken={props.authToken} />

      <TabContent>
        <div className="bright pal rounded-bottom rounded-top-right ui-container">
          {if !@state.isClient
            @_loadingMessage()
          else
            <ResourcePermissionsForm editing
              get={@state.model}
              onSubmit={@_onSubmit}
              onCancel={@_onCancel}/>
          }
        </div>
      </TabContent>
    </PageContent>
