class Card
  constructor: -> @initialize.apply(@,arguments)
  Card.prototype = Object.create(Card.prototype)
  Card.prototype.constructor = Card
  #初始化
  initialize :(id) ->
    if LIM.card[id]
      data=LIM.card[id]
      console.log(LIM.$data)
    on