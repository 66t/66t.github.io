#场景-实例
class Stage
  constructor: -> @initialize.apply(@,arguments)
  Stage.prototype = Object.create(PIXI.Container.prototype)
  Stage.prototype.constructor = Stage
  #初始化
  initialize : ->
    PIXI.Container.call(@)
    @interactive = false
    @started = false
    @active = false
    @sortableChildren = true
    on
  #销毁  
  destroy :->
    PIXI.Container.prototype.destroy.call(@,{children:true,texture:true })
    on
  #创建  
  create:->  on

  #判断 Stage 是否准备完毕  
  isReady:->
    FontManager.isReady()&&ImageManager.isReady()
  #启动 Stage  
  start:->
    @started = true
    @active = true
    on
  #更新 Stage  
  update: ->
    for child in @children
      child.update() if child.update
    on
  #从景栈中弹出当前场景  
  popScene: ->
    Scene.pop()
    on
  #停止 Stage  
  stop: -> 
    @active = false
    on
  #判断 Stage 是否处于活跃状态  
  isActive:-> @active  
  #判断 Stage 是否已经启动  
  isStarted: -> @started
  #终止运行  
  terminate: -> on

#场景-静态    
class Scene
  #当前场景
  @scene : null
  #下一个场景
  @nextScene : null
  #场景栈
  @stack : []
  #退出标记
  @exiting : false
  #前一个场景对象
  @previousScene : null
  #前一个场景类
  @previousClass : null
  #平滑计算游戏帧
  @smoothDeltaTime : 1
  #帧间隔时间
  @elapsedTime : 0
  #启动游戏引擎并切换到指定的场景类
  @run: (sceneClass) ->
    try
      @initialize()
      @goto(sceneClass)
      World.startGame()
      on
    catch e
      no
  #初始化游戏    
  @initialize: ->
    @initWorld()
    on
  #初始化世界
  @initWorld: ->
    World.init()
    World.setTick(@update.bind(@))
    on
  #更新游戏逻辑
  @update: (deltaTime) ->
    try
      n = @determineRepeatNumber(deltaTime)
      for i in [0...n]
        @updateMain()
    catch e
    on
  #主更新方法，负责处理场景切换、场景更新和操作更新
  @updateMain: ->
    @changeScene()
    @updateScene()
    @updateOperate()
    on
  #更新操作，键盘和触摸操作的更新。  
  @updateOperate:->
    Keyboard.update()
    Touch.update()
    on
  #决定需要重复执行的次数，以实现平滑的游戏逻辑更新。  
  @determineRepeatNumber: (deltaTime) ->
    @smoothDeltaTime *= 0.8
    @smoothDeltaTime += Math.min(deltaTime, 2) * 0.2
    if @smoothDeltaTime >= 0.9
      @elapsedTime = 0
      Math.round(@smoothDeltaTime)
    else
      @elapsedTime += deltaTime
      if @elapsedTime >= 1
        @elapsedTime -= 1
        1
      else
        0
    on
  #终止游戏  
  @terminate: ->
    if Utils.isNwjs()
      nw.App.quit()
      on
  #处理场景切换逻辑，包括场景的销毁和新场景的创建    
  @changeScene: ->
    if @isSceneChanging()
      if @scene
        @scene.terminate()
        @onSceneTerminate()
      @scene = @nextScene
      @nextScene = null
      if @scene
        @scene.create()
      @terminate() if @exiting
    on
  #判断是否正在切换场景  
  @isSceneChanging: ->
    @exiting or !!@nextScene
  #场景启动时的回调方法  
  @onSceneStart: ->
    World.setStage(@scene)
    on
  #场景终止时的回调方法  
  @onSceneTerminate: ->
    @previousScene = @scene
    @previousClass = @scene.constructor
    World.setStage(null)
    on
  #更新当前场景的逻辑  
  @updateScene: ->
    if @scene
      if @scene.isStarted()
        if @isGameActive()
          @scene.update()
      else if @scene.isReady()
        @onBeforeSceneStart()
        @scene.start()
        @onSceneStart()
    on
  #isGameActive  
  @isGameActive: ->
    try
      window.top.document.hasFocus()
    catch e
    on 
  #场景启动前的回调方法  
  @onBeforeSceneStart: ->
    if @previousScene
      @previousScene.destroy()
      @previousScene = null
    on
  #切换到指定的场景类  
  @goto: (sceneClass) ->
    @nextScene = new sceneClass() if sceneClass
    @scene.stop() if @scene
    on
  #将当前场景入栈 并切换  
  @push: (sceneClass) ->
    @stack.push(@scene.constructor)
    @goto(sceneClass)
    on
  #从场景栈中弹出一个场景  并切换 
  @pop: ->
    if @stack.length > 0
      @goto(@stack.pop())
    else
      @exit()
    on
  #退出应用程序  
  @exit: ->
    @goto(null)
    @exiting = true
    on
  #清空场景栈  
  @clearStack: ->
    @stack = []
    on
  #停止游戏引擎的运行  
  @stop: ->
    World.stopGame()
    on