noflo = require 'noflo'
{Arrayable} = require '../lib/Arrayable'
Color = require 'color'

class GetLuminosity extends Arrayable
  description: 'Get the relative luminosity of a given color.'
  icon: 'tint'
  constructor: ->
    ports =
      color:
        datatype: 'object'
        description: 'color(s) to get luminosity of'
        addressable: true
        required: true

    super 'luminosity', ports

  compute: ->
    return unless @outPorts.luminosity.isAttached()
    return unless @props.color? and @props.color.length>0

    luminosities = []
    if @props.color instanceof Array
      colors = @expandToArray @props.color
      for c in colors
        if c instanceof Array
          cc = c[0]
        else
          cc = c
        
        cc = @getLuminosity(cc)
        luminosities.push(cc)

    if luminosities.length == 1
      luminosities = luminosities[0]

    @outPorts.luminosity.send luminosities

  getLuminosity: (a_color) ->
    color = new Color a_color
    return color.luminosity()

exports.getComponent = -> new GetLuminosity