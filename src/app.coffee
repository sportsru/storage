# Необходимые модули

http = require('http')
express = require('express')
program = require('commander')

#

uid = require('./uid')

# Конфигурация приложения

config = require('../config')

app = module.exports = express()

# CLI args

program
	.option('-a, --address <string>', 'REST service address', config.storage.address)
	.option('-p, --port <port>', 'REST service port', config.storage.port)
	.option('-b, --mongo <string>', 'MongoDB connection string', config.mongo)
	.option('-m, --memcached <string>', 'Memcached servers list', config.memcached)
	.option('-v, --verbose', 'Log requests', false)
	.option('--memcached-prefix <string>', 'Memcached keys prefix', 's_')
	.parse(process.argv)

# Указываем необходимый Middleware

app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.logger('short')) if program.verbose
app.use(uid)
app.use(app.router)

# Устанавливаем общую конфигурацию приложения

app.set('verbose', program.verbose)
app.set('memcached', program.memcached)
app.set('mongobase', program.mongo)
app.set('memcachedPrefix', program.memcachedPrefix)

# И для отдельных окружений

app.use(express.errorHandler(dumpExceptions: true, showStack: true)) if app.get('env') is 'development'
app.use(express.errorHandler()) if app.get('env') is 'production'

# Устанавливаем маршрутизацию

#require('./api')

#

http.createServer(app).listen(program.port, program.address, () ->
	console.log """
		REST server listening
		Address			: \u001b[91m#{program.address}\u001b[0m
		Port			: \u001b[91m#{program.port}\u001b[0m
		Memcached		: \u001b[91m#{app.settings.memcached}\u001b[0m
		Memcached Prefix	: \u001b[91m#{app.settings.memcachedPrefix}\u001b[0m
		MongoDB			: \u001b[91m#{app.settings.mongobase}\u001b[0m
		Mode			: \u001b[91m#{app.settings.env}\u001b[0m
	"""
)