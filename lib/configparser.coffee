fs          = require 'fs'
path        = require 'path'
yaml        = require 'yaml'

module.exports = (file) ->
	if fs.existsSync file
		filecontents = fs.readFileSync(file).toString().replace(/\t/g, '  ')
		config       = yaml.eval(filecontents).devserver
	else
		console.log "Error: config file '#{file}' does not exist"
		process.kill(process.pid)
	return config
