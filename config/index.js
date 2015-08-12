var env = process.env.NODE_ENV || 'development';

var DB_URI = 'mongodb://127.0.0.1/mydb';
var config = {
  env: env,
  name: 'Express Application',

  db: {
    uri: DB_URI
  },

  session: {
    redis: {
      host: '127.0.0.1',
      port: 6379
    }
  },

  routes: require('./routes.json')
};

config.get = function(name, defaultVal) {
  return defaultVal
};
module.exports = config;
