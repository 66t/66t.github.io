class Rogue
  constructor: -> @initialize.apply(@,arguments)
  Rogue.prototype = Object.create(Rogue.prototype)
  Rogue.prototype.constructor = Rogue
  Object.defineProperties Rogue::, {
    use_len:
      get: ->  @use_room.length
      configurable: true
    use_room:
      get: ->  @room.filter (item) -> item.exist
      configurable: true
    empty_room:
      get: ->  @room.filter (item) -> !item.exist
      configurable: true
    #临近房间数  
    cont1_room:
      get: ->  @empty_room.filter (item) -> item.room_exin.length==1
      configurable: true
    cont2_room:
      get: ->  @empty_room.filter (item) -> item.room_exin.length==2
      configurable: true
    cont3_room:
      get: ->  @empty_room.filter (item) -> item.room_exin.length==3
      configurable: true
    cont4_room:
      get: ->  @empty_room.filter (item) -> item.room_exin.length==4
      configurable: true
    #区域
    room_scope:
      get: -> [
        @room.filter (item) -> item.scope==1
        @room.filter (item) -> item.scope==2
        @room.filter (item) -> item.scope==3
        @room.filter (item) -> item.scope==4
        @room.filter (item) -> item.scope==5
      ]
      configurable: true
  }
  initialize: (w, h, use, mode) ->
    #应用的种子
    @seed_mode=99
    @room = []
    @use = Math.min(use, w * h)
    @w = Number(w)
    @h = Number(h)
    @mode = mode||0
    @initSpace()
    @initScope()
    on
  # 初始化空间
  initSpace: ->
    for i in [0..(@w * @h - 1)]
      @room[i] = new Room(i % @w, parseInt(i / @w), @)
      
    @room[LIM.$data.pro(@seed_mode, @w*@h)].padExist()
    
    #填充
    while  @use_len<@use
      if @cont1_room.length
        @cont1_room[LIM.$data.pro(@seed_mode, @cont1_room.length)].exist=true
      else if  @cont2_room.length
        @cont2_room[LIM.$data.pro(@seed_mode, @cont2_room.length)].exist=true
      else if  @cont3_room.length
        @cont3_room[LIM.$data.pro(@seed_mode, @cont3_room.length)].exist=true
      else if  @cont4_room.length
        @cont4_room[LIM.$data.pro(@seed_mode, @cont4_room.length)].exist=true
      else return
    on
    
  # 初始化区域
  initScope: ->
    #随机3个房间作为顶点
    @triangle=[]
    while @triangle.length<Math.min(3,@use_room.length)
      num=LIM.$data.pro( @seed_mode,@use_room.length)
      @triangle.push(num) if @triangle.indexOf(num)==-1
    @origin=[]
    for i of @room
      p=@use_room[@triangle[0]].room_distance[i]
      p+=@use_room[@triangle[1]].room_distance[i]
      @origin[i]=p
    min=Math.min.apply(null,@origin.filter((item) -> item > -1))
    max=Math.max.apply(null,@origin)
    state=parseInt((max-min)/5)
    for i of @room
      s=if @room[i].exist then parseInt((@origin[i] - min) / state) + 1 else -1
      @room[i].scope=Math.min(s,5)