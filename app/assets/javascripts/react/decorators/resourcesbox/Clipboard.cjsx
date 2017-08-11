React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t
Modal = require('../../ui-components/Modal.cjsx')
setUrlParams = require('../../../lib/set-params-for-url.coffee')
railsFormPut = require('../../../lib/form-put-with-errors.coffee')

module.exports = React.createClass
  displayName: 'Clipboard'

  getInitialState: () ->
    {
      step: 'initial'
    }


  componentDidMount: () ->
    switch @props.type
      when 'add_all' then @_fetchForAddAll()
      when 'add_selected' then @_addSelected()
      when 'remove_all' then @_removeAll()
      when 'remove_selected' then @_removeSelected()
      else throw 'Unexpected type: ' + @props.type

  _selectedResourceIdsWithTypes: () ->
    @props.selectedResources.selection.map (model) ->
      {
        uuid: model.uuid
        type: model.type
      }

  _fetchForAddAll: () ->
    @setState(step: 'fetching')

    @props.resources.fetchAllResourceIds(
      (result) =>
        if result.result == 'error'
          window.scrollTo(0, 0)
          @setState(step: 'fetching-error', error: 'There was an error. Please try again.')
        else
          @setState(
            step: 'dialog'
            fetchedResources: f.map(result.data, (entry) ->
              {
                uuid: entry.uuid,
                type: entry.type
              }
            )
          )
    )
    return false

  _addSelected: () ->
    @setState(step: 'adding-selected')
    resourceIds = @_selectedResourceIdsWithTypes()
    url = setUrlParams('/batch_add_to_clipboard', {})
    railsFormPut.byData({resource_id: resourceIds}, url, (result) =>
      if result.result == 'error'
        window.scrollTo(0, 0)
        @setState(step: 'adding-error', error: result.message)
      else
        location.reload()
    )
    return false

  _cancelBatchAddToClipboard: (event) ->
    event.preventDefault()
    @props.onClose() if @props.onClose

  _processChunks: () ->

    if @state.step != 'adding-all'
      return



    chunks = @state.chunks

    chunk = f.first(f.filter(chunks, {state: 'pending'}))

    if chunk
      chunk.state = 'loading'
      @setState(chunks: chunks)

      url = setUrlParams('/batch_add_to_clipboard', {})
      railsFormPut.byData({resource_id: chunk.ids}, url, (result) =>
        chunk.state = 'loaded'
        @setState(chunks: chunks)
        if result.result == 'error'
          window.scrollTo(0, 0)
          @setState(step: 'adding-all-error', error: result.message)
        else
          @_processChunks()
      )


    else
      @setState(step: @state.step)
      setTimeout(
        () -> location.reload(),
        100
      )



  _okBatchAddToClipboard: (event) ->
    event.preventDefault()
    resourceIds = @state.fetchedResources
    @setState(step: 'adding-all')

    chunks = f.map(
      f.chunk(resourceIds, 1000),
      (ids) ->
        {
          state: 'pending'
          ids: ids
        }

    )

    @setState(chunks: chunks, () =>
      @_processChunks()
    )

  _cancelAddingAll: () ->
    window.scrollTo(0, 0)
    @setState(step: 'adding-all-cancelled')


  _removeAll: () ->
    @setState(step: 'removing')


    url = setUrlParams('/batch_remove_all_from_clipboard', {})
    railsFormPut.byData({}, url, (result) =>
      if result.result == 'error'
        window.scrollTo(0, 0)
        @setState(step: 'removing-error', error: result.message)
      else
        location.reload()
    )

    return false

  _removeSelected: ()->
    @setState(step: 'removing')
    resourceIds = @_selectedResourceIdsWithTypes()
    url = setUrlParams('/batch_remove_from_clipboard', {})
    railsFormPut.byData({resource_id: resourceIds}, url, (result) =>
      if result.result == 'error'
        window.scrollTo(0, 0)
        @setState(step: 'removing-error', error: result.message)
      else if result.type == 'data' && result.data.result == 'clipboard_deleted'
        # location.href = '/my'
        location.reload()
      else
        location.reload()
    )
    return false

  _infoText: (text) ->
    <div style={{margin: '20px', marginBottom: '20px', textAlign: 'center'}}>
      {text}
    </div>

  _errorBox: (error) ->
    <div style={{margin: '20px', marginBottom: '20px', textAlign: 'center'}}>
      <div className="ui-alerts" style={marginBottom: '20px'}>
        <div className="error ui-alert">
          {@state.error}
        </div>
      </div>
    </div>

  _okCloseAction: () ->
    <div style={{margin: '20px', marginBottom: '20px', textAlign: 'center'}}>
      <div className="ui-actions">
        <a href={null} className={'primary-button'} onClick={@props.onClose}>
          {t('clipboard_ask_add_all_ok')}</a>
      </div>
    </div>

  render: () ->

    switch @state.step

      when 'initial'
        <Modal widthInPixel={400}>
        </Modal>

      when 'fetching'
        <Modal widthInPixel={400}>
          {@_infoText(t('clipboard_fetching_resources'))}
        </Modal>

      when 'fetching-error'
        <Modal widthInPixel={400}>
          {@_errorBox(@state.error)}
          {@_infoText(t('clipboard_fetching_resources'))}
          {@_okCloseAction()}
        </Modal>

      when 'adding-selected'
        <Modal widthInPixel={400}>
          {@_infoText(t('clipboard_adding_resources'))}
        </Modal>

      when 'adding-all'

        chunks = @state.chunks
        pending = f.filter(
          chunks,
          (chunk) ->
            chunk.state != 'loaded'
        )
        done = f.filter(chunks, {state: 'loaded'})

        pendingCount = f.reduce(
          pending,
          (sum, chunk) -> sum + f.size(chunk.ids),
          0
        )
        doneCount = f.reduce(
          done,
          (sum, chunk) -> sum + f.size(chunk.ids),
          0
        )

        counter = if f.size(chunks) > 1
          doneCount + ' / ' + (pendingCount + doneCount)
        else
          ''


        <Modal widthInPixel={400}>
          {@_infoText(t('clipboard_adding_resources') + ' ' + counter)}
          <div style={{margin: '20px', marginBottom: '20px', textAlign: 'center'}}>
            <div className="ui-actions">
              <a onClick={@_cancelAddingAll} className="link weak">{t('clipboard_ask_add_all_cancel')}</a>
            </div>
          </div>
        </Modal>

      when 'adding-error'
        <Modal widthInPixel={400}>
          {@_errorBox(@state.error)}
          {@_infoText(t('clipboard_adding_resources'))}
          {@_okCloseAction()}
        </Modal>

      when 'adding-all-cancelled'
        <Modal widthInPixel={400}>
          {@_infoText(t('clipboard_adding_all_resources_cancelled'))}
          {@_okCloseAction()}
        </Modal>

      when 'adding-all-error'
        <Modal widthInPixel={400}>
          {@_errorBox(@state.error)}
          {@_infoText(t('clipboard_adding_all_resources_error'))}
          <div className="ui-actions" style={{padding: '10px'}}>
            <a onClick={@_cancelBatchAddToClipboard} className="link weak">{t('clipboard_ask_add_all_cancel')}</a>
            <button className="primary-button" type="submit" onClick={@_okBatchAddToClipboard}>
              {t('clipboard_adding_all_resources_retry')}
            </button>
          </div>
        </Modal>

      when 'removing'
        <Modal widthInPixel={400}>
          {@_infoText(t('clipboard_removing_resources'))}
        </Modal>

      when 'removing-error'
        <Modal widthInPixel={400}>
          {@_errorBox(@state.error)}
          {@_infoText(t('clipboard_removing_resources'))}
          {@_okCloseAction()}
        </Modal>

      when 'dialog'
        <Modal widthInPixel={400}>
          <div style={{margin: '20px', marginBottom: '20px', textAlign: 'center'}}>
            {t('clipboard_ask_add_all_1')}{@state.fetchedResources.length}{t('clipboard_ask_add_all_2')}
          </div>
          <div className="ui-actions" style={{padding: '10px'}}>
            <a onClick={@_cancelBatchAddToClipboard} className="link weak">{t('clipboard_ask_add_all_cancel')}</a>
            <button className="primary-button" type="submit" onClick={@_okBatchAddToClipboard}>
              {t('clipboard_ask_add_all_ok')}
            </button>
          </div>
        </Modal>


      else throw 'Unexpected step: ' + @state.step
