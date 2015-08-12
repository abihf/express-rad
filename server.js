/**
 * Created by abie on 8/10/15.
 */

require('iced-coffee-script/register');
var http = require('http');
var config = require('./config');
var app = require('./app')(config);

var port = process.env.PORT || 3000;
var host = '127.0.0.1';
http.createServer(app).listen(port, function(){
console.log(this.port);
  console.info('Server listening on http://' + host + ':' + port);
});

// app.run()
