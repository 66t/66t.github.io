class StorageNumber
  constructor: -> @initialize.apply(@,arguments)
  StorageNumber.prototype = Object.create(StorageNumber.prototype)
  StorageNumber.prototype.constructor = StorageNumber
  
  initialize: ->
    @MAX_Number=999999999 
    @MIN_Number=-999999999
    @arr=[]
    on
    
  get: (id) ->
    if @arr[id]?
      LIM.$data.getInn(@arr[id])
    else
      0
LIM.$number = new StorageNumber()      