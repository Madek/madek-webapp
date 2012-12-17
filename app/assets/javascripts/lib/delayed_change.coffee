###

jQuery Plugin for having a delayedChange event triggered even when the field was not blured 

after the default waiting time of 500 ms or the one that is provided with options.delay

###

$ = jQuery

$.extend $.fn, delayedChange: (options)-> @each -> $(this).data('_delayed_change', new DelayedChange(this, options)) unless $(this).data("_delayed_change")?

class DelayedChange
  
  @target
  @timeout
  @delay
  @last_value
  
  constructor:(element, options)->
    @delay = if options? and options.delay? then options.delay else 500 
    @target = $(element)
    do @delegate_events 
    this
    
  delegate_events: ->
    @target.on "keyup", @validate
    @target.on "keydown mousedown change", => @last_value = @target.val()
    
  validate: (e)=>
    clearTimeout @timeout if @timeout?
    @timeout = setTimeout =>
      @target.trigger("delayedChange") if @target.val() != @last_value
      @last_value = @target.val()  
    , @delay