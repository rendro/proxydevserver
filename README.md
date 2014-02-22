# Proxy dev server [![NPM version](https://badge.fury.io/js/proxydevserver.png)](http://badge.fury.io/js/proxydevserver)

The proxydevserver is highly inspired by [KnisterPeters](https://github.com/KnisterPeter) [smaller-dev-server](https://github.com/KnisterPeter/smaller-dev-server). It aims to proxy all requests, intersecting some to serve a fresh set of assets like images, JavaScript or Stylesheets.

Currently it supports the following middelwares:

* LESS.js
* Browserify

## Install

```
$ npm install -g proxydevserver
$ proxydevserver -c config.yml
```

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
      # url to intersect
      src: '/app.css'
      # url to rewrite src
      dest: '/entry.css'
      # less middleware opeions
      options:
        src: './sourcestyles/'
        dest: './static'
        compress: false
        sourceMap: false
        paths:
          - './sourceincludes/'
    # configure browserify middleware
    browserify:
      # url to intersect
      src: '/app.js'
      # url to rewrite src
      dest: './static/entry.js'
      # browserify options
      options:
        sourceMap: true
        transforms:
          - coffeeify
        aliases:
          - "js/ext/jquery.js#jquery"
        paths:
          - './sourceincludes/'

```

Credits
-------

Thanks to [SinnerSchrader](http://www.sinnerschrader.com/) for their support 
