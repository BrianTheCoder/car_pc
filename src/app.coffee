# Module dependencies.

express = require 'express'
routes = require './routes'
http = require 'http'
gpio = require 'gpio'
five = require 'johnny-five'

gpio4 = gpio.export 4,
   # When you export a pin, the default direction is out. This allows you to set
   # the pin value to either LOW or HIGH (3.3V) from your program.
   direction: 'out'
   # Due to the asynchronous nature of exporting a header, you may not be able to
   # read or write to the header right away. Place your logic in this ready
   # function to guarantee everything will get fired properly
   ready: ->
      gpio4.set()                 # sets pin to high
      console.log gpio4.value     # should log 1
      gpio4.set 0                 # sets pin to low (can also call gpio4.reset()
      console.log gpio4.value     # should log 0
      gpio4.unexport()            # all done

board = new five.Board()

board.on 'ready', ->
  shiftRegister = new five.ShiftRegister
    pins:
      data: 2
      clock: 3
      latch: 4

app = express()

app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.configure 'development', ->
  app.use express.errorHandler()

app.get '/', routes.index

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port " + app.get('port')