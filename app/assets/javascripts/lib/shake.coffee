$ = jQuery

$.extend $.fn, shake: (options)-> @each -> new Shake(this, options)

class Shake
  
  @target
  @speed
  
  constructor:(element, options)->
    @target = $(element)
    @speed = if options? and options.speed? then options.speed else 150
    @target.css
      position: "relative"
    @target.animate {left: 15}, @speed
    @target.animate {left: -15}, @speed
    @target.animate {left: 15}, @speed
    @target.animate {left: 0}, @speed
    this