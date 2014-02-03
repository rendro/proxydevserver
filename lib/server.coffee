connect = require 'connect'
http    = require 'http'
path    = require 'path'
url     = require 'url'
colors  = require 'colors'
Request = require './request.coffee'

class ProxyServer

	constructor: (@config) ->
		@rewrites     = {}
		@manipulators = []

		@livereload() if @config.livereload

		@app = connect()

		@app.use connect.logger 'dev'

		@app.use @urlRewriter.bind(@)

		@parseMiddlewareConfig @config.middlewares

		if @config.staticDir
			@staticDir = if @config.staticDir.match(/^\.\.?\//) then path.join(process.cwd(), @config.staticDir) else @staticDir = @config.staticDir
			@addStaticDir @staticDir

		@server = http.createServer @app

	request: (req, res) ->
		return new Request @, req, res

	urlRewriter: (req, res, next) ->
		req.url = to for from, to of @rewrites when url.parse(req.url).pathname is from
		next()
		return

	start: ->
		# add proxy middleware
		@app.use @request.bind @

		#start listening
		@server.listen @config.port, @config.host, =>
			message = "Proxy server started:".green
			message += " #{@config.host}:#{@config.port} -> #{@config.proxy.host}:#{@config.proxy.port}"
			console.log message
		return

	addStaticDir: (path) ->
		@app.use connect.static path
		return

	parseMiddlewareConfig: (config) ->
		for name, middlewareConfig of config
			require("../middlewares/#{name}").call(@, middlewareConfig)
		return

	addRewrite: (from, to) ->
		@rewrites[from] = to
		return

	addManipulator: (manipulator) ->
		@manipulators.push manipulator
		return

	livereload: ->
		# default port: 35729
		livereload = require('livereload').createServer({
			exts: ['less', 'js', 'coffee']
			applyCSSLive: false
		})
		livereload.watch path.join process.cwd()

		# this is evil
		process.on 'uncaughtException', (err) ->
			if err.code is 'ECONNRESET'
				console.log "supressed error: #{err.message}"
			else
				throw err

		@addManipulator require('../manipulators/livereload')

		return

module.exports = ProxyServer
