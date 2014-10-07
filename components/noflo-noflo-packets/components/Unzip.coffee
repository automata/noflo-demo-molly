_ = require("underscore")
noflo = require("noflo")

class Unzip extends noflo.Component

  description: "Send packets whose position upon receipt is even to the
  EVEN port, otherwise the ODD port."

  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      odd: new noflo.Port
      even: new noflo.Port

    @inPorts.in.on "connect", (group) =>
      @count = 0

    @inPorts.in.on "data", (data) =>
      @count++
      port = if @count % 2 is 0 then "even" else "odd"
      @outPorts[port].send(data)

    @inPorts.in.on "disconnect", =>
      @outPorts.odd.disconnect()
      @outPorts.even.disconnect()

exports.getComponent = -> new Unzip
