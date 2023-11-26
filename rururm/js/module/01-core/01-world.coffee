#应用
class World
  #画布大小
  @canvasWidth: 16*128
  @canvasHeight: 9*128
  #画面大小
  @windowWidth: 0
  @windowHeight: 0
  #当前缩放比例
  @scale: 1
  #pixi应用
  @app: null
  #工作场景
  @tick: null
  #运行时钟
  @clock: [0, 0, 0, 0, 0, 0]
  #鼠标坐标
  @cursor: [0, 0]
  #画布位置
  @canvas:
    x: 0
    y: 0
    w: 0
    h: 0
  #fps标记  
  @showFps: false
  #world初始化
  @init: ->
    PIXI.utils.skipHello()
    PIXI.settings.GC_MAX_IDLE = 600
    @initCanvas()
    @initFps()
    @initFont()
    
    @updateFps()
    @setupEventHandlers()
    @resize()
    on
  @initCanvas: ->
    try
      @app = new PIXI.Application
        width: @canvasWidth
        height: @canvasHeight
        resolution: window.devicePixelRatio
        antialias: true
        autoStart: false
        
        
      PIXI.settings.PREFER_ENV = PIXI.ENV.WEBGL; 
      document.body.appendChild @app.view
      @app.view.style.display = "none"
      @app.view.style.position = "absolute"
  
      @app.ticker.remove @app.render, @app
      @app.ticker.add @onTick, this
  
      @clock[2] = 100
      @clock[1] = performance.now() - 100
      on
    catch e
      this._app = null;
      no
  #运行pixi  
  @startGame: ->
    @app.start() if @app
    on
  #停止pixi    
  @stopGame: ->
    @app.stop() if @app
    on
  #初始化FPS提示
  @initFps: ->
    @fps = document.createElement("div")
    @memory = document.createElement("div")
    @xy = document.createElement("div")
    
    document.body.appendChild @fps
    @fps.style.width = "200px"
    @fps.style.height = "30px"
    @fps.style.top = "30px"
    @fps.style.left = "10px"
    @fps.style.lineHeight = "30px"
    @fps.style.position = "absolute"
    @fps.style.backgroundColor = "#000a"
    @fps.style.color = "#fff"
    @fps.style.fontSize = "18px"
    @fps.style.fontWeight = "800"
    @fps.style.textAlign = "left"
    @fps.style.pointerEvents = "none"

    document.body.appendChild @memory
    @memory.style.width = "200px"
    @memory.style.height = "30px"
    @memory.style.left = "10px"
    @memory.style.lineHeight = "30px"
    @memory.style.position = "absolute"
    @memory.style.backgroundColor = "#000a"
    @memory.style.color = "#fff"
    @memory.style.fontSize = "18px"
    @memory.style.fontWeight = "800"
    @memory.style.textAlign = "left"
    @memory.style.pointerEvents = "none"

    document.body.appendChild @xy
    @xy.style.width = "200px"
    @xy.style.height = "30px"
    @xy.style.top = "60px"
    @xy.style.left = "10px"
    @xy.style.lineHeight = "30px"
    @xy.style.position = "absolute"
    @xy.style.backgroundColor = "#000a"
    @xy.style.color = "#fff"
    @xy.style.fontSize = "18px"
    @xy.style.fontWeight = "800"
    @xy.style.textAlign = "left"
    @xy.style.pointerEvents = "none"
    on
  #更新FPS提示
  @updateFps: ->
    if @showFps
      @fps.style.display ='block'
      @xy.style.display ='block'
      @memory.style.display ='block'
    else
      @fps.style.display ='none'
      @xy.style.display ='none'
      @memory.style.display ='none'
    on
  #绘制FPS提示  
  @drawFps: ->
    @fps.innerHTML = "fps: #{@clock[3].toFixed(0)}"
    @memory.innerHTML = "#{(performance.memory.usedJSHeapSize / 1048576).toFixed(2)}MB"
    @xy.innerHTML = "#{@cursor[0].toFixed(0)}/#{@cursor[1].toFixed(0)}"
    on
  #设置场景  
  @setStage: (stage) ->
    @app.stage = stage if @app
    on
  #是否渲染   
  @canRender: -> !!@app.stage
  #初始化字体  
  @initFont:->
    FontManager.load("cubic","cubic.ttf")
    FontManager.load("ht","ZiXinFangShenShiHei-2.ttf")
    on
  #设置工作  
  @setTick: (handler) ->
    @tick = handler
    on
  #运行工作  
  @onTick: (deltaTime) ->
    @clock[0] = performance.now()
    @tick deltaTime if @tick  
    @app.render() if @canRender()
    
    time = performance.now()
    thisclockTime = time - @clock[1]
    
    @clock[2] += (thisclockTime - @clock[2]) / 12
    @clock[3] = 1000 / @clock[2]
    @clock[4] = Math.max(0, time - @clock[0])
    @clock[1] = time
    @drawFps() if @clock[5]++ % 15 == 0
    on
  #计算缩放比例
  @resize: ->
    @windowWidth = window.innerWidth
    @windowHeight = window.innerHeight
    scale = Math.min(@windowWidth / @app.view.width, @windowHeight / @app.view.height)
    @setScale scale
    on
  #改变分辨率时
  @changeResolution: (w, h) ->
    @scale = 1
    w *= window.devicePixelRatio
    h *= window.devicePixelRatio
    @canvasWidth = w
    @canvasHeight = h
    @app.width = w
    @app.height = h
    @app.view.width = w
    @app.view.height = h
    @resize()
    on
  #设置canvas缩放  
  @setScale: (scale) ->
    if @app?.view
      @scale = scale
      canvasStyle = @app.view.style
      canvasOffsetWidth = @app.view.offsetWidth
      canvasOffsetHeight = @app.view.offsetHeight
      @canvas.w = canvasOffsetWidth * scale
      @canvas.h = canvasOffsetHeight * scale
      @canvas.x = (@windowWidth - @canvas.w) / 2
      @canvas.y = (@windowHeight - @canvas.h) / 2
      canvasStyle.transform = "scale(#{scale}, #{scale})"
      canvasStyle.left = "calc((-#{canvasOffsetWidth}px * (1 - #{scale})) / 2 + (#{@windowWidth}px - #{canvasOffsetWidth}px * #{scale}) / 2)"
      canvasStyle.top = "calc((-#{canvasOffsetHeight}px * (1 - #{scale})) / 2 + (#{@windowHeight}px - #{canvasOffsetHeight}px * #{scale}) / 2)"
    on  
  #光标移动事件  
  @cursorMove: (event) ->
    sx = event.clientX - World.canvas.x
    sy = event.clientY - World.canvas.y
    @cursor =[ sx / World.scale / window.devicePixelRatio,sy / World.scale / window.devicePixelRatio]
    on
  #键盘输入
  @onKeyDown: (event) ->
    unless event.ctrlKey || event.altKey
      switch event.keyCode
        when 113 # F2
          @showFps = not @showFps
          @updateFps()
        when 115 # F4
            if @isFull()
              @cancelFullScreen()
            else
              @requestFullScreen()
        when 116 # F5
          if Utils.isNwjs()
            chrome.runtime.reload()
    @
  @isFull: ->
    document.fullScreenElement || document.mozFullScreen || document.webkitFullscreenElement
  @requestFullScreen:->
    element = document.body
    if element.requestFullScreen 
      element.requestFullScreen()
    else if element.mozRequestFullScreen
      element.mozRequestFullScreen()
    else if element.webkitRequestFullScreen
      element.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT)
  @cancelFullScreen:->
    element = document 
    if document.cancelFullScreen
      document.cancelFullScreen()
    else if document.mozCancelFullScreen
      document.mozCancelFullScreen()
    else if document.webkitCancelFullScreen
      document.webkitCancelFullScreen()   
      
  #可见改变是  
  @change:->
    if document.visibilityState == 'hidden' then @hide() 
    else @acti()
    on
  #激活  
  @acti:->
    Tone.Master.mute = false
    Keyboard.active=true
    Touch.active=true
    on
  #隐藏 
  @hide:->
    Tone.Master.mute = true
    Keyboard.active=false
    Touch.active=false
    on
  #清理
  @unload:->
    PIXI.utils.clearTextureCache();
    ImageManager.clear()
  #设置事件  
  @setupEventHandlers: ->
    document.addEventListener 'mousemove', @cursorMove.bind(@)
    document.addEventListener 'keydown', @onKeyDown.bind(@)
    window.addEventListener 'resize',@resize.bind(@)
    window.addEventListener 'visibilitychange',@change.bind(@)
    window.addEventListener("unload", this.unload.bind(this));
    on
