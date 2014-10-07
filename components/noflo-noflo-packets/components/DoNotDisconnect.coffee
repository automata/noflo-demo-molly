noflo = require("noflo")

class DoNotDisconnect extends noflo.Component

  description: "forwards everything but never disconnect"

  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      @outPorts.out.send(data)

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

exports.getComponent = -> new DoNotDisconnect
