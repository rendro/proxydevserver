path = require 'path'
less = require 'less-middleware'

module.exports = (config) ->
	# make all relative paths absolute
	config.options[i] = path.join(process.cwd(), x) for i, x of config.options when typeof x is 'string' and x.match /^\.\.?\//

	# add rewrite url pairs
	@addRewrite config.src, config.dest

	# add middleware
	@app.use(less(config.options))

	# add static dir for compiled result AFTER the less middleware
	@addStaticDir config.options.dest if config.options.dest
