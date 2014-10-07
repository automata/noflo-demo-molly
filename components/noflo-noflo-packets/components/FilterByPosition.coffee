noflo = require("noflo")
_ = require("underscore")

class FilterByPosition extends noflo.Component

  description: "Filter packets based on their positions"

  constructor: ->
    @filters = []

    @inPorts =
      in: new noflo.Port
      filter: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.filter.on "connect", =>
      @filters = []
    @inPorts.filter.on "data", (filter) =>
      @filters.push filter

    @inPorts.in.on "connect", =>
      @count = 0
    @inPorts.in.on "data", (data) =>
      @outPorts.out.send data if @filters[@count]
      @count++
    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new FilterByPosition
