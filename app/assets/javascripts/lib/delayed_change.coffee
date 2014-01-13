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
    @last_values = []
    @timeouts = []
    do @delegate_events 
    this
    
  delegate_events: ->
    @target.on "keydown mousedown change", (e)=> 
      target= $(e.target)
      target_id= target.attr('id')
      target_value= target.val()
      #console.log ["setting delayed_change event", target_id,target_value]
      if target_id 
        #console.log ["setting last_values", target_id, target_value]
        @last_values[target_id]= target_value


    @target.on "keyup", (e)=> 
      target= $(e.target)
      target_id= target.attr('id')
      target_value= target.val()
      #console.log ["evaluating delayed_change event", target_id,target_value]
      if target_id and @last_values[target_id] != target.val()
        #console.log ["new value",target_id,target_value]
        @last_values[target_id] = target_value
        clearTimeout @timeouts[target_id] if @timeouts[target_id]
        target.attr("data-delay-timeout-pending",true)
        # console.log ["setting delay attr", target_id]
        @timeouts[target_id] = setTimeout => 
          target.trigger("delayedChange") 
          #console.log ["trigger delayedChange and removing delay attr", target_id]
          target.removeAttr("data-delay-timeout-pending") 
        , @delay

