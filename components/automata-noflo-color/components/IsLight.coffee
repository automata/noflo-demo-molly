noflo = require 'noflo'
{Arrayable} = require '../lib/Arrayable'
Color = require 'color'

class IsLight extends Arrayable
  description: 'Check if a light color.'
  icon: 'tint'
  constructor: ->
    ports =
      color:
        datatype: 'object'
        description: 'color(s) to check'
        addressable: true
        required: true

    super 'light', ports

  compute: ->
    return unless @outPorts.light.isAttached()
    return unless @props.color? and @props.color.length>0

    lights = []
    if @props.color instanceof Array
      colors = @expandToArray @props.color
      for c in colors
        if c instanceof Array
          cc = c[0]
        else
          cc = c
        
        cc = @isLight(cc)
        lights.push(cc)

    if lights.length == 1
      lights = lights[0]

    @outPorts.light.send lights

  isLight: (a_color) ->
    color = new Color a_color
    return color.light()

exports.getComponent = -> new IsLight