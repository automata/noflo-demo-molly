noflo = require 'noflo'
{Arrayable} = require '../lib/Arrayable'
Color = require 'color'

class Mix extends Arrayable
  description: 'Mix the given colors with a reference color.'
  icon: 'tint'
  constructor: ->
    ports =
      color:
        datatype: 'object'
        description: 'color(s) to mix'
        addressable: true
        required: true
      reference:
        datatype: 'object'
        description: 'a reference color'
        required: true
      weight:
        datatype: 'number'
        description: 'weight (0 first, 1 second)'
        required: false

    super 'color', ports

  compute: ->
    return unless @outPorts.color.isAttached()
    return unless @props.color? and @props.color.length>0 and @props.reference?

    new_colors = []
    if @props.color instanceof Array
      colors = @expandToArray @props.color
      for c in colors
        if c instanceof Array
          cc = c[0]
        else
          cc = c
        
        cc = @mix(cc)
        new_colors.push(cc)

    if new_colors.length == 1
      new_colors = new_colors[0]

    @outPorts.color.send new_colors

  mix: (a_color) ->
    colorA = new Color a_color
    colorB = new Color @props.reference
    return colorA.mix(colorB, @props.weight).hslString()

exports.getComponent = -> new Mix