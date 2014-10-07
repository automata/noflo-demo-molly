noflo = require 'noflo'

class Alert extends noflo.Component
  icon: 'exclamation'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'string'

    @inPorts.in.on 'data', (data) =>
      if data isnt undefined
        if noflo.isBrowser()
          alert data
        else
          console.log("Alert: " + data)
        @outPorts.out.send true
        @outPorts.out.disconnect()

exports.getComponent = -> new Alert
