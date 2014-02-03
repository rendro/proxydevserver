fs         = require 'fs'
path       = require 'path'
url        = require 'url'
through    = require 'through'
browserify = require 'browserify'
resolve    = require 'resolve'
convert    = require 'convert-source-map'

class BrowserifyMiddleware
	constructor: (@config) ->
		dest = if @config.dest.match /^\.\.?\// then path.join(process.cwd(), @config.dest) else @config.dest

		options =
			extensions: ['.coffee']

		if @config.options.paths


			# make paths absolute
			@config.options.paths[i] = path.join(process.cwd(), x) for i, x of @config.options.paths when typeof x is 'string' and x.match /^\.\//

			options.resolve = (pkg, options, cb) =>
				options.paths = @config.options.paths.concat options.paths

				# filter empty paths because otherwise it breaks the resolver
				options.paths = options.paths.filter (p) -> p != ''

				if pkg.match /^\.\.?\//
					options.basedir = path.dirname(options.filename)

				else if pkg.match /^\//
					isAbsolute = options.paths.some (lookupPath) -> pkg.indexOf(lookupPath) == 0
					pkg = pkg.substr(1) if !isAbsolute

				resolve.call(this, pkg, options, cb)
				return

		# add paths to package resolver
		@b = browserify([], options)

		@b.add(dest)

		@b.transform(require(transform)) for transform in @config.options.transforms

		@addAliases(@config.options.aliases) if @config.options.aliases

	addAliases: (aliases) ->
		for alias in aliases
			aliasParts = alias.split("#")
			@b.require(aliasParts[0], { expose: aliasParts[1] })

	requestHandler: (req, res, next) ->
		if url.parse(req.url).pathname is @config.src

			res.writeHead 200, {
				'content-type': 'text/javascript;charset=utf-8'
			}

			withSourceMap = @config.options.sourceMap || false
			data = ''
			handleData = (chunk) -> data += chunk
			end = ->
				if withSourceMap
					sourceMap = convert.fromSource(data)
					sourceMap.setProperty('sources', sourceMap.getProperty('sources').map((source) ->
						return path.relative(process.cwd(), source)
					))
					data = convert.removeComments(data)
					data += "\n#{sourceMap.toComment()}\n"
				res.write(data)
				res.end()
			@b.bundle({ debug: withSourceMap }).pipe(through(handleData, end))
		else
			next()


module.exports = (config) ->
	mw = new BrowserifyMiddleware(config)
	@app.use(mw.requestHandler.bind(mw))
