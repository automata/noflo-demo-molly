noflo = require 'noflo'

class GetUserMedia extends noflo.Component
  description: 'initialize camera and/or microphone'
  icon: 'video-camera'
  constructor: ->
    @video = true
    @audio = false
    @stream = null
    
    @inPorts = new noflo.InPorts
      start:
        datatype: 'bang'
      stop:
        datatype: 'bang'
      video:
        datatype: 'boolean'
      audio:
        datatype: 'boolean'
    @outPorts = new noflo.OutPorts
      stream:
        datatype: 'object'
      url:
        datatype: 'string'
      error:
        datatype: 'object'

    @inPorts.start.on 'data', () =>
      @resetStream()
    @inPorts.stop.on 'data', () =>
      @stopStream()
    @inPorts.video.on 'data', (@video) =>
      if @stream
        @resetStream()
    @inPorts.audio.on 'data', (@audio) =>
      if @stream
        @resetStream()

    @stopStream = () =>
      if @stream
        if @stream.stop
          @stream.stop()
        @stream = null

    @resetStream = () =>
      @stopStream()
      unless navigator?
        @error 'navigator not available.'
        return
      # Shim
      unless navigator.getUserMedia?
        navigator.getUserMedia = (
          navigator.webkitGetUserMedia ||
          navigator.mozGetUserMedia ||
          navigator.msGetUserMedia ||
          null)
      unless navigator.getUserMedia?
        # In higher-level graph should provide option to chose image
        # with file picker here. This will make it work on mobile etc.
        @error 'navigator.getUserMedia not available.'
        return

      navigator.getUserMedia
        video: @video
        audio: @audio
      , (@stream) =>
        if @outPorts.url.isAttached()
          # Shim
          unless window.URL?
            window.URL = (
              window.webkitURL ||
              window.msURL ||
              window.oURL ||
              null)
          if window.URL.createObjectURL
            @outPorts.url.send window.URL.createObjectURL(stream)
          else
            @outPorts.url.send stream
        if @outPorts.stream.isAttached()
          @outPorts.stream.send stream
      , () =>
        @error 'Access denied or no device available.'

  error: (msg) ->
    if @outPorts.error.isAttached()
      @outPorts.error.send new Error msg
      @outPorts.error.disconnect()
      return
    throw new Error msg

  shutdown: ->
    @stopStream()


exports.getComponent = -> new GetUserMedia
