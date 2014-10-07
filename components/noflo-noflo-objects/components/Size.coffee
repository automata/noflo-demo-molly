noflo = require("noflo")
_ = require("underscore")

class Size extends noflo.Component

  description: "gets the size of an object and sends that out as a number"

  constructor: ->
    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Object to measure the size of'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'int'
        description: 'Size of the input object'

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      @outPorts.out.send _.size data

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new Size
