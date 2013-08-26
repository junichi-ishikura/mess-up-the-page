module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

  # config
    watch:
      default:
        files: ['../src/coffee/**/*.coffee']
        tasks: ['coffee', 'uglify']

    coffee:
      compile:
        options:
          sourceMap: true
          bare: true
        files:
          '../js/app.js': ['../src/coffee/particle.coffee',
                           '../src/coffee/Flip.coffee',
                           '../src/coffee/LeapElement.coffee',
                           '../src/coffee/LeapManagerUtils.coffee',
                           '../src/coffee/Cursor.coffee',
                           '../src/coffee/CursorManager.coffee',
                           '../src/coffee/LeapManager.coffee']

    uglify:
      uglify_target:
        options:
          beautify: false
        files: [
          expand: true
          cwd: '../js/'
          src: ['app.js']
          dest: '../js/'
          ext: '.min.js'
        ]


  # loadNpmTasks
  # read from package.json
  for taskName of pkg.devDependencies when taskName.substring(0, 6) is 'grunt-'
    grunt.loadNpmTasks taskName

  grunt.registerTask 'default', ['coffee', 'uglify', 'watch']