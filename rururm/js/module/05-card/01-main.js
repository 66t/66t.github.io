// Generated by CoffeeScript 1.12.7
var Card;

Card = (function() {
  function Card() {
    this.initialize.apply(this, arguments);
  }

  Card.prototype = Object.create(Card.prototype);

  Card.prototype.constructor = Card;

  Card.prototype.initialize = function(id) {
    var data;
    if (LIM.card[id]) {
      data = LIM.card[id];
      console.log(LIM.$data);
    }
    return true;
  };

  return Card;

})();
