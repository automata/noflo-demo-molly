noflo = require 'noflo'
{Arrayable} = require '../lib/Arrayable'
Color = require 'color'

class ConvertToRGB extends Arrayable
  description: 'Converts a given color to RGB.'
  icon: 'tint'
  constructor: ->
    ports =
      color:
        datatype: 'object'
        description: 'color(s) to convert'
        addressable: true
        required: true

    super 'color', ports

  compute: ->
    return unless @outPorts.color.isAttached()
    return unless @props.color? and @props.color.length>0

    new_colors = []
    if @props.color instanceof Array
      colors = @expandToArray @props.color
      for c in colors
        if c instanceof Array
          cc = c[0]
        else
          cc = c
        cc = @toRGB(cc)
        new_colors.push(cc)

    if new_colors.length == 1
      new_colors = new_colors[0]

    @outPorts.color.send new_colors

  toRGB: (old_color) ->
    color = new Color old_color
    return color.rgbString()

exports.getComponent = -> new ConvertToRGB