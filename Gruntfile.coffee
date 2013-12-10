module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		watch:
			coffee:
				files: ['src/coffee/**/*.coffee']
				tasks: ['coffee:compile']
		bower:
			install:
				options: 
					targetDir: './public/lib'
					layout: 'byComponent'
					install: true
					verbose: false
					cleanTargetDir: true
					cleanBowerDir: false
		coffee:
			compile:
				files: [
					expand: true
					cwd: 'src/coffee/'
					src: [
						'**/*.coffee'
					]
					dest: 'public/js/'
					ext: '.js'
				]
		exec:
			generate:
				command: 'bundle exec rake make_static_file'

	grunt.loadNpmTasks 'grunt-bower-task'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-exec'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.registerTask 'default', ['watch']
	grunt.registerTask 'install', ['bower']
	grunt.registerTask 'generate', ['exec:generate']
	return
