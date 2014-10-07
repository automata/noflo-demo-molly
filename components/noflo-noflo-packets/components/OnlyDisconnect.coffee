noflo = require("noflo")

class OnlyDisconnect extends noflo.Component

  description: "the inverse of DoNotDisconnect"

  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.in.on "disconnect", =>
      @outPorts.out.connect()
      @outPorts.out.disconnect()

exports.getComponent = -> new OnlyDisconnect
