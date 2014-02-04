# Proxy dev server

The proxydevserver is highly inspired by [KnisterPeters](https://github.com/KnisterPeter) [smaller-dev-server](https://github.com/KnisterPeter/smaller-dev-server). It aims to proxy all requests, intersecting some to serve a fresh set of assets like images, JavaScript or Stylesheets.

Currently it supports the following middelwares:

* LESS.js
* Browserify

## config.yml

```yml
devserver:
  # hostname of the proxy
  host: 'localhost'
  # port of the proxy
  port: 3000
  # support live reload
  livereload: true
  # serve static files
  staticDir: './static/'
  proxy:
  	# host of the target server
    host: 'localhost'
    # port of the target server
    port: 8181
  middlewares:
    # configure less middleware
    less:
      src: '/app.css'
      dest: '/entry.css'
      options:
        src: './sourcestyles/'
        dest: './static'
        compress: false
        sourceMap: false
        paths:
          - './sourceincludes/'
    browserify:
      src: '/app.js'
      dest: './static/entry.js'
      options:
        transforms:
          - coffeeify
        aliases:
          - "js/ext/jquery.js#jquery"
        paths:
          - './sourceincludes/'
```