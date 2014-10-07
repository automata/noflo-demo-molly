noflo = require 'noflo'
{Arrayable} = require '../lib/Arrayable'
Color = require 'color'

class GetContrast extends Arrayable
  description: 'Get the constrast ratio to a reference color (1 close, 21 far).'
  icon: 'tint'
  constructor: ->
    ports =
      color:
        datatype: 'object'
        description: 'color(s) to get contrast of'
        addressable: true
        required: true
      reference:
        datatype: 'object'
        description: 'a reference color'
        required: true

    super 'contrast', ports

  compute: ->
    return unless @outPorts.contrast.isAttached()
    return unless @props.color? and @props.color.length>0 and @props.reference?

    contrasts = []
    if @props.color instanceof Array
      colors = @expandToArray @props.color
      for c in colors
        if c instanceof Array
          cc = c[0]
        else
          cc = c
        
        cc = @getContrast(cc)
        contrasts.push(cc)

    if contrasts.length == 1
      contrasts = contrasts[0]

    @outPorts.contrast.send contrasts

  getContrast: (a_color) ->
    colorA = new Color a_color
    colorB = new Color @props.reference
    return colorA.contrast(colorB)

exports.getComponent = -> new GetContrast