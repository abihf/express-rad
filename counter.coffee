
class Lala
  constructor: (@i) ->

Object.defineProperty(Lala.prototype, 'count', {
  get: -> ++@i
})

l = new Lala(2)
console.log l.count
console.log l.count
console.log l.count
