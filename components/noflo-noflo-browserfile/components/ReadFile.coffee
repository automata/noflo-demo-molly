noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'file'
  c.description = 'Read a file object and output its content as data URL string.'

  c.inPorts.add 'file',
    datatype: 'object'
    description: 'file object'
    process: (event, payload) ->
      return unless event is 'data'
      return unless c.outPorts.out.isAttached()
      file = payload
      reader = new FileReader()
      reader.onload = (e) ->
        c.outPorts.out.send e.target.result
      reader.readAsDataURL file

  c.outPorts.add 'out',
    datatype: 'string'

  c
