###

jQuery Plugin for having a delayedChange event triggered even when the field was not blured 

after the default waiting time of 500 ms or the one that is provided with options.delay

###

$ = jQuery

$.extend $.fn, delayedChange: (options)-> @each -> $(this).data('_delayed_change', new DelayedChange(this, options)) unless $(this).data("_delayed_change")?

class DelayedChange
  
  constructor:(element, options)->
    @delay = if options? and options.delay? then options.delay else 500 
    @target = $(element)
    @last_value = @target.val()
    do @delegate_events 
    this
    
  delegate_events: ->
    @target.on "keydown mousedown change", (e)=> 
      target = $(e.target)
      @last_value = target.val()
    @target.on "keyup", @validate
    
  validate: (e)=>
    target = $(e.target)
    clearTimeout @timeout if @timeout?
    @timeout = setTimeout =>
      target.trigger("delayedChange") if target.val() != @last_value
      @last_value = target.val()  
    , @delay