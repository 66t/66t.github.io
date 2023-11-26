
class Touch
  @active : true
  @repeatTime : 25
  @keyTable : {}
  @install: ->
    document.addEventListener 'mouseup', @onUp.bind(@)
    document.addEventListener 'mousedown', @onDown.bind(@)
    document.addEventListener 'touchstart', @onDown.bind(@)
    document.addEventListener 'touchend', @onUp.bind(@)
    document.addEventListener 'wheel', @onWheel.bind(@)
    on
  @onDown:(event)->
    @keyTable[event.button]=
      keyTime:performance.now()
      upTime:-1
      count: 0  
    on
  @onUp:(event)->
    if @keyTable[event.button]
      @keyTable[event.button].upTime = performance.now()
    on
  @onWheel:(event)->
    if event.deltaY < 0
      @keyTable[100]=
        keyTime:performance.now()
        upTime:-1
        count: 0
    else
      @keyTable[101]=
        keyTime:performance.now()
        upTime:-1
        count: 0
    on
  @update:->
    return unless @active
    for key, table of @keyTable
      if table.keyTime > table.upTime
        table.count++
      else if table.count>0
        table.count=-1
      else table.count--
    on
  #按下检测      
  @isPress:(c)->
    return on if @keyTable[c]&&@keyTable[c].count==1
    no
  #长按检测  
  @isRepeatPress:(c,time)->
    return on if @keyTable[c]&&@keyTable[c].count > 0&&@keyTable[c].count % (time||@repeatTime)==0
    no
  #释放检测  
  @isReleasPress:(c)->
    return on if @keyTable[c]&&@keyTable[c].count==-1
    no
#注册    
Touch.install()    