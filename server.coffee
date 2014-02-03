fs           = require 'fs'
path         = require 'path'
ProxyServer  = require './lib/server'
configparser = require './lib/configparser'

server = new ProxyServer configparser 'config.yml'

server.start()
