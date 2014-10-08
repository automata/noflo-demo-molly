module.exports = ->
  @initConfig
    noflo_browser:
      build:
        files:
          'demomolly.js': ['component.json']

  # Grunt plugins used for building
  #@loadNpmTasks 'grunt-component-build'
  #@loadNpmTasks 'grunt-contrib-uglify'
  @loadNpmTasks 'grunt-noflo-browser'

  @registerTask 'build', ['noflo_browser']
  @registerTask 'default', ['build']
