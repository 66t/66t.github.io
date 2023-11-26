class StorageBool
  constructor: -> @initialize.apply(@,arguments)
  StorageBool.prototype = Object.create(StorageBool.prototype)
  StorageBool.prototype.constructor = StorageBool
  initialize: ->
    @arr=[]
    on
    
  get: (id) ->
    arr = parseInt(id / 16)
    if @arr[arr]?
      key = @getGroup arr
      key[id % 16] > 1
    else
      false
      
  set: (id, bool) ->
    arr = parseInt(id / 16)
    if @arr[arr] == null
      @arr[arr] = LIM.$data.idleInn()
    key = @getGroup(arr).split('')
    key[id % 16] = if bool then 2 else 1
    key = key.join('')
    LIM.$data.setInn(@arr[arr], Utils.radixNum(parseInt(key), 3, 10))
    on
    
  getGroup: (index) ->
    Utils.radixNum(LIM.$data.getInn(@arr[index]), 10, 3).padZero(16)    


LIM.$bool = new StorageBool()        