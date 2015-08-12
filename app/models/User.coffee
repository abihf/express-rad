
userPlugin = require 'mongoose-user'

module.exports = (Schema) ->
  schema = new Schema
    name: { type: String, default: '' }
    username: { type: String, default: '' }
    email: { type: String, default: '' }
    hashed_password: { type: String, default: '' }
    salt: { type: String, default: '' }
  schema.plugin(userPlugin)
  return schema
