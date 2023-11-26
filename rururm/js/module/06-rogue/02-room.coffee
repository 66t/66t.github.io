class Room
  constructor: -> @initialize.apply(@,arguments)
  Room.prototype = Object.create(Room.prototype)
  Room.prototype.constructor = Room
  Object.defineProperties Room::, {
    room_id:
      get: ->  @y * @rogue.w + @x
      configurable: true
    #上下左右的临近空间
    room_up:
      get: -> if @room_id / @rogue.w < 1 then null else @rogue.room[@room_id - @rogue.w]
      configurable: true
    room_down:
      get: -> if @room_id / @rogue.w > @rogue.h - 1 then null else @rogue.room[@room_id + @rogue.w]
      configurable: true
    room_left:
      get: -> if @room_id % @rogue.w == 0 then null else @rogue.room[@room_id - 1]
      configurable: true
    room_right:
      get: -> if @room_id % @rogue.w == @rogue.w - 1 then null else @rogue.room[@room_id + 1]
      configurable: true
    #临近空间
    room_neigh:
      get: -> [@room_down, @room_left, @room_right, @room_up].filter (item) -> item
      configurable: true
    #周围房间
    room_exin:
      get: -> @room_neigh.filter (item) -> item.exist
      configurable: true
    #周围空间
    room_vain:
      get: -> @room_neigh.filter (item) -> not item.exist
      configurable: true
    #周围同级房间
    room_equative:
      get: -> @room_exin.filter (item) -> item.scope==@scope
      configurable: true
    #周围通行房间  
    room_way:
      get: -> @room_exin.filter (item) -> item.door.indexOf(item.room_id)>-1
      configurable: true
    #周围隔断房间 
    room_cut:
      get: -> @room_exin.filter (item) -> item.door.indexOf(item.room_id)==-1
      configurable: true
    #周围同级通行房间    
    room_equa_way:
      get: -> @room_equative.filter (item) -> item.door.indexOf(item.room_id)==-1
      configurable: true
    #周围同级隔断房间 
    room_equa_cut:
      get: -> @room_equative.filter (item) -> item.door.indexOf(item.room_id)==-1
      configurable: true  
    #与其他房间的空间距离表
    room_distance:
      get: ->
        arr=Utils.fillArray(@rogue.room.length,-1)
        arr[@room_id]=0
        arr=@padDistance(arr,1)
        arr
      configurable: true
    #与其他房间的通行距离表  
    way_distance:
      get: ->
       arr=Utils.fillArray(@rogue.room.length,-1)
       arr[@room_id]=0
       arr=@padEnter(arr,1)
       arr
      configurable: true
    #扩散1次后空房间数量
    room_diff:
      get: ->
        @room_vain.reduce (r, item) ->
         r + item.room_vain.length
        ,0
      configurable: true  
  }
  
  initialize: (x,y,rogue) ->
    @rogue=rogue
    @exist=false
    @x = x
    @y = y
    @index=0
    @scope=0
    @prev=null
    @door=[-1,-1,-1,-1]
    on
  padExist:() ->
    try
      switch @rogue.mode
        #
        when 0 then @pad()
        when 1 then @padWide(0)
        when 2 then @padWide(1)
        when 3 then @padWide(2)
        when 4 then @padNarrow(8)
        when 5 then @padNarrow(4)
        when 6 then @padNarrow(2)
        when 7 then @padNarrow(0)
          
      on   
    catch e
        console.log(e)
        
  pad: (prev) ->
    #如果以填充满
    return if @rogue.use <= @rogue.use_len
    
    #设定上一个节点
    @prev = prev if @prev == null and prev
    @exist = true
    #下一个房间
    if @room_vain.length
      @room_vain[LIM.$data.pro(@rogue.seed_mode + (@rogue.use_len % 50), @room_vain.length)].pad(@)
    else if @prev
      @prev.pad()   
  padWide: (d=0,prev) ->
    #如果以填充满
    return if @rogue.use <= @rogue.use_len
    #设定上一个节点
    @prev = prev if @prev == null and prev
    @exist = true

    arr=[]
    for item in @room_vain
      if(item.room_vain.length>d)
        for i in [0..item.room_vain.length]
           arr.push item
        
    #下一个房间
    if arr.length
      arr[LIM.$data.pro(@rogue.seed_mode + (@rogue.use_len % 50), arr.length)].padWide(d,@)
    else if @prev
      @prev.padWide(d)
    else if d>0  
      @padWide(d-1)  
  padNarrow: (d=0,prev) ->
    #如果以填充满
    return if @rogue.use <= @rogue.use_len
    #设定上一个节点
    @prev = prev if @prev == null and prev
    @exist = true  
    arr=[]
    for item in @room_vain
      if(item.room_diff>d)
        for i in [0..item.room_diff]
          arr.push item
    #下一个房间
    if arr.length
      arr[LIM.$data.pro(@rogue.seed_mode + (@rogue.use_len % 50), arr.length)].padNarrow(d,@)
    else if @prev
      @prev.padNarrow(d)
  #迭代距离
  padDistance: (arr,d) ->
    ex=[]
    for room in @room_exin
      if arr[room.room_id]==-1||arr[room.room_id]>d
        arr[room.room_id]=d
        ex.push(room)
    for room in ex
      arr=room.padDistance(arr,d+1)
    arr
  #迭代距离
  padEnter: (arr,d) ->
    ex=[]
    for room in @room_way
      if arr[room.room_id]==-1||arr[room.room_id]>d
        arr[room.room_id]=d
        ex.push(room)
    for room in ex
      arr=room.padEnter(arr,d+1)
    arr  
      