# Необходимые модули

Memcached = require('memcached')

# Приложение из главного модуля

app = require('./app')

memcached = exports = module.exports = new Memcached(app.settings.memcached.split(','), retries: 10, retry: 10000, remove: true)