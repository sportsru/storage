# Управление сервисом
#
# Март, 2013 год
#
# Автор - Владимир Андреев
#
# E-Mail: volodya@netfolder.ru

# Необходимые модули

async = require('async')
syslog = require('node-syslog')
http = require('http')
express = require('express')
mongo = require('mongodb')

# Управление сервисом

service =
	# Начинает работу сервиса

	start: (options, callback) ->
		# Иниализируем клиента Syslog

		syslog.init(options.log.name, syslog.LOG_PID | syslog.LOG_ODELAY, syslog.LOG_LOCAL0)

		# Создаем приложение Express и настраиваем его

		@application = express()

		@application.use(express.logger('dev'))

		# Устанавливаем маршруты

		#for route in routes

		# Подключаемся к MongoDB

		@db = new mongo.Db(options.mongo.db, new mongo.Server(options.mongo.host, options.mongo.port), options.mongo.options)

		@db.open((error) ->
			console.log(error)

			undefined
		)

		# Создаем сокет для входящих подключений

		@server = http.createServer(@application)

		@server.on('error', (error) ->
			console.log('An error has occured')
			console.log(error)

			syslog.log(syslog.LOG_CRIT, 'Unable to start service')

			undefined
		) 

		@server.listen(options.service.port, options.service.host, () ->
			console.log('Listening now')

			syslog.log(syslog.LOG_INFO, 'Service successfully started')

			undefined
		)

		@

	# Останавливает работу сервиса

	stop: () ->
		@server.close()

		syslog.close()

		@

# Объекты для экспорта

module.exports = service
