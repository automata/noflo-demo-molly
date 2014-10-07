noflo = require 'noflo'
{Arrayable} = require '../lib/Arrayable'
Color = require 'color'

class Transform extends Arrayable
  description: 'Transforms a color applying the given parameters.'
  icon: 'tint'
  constructor: ->
    ports =
      color:
        datatype: 'object'
        description: 'color(s) to transform'
        addressable: true
        required: true
      lighten:
        datatype: 'number'
        description: 'light intensity (0..1)'
        required: false
      darken:
        datatype: 'number'
        description: 'dark intensity (0..1)'
        required: false
      saturate:
        datatype: 'number'
        description: 'saturation intensity (0..1)'
        required: false
      desaturate:
        datatype: 'number'
        description: 'desaturation intensity(0..1)'
        required: false
      whiten:
        datatype: 'number'
        description: 'white intensity (0..1)'
        required: false
      blacken:
        datatype: 'number'
        description: 'black intensity (0..1)'
        required: false
      clearer:
        datatype: 'number'
        description: 'transparency intensity (0..1)'
        required: false
      opaquer:
        datatype: 'number'
        description: 'opaque intensity (0..1)'
        required: false
      rotate:
        datatype: 'number'
        type: 'noflo-canvas/angle'
        description: 'angle in degrees (0..360)'
        required: false

    super 'color', ports

  compute: ->
    return unless @outPorts.color.isAttached()
    return unless @props.color? and @props.color.length>0
    return unless @props.lighten? or @props.darken? or @props.saturate? or
    @props.desaturate? or @props.whiten? or @props.blacken? or
    @props.clearer? or @props.opaquer? or @props.rotate?

    new_colors = []
    if @props.color instanceof Array
      colors = @expandToArray @props.color
      for c in colors
        if c instanceof Array
          cc = c[0]
        else
          cc = c
        # Calls @foo for each of @props.foo inport that has a value
        for k of @props
          # Color and type are not expected methods (for color instance)
          if k isnt 'color' and k isnt 'type'
            # Following DRY, we use a factory to call proper color.method
            cc = @factory(k, cc)
        new_colors.push(cc)

    if new_colors.length == 1
      new_colors = new_colors[0]

    @outPorts.color.send new_colors

  factory: (op, old_color) ->
    color = new Color old_color
    # Metaprogramming for the sake
    new_color = color[op](@props[op]).hslString()
    return new_color

exports.getComponent = -> new Transform