noflo = require 'noflo'

class Prompt extends noflo.Component
  icon: 'pencil'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'bool'

    @inPorts.in.on 'data', (data) =>
      if data isnt undefined
        @outPorts.out.send ( prompt data )
        @outPorts.out.disconnect()

exports.getComponent = -> new Prompt
