#键盘输入
class Keyboard
  #注册表
  @controlMapper : {}
  @down : []
  @up : []
  @time : 0
  #初始化
  @install: ->
    data=@controlMapper
    data.tab=[9]
    data.start=[81]
    data.home=[87]
    data.select=[33]
    data.back=[34]
    data.a=[13,32,90]
    data.b=[88,27,45]
    data.x=[17,18]
    data.y=[16]
    data.up=[38,104]
    data.down=[40,98]
    data.left=[37,100]
    data.right=[39,102]

    document.addEventListener 'keydown', @onKeyDown.bind(@);
    document.addEventListener 'keyup', @onKeyUp.bind(@);
    window.addEventListener 'blur', @onBlur.bind(@);
    on

  @onKeyDown:({keyCode})->
    if(!@down[keyCode]||@down[keyCode]<@up[keyCode])
     @down[keyCode]=@time
     @up[keyCode]=@time-1
    on
  @onKeyUp:({keyCode})->
    @up[keyCode]=@time
    on
  @onBlur:->
    @keyTable = []
  @update:->
    @time++
  @isPress:(key)->
    return no unless @controlMapper[key]
    for item in @controlMapper[key]
      if @down[item] == @time
        return on
    no
  @isReleas:(key)->
    return no unless @controlMapper[key]
    bool=no
    for item in @controlMapper[key]
      bool=on if @up[item] == @time
      if @down[item] > @up[item]
       return no  
    bool
 
    
    
#注册        
Keyboard.install()
