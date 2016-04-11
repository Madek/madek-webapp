###
Proof of Concept: Inline Edit
- only implemented for MetaDatumText to keep it simple (no ui components, just "HTML")
- integrated with UI with conventional UJS
  (target elements with data properties; enhance on document load)
###

React = require('react')
ampersandReactMixin = ('ampersand-react-mixin')

module.exports = React.createClass
  displayName: 'MetaDatumEdit'
  mixins: [ampersandReactMixin]

  getInitialState: ()-> { editing: false, updating: false }

  onEditClick: (event)->
    event.preventDefault()
    @setState(editing: true) unless (@state.updating)

  onCancelClick: (_event)-> @setState(editing: false)

  onSubmit: (value)->
    metaDatum = @props.metaDatum

    @setState(editing: false)
    return unless value?

    previous = metaDatum.serialize()
    @setState(updating: true)
    metaDatum.values = [value] # this also (optimistically) updates the UI

    metaDatum.save
      success: (model, response, options)=>
        @setState(updating: false)

      error: (model, response, options)=>
        # roll back the state (thus also the UI)
        model.set(previous)
        @setState(updating: false)
        # HACK: just 'alert' the error
        alert 'Error!\n\n' + response.body

  render: ()->
    metaDatum = @props.metaDatum
    editing = @state.editing
    updating = @state.updating

    # HACK: build 1 dl per datum…
    <dl className='media-data mbs'>

      <dt className='media-data-title' data='meta-datum-editable'>
        <a className='weak' disabled={updating} onClick={@onEditClick}>
          {<i className={'icon-pen'}/>}
          {metaDatum.meta_key.label}
        </a>
        {updating and <span> saving…</span> or null}
      </dt>

      <dd className='media-data-content'>
        {if editing
          <ValuesEdit metaDatum={metaDatum}
            onCancelClick={@onCancelClick}
            onDeleteClick={@onDeleteClick}
            onSubmit={@onSubmit}/>
         else
           <ValuesShow metaDatum={metaDatum} persisted={!updating}/>
        }
      </dd>

    </dl>

ValuesShow = React.createClass
  mixins: [ampersandReactMixin]
  render: ()->
    values = @props.metaDatum.values
    persisted = @props.persisted # needed as indicator for testing

    <ul className='inline' data-meta-datum-persisted={persisted}>
      {values.map (string)-> <li key={string}>{string}</li> }
    </ul>

ValuesEdit = React.createClass
  getInitialState: ()->
    # HACK: only edit first value (MetaDatumText only)
    { initalValue: @props.metaDatum.serialize().values[0] }

  onValueChange: (event)->
    @setState({value: event.target.value})

  onSubmit: (event)->
    event.preventDefault()
    @props.onSubmit(@state.value)

  render: ()->
    metaDatum = @props.metaDatum
    onCancelClick = @props.onCancelClick
    onDeleteClick = @props.onDeleteClick
    onSubmit = @onSubmit
    onValueChange = @onValueChange
    # component keeps internal state of currently edited values:
    value = @state.value or @state.initalValue
    hasChanged = value != @state.initalValue

    <form onSubmit={onSubmit}>
      <input type='text' className='block' placeholder='(Text)'
        defaultValue={value} onChange={onValueChange}/>
      <div className='ui-actions'>
        <a className='weak' onClick={onCancelClick}>
          Cancel</a>
        <button className='primary-button' type='submit' disabled={!hasChanged}>
          Save</button>
      </div>
    </form>
