#! /usr/bin/env coffee

#

service = require('./lib/service')

# Конфигурация и маршруты

config = require('./config')
routes = require('./routes')

service.start(service: config.service, routes: routes, mongo: config.mongo, log: config.log)
