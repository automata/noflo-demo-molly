_ = require("underscore")
noflo = require("noflo")

class MergeObjects extends noflo.Component

  description: "merges all incoming objects into one"

  constructor: ->
    @merge = _.bind @merge, this

    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Objects to merge (one per IP)'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'
        description: 'A new object containing the merge of input objects'

    @inPorts.in.on "connect", () =>
      @groups = []
      @objects = []

    @inPorts.in.on "begingroup", (group) =>
      @groups.push(group)

    @inPorts.in.on "data", (object) =>
      @objects.push(object)

    @inPorts.in.on "endgroup", (group) =>
      @groups.pop()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.send _.reduce @objects, @merge, {}
      @outPorts.out.disconnect()

  merge: (origin, object) ->
    # Go through the incoming object
    for key, value of object
      oValue = origin[key]

      # If property already exists, merge
      if oValue?
        # ... depending on type of the pre-existing property
        switch toString.call(oValue)
          # Concatenate if an array
          when "[object Array]"
            origin[key].push.apply(origin[key], value)
          # Merge down if an object
          when "[object Object]"
            origin[key] = @merge(oValue, value)
          # Replace if simple value
          else
            origin[key] = value

      # Use object if not
      else
        origin[key] = value

    origin

exports.getComponent = -> new MergeObjects
