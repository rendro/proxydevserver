runner = ->

  ProxyServer  = require './server'
  configparser = require './configparser'
  opts         = require 'opts'

  opts.parse [
    {
      short: "c"
      long:  "config"
      description: "Path to config file"
      value: true
      required: false
    }
  ].reverse(), true

  configFile = opts.get('config') || 'config.yml'

  server = new ProxyServer configparser configFile

  server.start()

module.exports =
  run: runner
