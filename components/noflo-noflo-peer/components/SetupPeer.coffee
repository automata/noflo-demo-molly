# @runtime noflo-browser

noflo = require 'noflo'
Peer = require('peerjs').Peer

exports.getComponent = ->
  c = new noflo.Component
  c.peer = null
  c.key = null
  c.server = null
  c.id = null
  c.connections = null
  c.stream = null

  # Define a meaningful icon for component from http://fontawesome.io/icons/
  c.icon = 'cog'

  # Provide a description on component usage
  c.description = 'Connect to peer.js server, then connect to peers for P2P audio/visual and data communication.'

  # Add input ports
  c.inPorts.add 'key',
    datatype: 'string'
    description: 'API key for hosted service: http://peerjs.com/peerserver'
    default: 'lwjd5qra8257b9'
    process: (event, payload) ->
      return unless event is 'data'
      c.key = payload

  # TODO stun/ice config? https://code.google.com/p/natvpn/source/browse/trunk/stun_server_list
  c.inPorts.add 'server',
    datatype: 'object'
    description: 'optional custom peerjs server connection: {host, port, path}'
    process: (event, payload) ->
      return unless event is 'data'
      c.server = payload

  c.inPorts.add 'connect',
    datatype: 'bang'
    description: 'open connection with broker server'
    process: (event, payload) ->
      return unless event is 'data'
      unless c.key? or c.server?
        c.sendServerError 'need an api `key` or custom `server` input before starting'
        return
      options = {}
      if c.server?
        options = c.server
      if c.key?
        options.key = c.key
      peer = c.peer = new Peer(options)
      peer.on 'error', (err) ->
        return unless c.outPorts.server_error.isAttached()
        c.sendServerError err
      peer.on 'open', (id) ->
        c.id = id
        c.connections = {}
        if c.outPorts.id.isAttached()
          c.outPorts.id.send id
      peer.on 'connection', c.setupConnection
      peer.on 'call', c.setupConnection


  c.inPorts.add 'connect_peer',
    datatype: 'string'
    description: 'connect with this peer id'
    process: (event, payload) ->
      return unless event is 'data'
      unless c.peer?
        c.sendServerError 'need to connect to server before connecting to peer'
        return
      connection = c.peer.connect payload
      c.setupConnection connection

  c.inPorts.add 'send_peer',
    datatype: 'all'
    description: 'Send data to peer. Peer ID defined by group. If no group send to all connected.'
    process: (event, payload) ->
      console.log event, payload
      # if event is 'group'
      return unless event is 'data'
      unless c.peer?
        c.sendServerError 'need to connect to server before sending to peer'
        return
      # TODO if group defined, only send to that peer
      sentCount = 0
      for own id, conn of c.connections
        if conn.type is 'data' and conn.open
          conn.send payload
          sentCount++
      if sentCount is 0
        c.sendServerError 'no open peer connections'

  c.inPorts.add 'stream',
    datatype: 'object'
    description: 'mediaStream to use for call'
    process: (event, payload) ->
      return unless event is 'data'
      c.stream = payload

  c.inPorts.add 'call_peer',
    datatype: 'string'
    description: 'peer id to initiate media call'
    process: (event, payload) ->
      return unless event is 'data'
      unless c.peer?
        c.sendServerError "need to connect to server before calling peer"
        return
      unless c.stream?
        c.sendServerError "need a media stream before calling peer"
        return
      call = c.peer.call payload, c.stream
      c.setupConnection call

  c.inPorts.add 'answer_call',
    datatype: 'string'
    description: 'peer id to answer call'
    process: (event, payload) ->
      return unless event is 'data'
      peerId = payload
      unless c.peer? and c.connections?
        c.sendServerError "need to connect to server before answering peer"
        return
      connection = c.connections[peerId]
      unless connection?
        c.sendPeerError peerId, 'no connection with that id'
      unless connection.type is 'media'
        c.sendPeerError peerId, 'not a media connection'
      connection.answer(c.stream)

  c.inPorts.add 'close_peer',
    datatype: 'string'
    description: 'peer id to close connection'
    process: (event, payload) ->
      return unless event is 'data'
      peerId = payload
      unless c.peer? and c.connections?
        c.sendServerError "not connected to server"
        return
      connection = c.connections[peerId]
      unless connection?
        c.sendPeerError peerId, 'no connection with that id'
      connection.close()

  # Add output ports
  c.outPorts.add 'id',
    datatype: 'string'
    description: 'my peer id'

  c.outPorts.add 'data',
    datatype: 'all'
    description: 'data from peer'

  c.outPorts.add 'call',
    datatype: 'object'
    description: 'call from peer'

  c.outPorts.add 'stream',
    datatype: 'object'
    description: 'stream from peer'

  c.outPorts.add 'open',
    datatype: 'object'
    description: 'connection opened'

  c.outPorts.add 'close',
    datatype: 'object'
    description: 'connection closed'

  c.outPorts.add 'server_error',
    datatype: 'object'
    description: 'server error'

  c.outPorts.add 'peer_error',
    datatype: 'object'
    description: 'connection error'

  # Util
  c.setupConnection = (conn) ->
    peerId = conn.peer
    c.connections[peerId] = conn
    conn.on 'open', ->
      return unless c.outPorts.open.isAttached()
      c.outPorts.open.beginGroup peerId
      c.outPorts.open.send conn
      c.outPorts.open.endGroup()
    conn.on 'data', (data) ->
      return unless c.outPorts.data.isAttached()
      c.outPorts.data.beginGroup peerId
      c.outPorts.data.send data
      c.outPorts.data.endGroup()
    conn.on 'close', ->
      return unless c.outPorts.close.isAttached()
      c.outPorts.close.beginGroup peerId
      c.outPorts.close.send conn
      c.outPorts.close.endGroup()
    conn.on 'error', (err) ->
      c.sendPeerError peerId, err

    return unless conn.type is 'media'
    conn.on 'stream', (stream) ->
      return unless c.outPorts.stream.isAttached()
      c.outPorts.stream.beginGroup peerId
      c.outPorts.stream.send stream
      c.outPorts.stream.endGroup()

  c.sendPeerError = (peerId, err) ->
    out = c.outPorts.peer_error
    return unless out.isAttached()
    out.beginGroup peerId
    out.send err
    out.endGroup()

  c.sendServerError = (err) ->
    out = c.outPorts.server_error
    return unless out.isAttached()
    out.send err


  # Finally return the component instance
  c
