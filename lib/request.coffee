http   = require 'http'
url    = require 'url'

class Request

	@responseHeaderBlackList: [
		'connection'
		'content-length'
	]

	@requestHeaderBlackList: [
		'connection'
		'accept-encoding'
	]

	constructor: (@server, @req, @res) ->

		@options =
			hostname: @server.config.proxy.host
			port: @server.config.proxy.port
			method: @req.method
			path: @req.url

		headers          = @filterHeaders(@req.headers, Request.requestHeaderBlackList)
		headers.host     = @server.config.proxy.host
		@options.headers = headers

		@proxyRequest = http.request @options, @handleResponse.bind @

		@req.on 'data', (chunk) =>
			@proxyRequest.write chunk, 'binary'

		@req.on 'end', =>
			@proxyRequest.end()

		@proxyRequest.on 'error', @handleError

	handleError: (e) ->
		console.log('problem with request: ' + e.message)
		return

	filterHeaders: (originalHeader, filterList) ->
		originalHeader.server = 'Node ProxyServer'
		header = {}
		header[i] = x for i, x of originalHeader when i not in filterList
		header.server = 'Node ProxyServer'
		return header

	handleResponse: (proxyResponse) ->
		isHTML = proxyResponse.headers['content-type'] and proxyResponse.headers['content-type'].indexOf('text/html') >= 0

		headers = @filterHeaders(proxyResponse.headers, Request.responseHeaderBlackList)

		if proxyResponse.headers.location
			location          = url.parse(proxyResponse.headers.location)
			location.host     = null
			location.href     = null
			location.hostname = @server.config.host
			location.port     = @server.config.port
			headers.location  = url.format(location)

		@res.writeHead proxyResponse.statusCode, headers

		body = ''

		proxyResponse.on 'data', (chunk) =>
			if isHTML then body += chunk else @res.write(chunk, 'binary')

		proxyResponse.on 'end', =>
			if isHTML and body.substr(0,1) isnt '{'
				body = manipulator(body) for manipulator in @server.manipulators
			@res.write body if isHTML
			@res.end()

		return

module.exports = Request
