#矩形
class Rectangle
  constructor: -> @initialize.apply(@,arguments)
  Rectangle.prototype = Object.create(PIXI.Rectangle.prototype)
  Rectangle.prototype.constructor = Rectangle
  initialize:(x, y, width, height)->
    PIXI.Rectangle.call(@,x,y,width,height)
#基础滤镜
class ColorFilter
  constructor: ->
    @initialize.apply(@, arguments)

  ColorFilter.prototype = Object.create(PIXI.Filter.prototype)
  ColorFilter.prototype.constructor = ColorFilter

  initialize: ->
    PIXI.Filter.call(@, null, @_fragmentSrc())
    @uniforms.hue = 0
    @uniforms.colorTone = [0, 0, 0, 0]
    @uniforms.blendColor = [0, 0, 0, 0]
    @uniforms.brightness = 255
    on
  setHue: (hue) ->  
    @uniforms.hue = Number(hue)
    on
  setColorTone: (tone) ->
    throw new Error("Argument must be an array") unless tone instanceof Array
    @uniforms.colorTone = tone.clone()
    on
  setBlendColor: (color) ->
    throw new Error("Argument must be an array") unless color instanceof Array
    @uniforms.blendColor = color.clone()
    on
  setBrightness: (brightness) ->
    @uniforms.brightness = Number(brightness)
    on
  _fragmentSrc: ->
    src = """
      varying vec2 vTextureCoord;
      uniform sampler2D uSampler;
      uniform float hue;
      uniform vec4 colorTone;
      uniform vec4 blendColor;
      uniform float brightness;

      vec3 rgbToHsl(vec3 rgb) {
         float r = rgb.r;
         float g = rgb.g;
         float b = rgb.b;
         float cmin = min(r, min(g, b));
         float cmax = max(r, max(g, b));
         float h = 0.0;
         float s = 0.0;
         float l = (cmin + cmax) / 2.0;
         float delta = cmax - cmin;
         if (delta > 0.0) {
           if (r == cmax) {
             h = mod((g - b) / delta + 6.0, 6.0) / 6.0;
           } else if (g == cmax) {
             h = ((b - r) / delta + 2.0) / 6.0;
           } else {
             h = ((r - g) / delta + 4.0) / 6.0;
           }
           if (l < 1.0) {
             s = delta / (1.0 - abs(2.0 * l - 1.0));
           }
         }
         return vec3(h, s, l);
      }

      vec3 hslToRgb(vec3 hsl) {
         float h = hsl.x;
         float s = hsl.y;
         float l = hsl.z;
         float c = (1.0 - abs(2.0 * l - 1.0)) * s;
         float x = c * (1.0 - abs((mod(h * 6.0, 2.0)) - 1.0));
         float m = l - c / 2.0;
         float cm = c + m;
         float xm = x + m;
         if (h < 1.0 / 6.0) {
           return vec3(cm, xm, m);
         } else if (h < 2.0 / 6.0) {
           return vec3(xm, cm, m);
         } else if (h < 3.0 / 6.0) {
           return vec3(m, cm, xm);
         } else if (h < 4.0 / 6.0) {
           return vec3(m, xm, cm);
         } else if (h < 5.0 / 6.0) {
           return vec3(xm, m, cm);
         } else {
           return vec3(cm, m, xm);
         }
      }

      void main() {
        vec4 sample = texture2D(uSampler, vTextureCoord);
        float a = sample.a;
        vec3 hsl = rgbToHsl(sample.rgb);
        hsl.x = mod(hsl.x + hue / 360.0, 1.0);
        hsl.y = hsl.y * (1.0 - colorTone.a / 255.0);
        vec3 rgb = hslToRgb(hsl);
        float r = rgb.r;
        float g = rgb.g;
        float b = rgb.b;
        float r2 = colorTone.r / 255.0;
        float g2 = colorTone.g / 255.0;
        float b2 = colorTone.b / 255.0;
        float r3 = blendColor.r / 255.0;
        float g3 = blendColor.g / 255.0;
        float b3 = blendColor.b / 255.0;
        float i3 = blendColor.a / 255.0;
        float i1 = 1.0 - i3;

        r = clamp((r / a + r2) * a, 0.0, 1.0);
        g = clamp((g / a + g2) * a, 0.0, 1.0);
        b = clamp((b / a + b2) * a, 0.0, 1.0);
        r = clamp(r * i1 + r3 * i3 * a, 0.0, 1.0);
        g = clamp(g * i1 + g3 * i3 * a, 0.0, 1.0);
        b = clamp(b * i1 + b3 * i3 * a, 0.0, 1.0);
        r = r * brightness / 255.0;
        g = g * brightness / 255.0;
        b = b * brightness / 255.0;
        gl_FragColor = vec4(r, g, b, a);
      }
    """
    src  
#图形
class Shape
  constructor: -> @initialize.apply(@,arguments)
  Shape.prototype = Object.create(PIXI.Sprite.prototype)
  Shape.prototype.constructor = Shape
  #用于存储一个空的PIXI BaseTexture 对象
  @emptyBaseTexture = null;
  #用于生成每个Shape对象的唯一标识符
  @counter = 0;
  #初始化Shape对象。接受一个参数bitmap，用于设置对象的位图。
  initialize:(bitmap)->
    if not Shape.emptyBaseTexture
      Shape.emptyBaseTexture = new PIXI.BaseTexture()
      Shape.emptyBaseTexture.setSize(1 ,1) 
    frame = new Rectangle()
    texture = new PIXI.Texture(Shape.emptyBaseTexture, frame)
    PIXI.Sprite.call(@,texture)
    spriteId = Shape.counter++
    @_bitmap = bitmap
    @_frame = frame
    @_hue = 0
    @_blendColor = [0, 0, 0, 0]
    @_colorTone = [0, 0, 0, 0]
    @_colorFilter = null
    @_blendMode = PIXI.BLEND_MODES.NORMAL
    @_hidden = false
    @_onBitmapChange()
    on
  #销毁Shape对象及其子对象和纹理资源  
  destroy: ->
    options = {children: true, texture: true}
    PIXI.Sprite.prototype.destroy.call(@, options)
    on
  #更新Shape对象及其子对象的状态  
  update: ->
    for child in @children
      child.update() if child.update
    on
  #隐藏Shape对象，使其不可见  
  hide: ->
    @_hidden = true
    @updateVisibility()
    on
  #显示Shape对象，使其可见。  
  show: ->
    @_hidden = false
    @updateVisibility()
    on
  #根据_hidden属性更新Shape对象的可见性  
  updateVisibility: ->
    @visible = not @_hidden
    on
  #移动Shape对象到指定的坐标(x, y)  
  move: (x, y) ->
    @x = x
    @y = y
    on
  #设置Shape对象显示的部分的位置和大小。  
  setFrame: (x, y, width, height) ->
    @_refreshFrame = false
    frame = @_frame
    if x isnt frame.x or y isnt frame.y or width isnt frame.width or height isnt frame.height
      frame.x = x
      frame.y = y
      frame.width = width
      frame.height = height
      @_refresh()
    on
  #设置Shape对象的色调
  setHue: (hue) ->
    if @_hue isnt Number(hue)
      @_hue = Number(hue)
      @_updateColorFilter()
    on 
  #获取Shape对象的混合颜色  
  getBlendColor: ->
    @_blendColor.clone()
  #设置Shape对象的混合颜色  
  setBlendColor: (color) ->
    if not @_blendColor.equals(color)
      @_blendColor = color.clone()
      @_updateColorFilter()
    on
  #获取Shape对象的颜色色调  
  getColorTone: ->
    @_colorTone.clone()
  #设置Shape对象的颜色色调  
  setColorTone: (tone) ->
    if not @_colorTone.equals(tone)
      @_colorTone = tone.clone()
      @_updateColorFilter()
    on
  #当位图（bitmap）发生变化时调用的内部方法  
  _onBitmapChange: ->
    if @_bitmap
      @_refreshFrame = true
      @_bitmap.addLoadListener(@_onBitmapLoad.bind(@))
    else
      @_refreshFrame = false
      @texture.frame = new Rectangle()
    on 
  #当位图加载完成时调用的内部方法  
  _onBitmapLoad: (bitmapLoaded) ->
    if bitmapLoaded is @_bitmap
      if @_refreshFrame and @_bitmap
        @_refreshFrame = false
        @_frame.width = @_bitmap.width
        @_frame.height = @_bitmap.height
    @_refresh()
    on
  #创建颜色滤镜对象的内部方法  
  _createColorFilter: ->
    @_colorFilter = new ColorFilter()
    if not @filters
      @filters = []
    @filters.push(@_colorFilter)
    on
   #更新颜色滤镜对象的内部方法 
  _updateColorFilter: ->
    console.log(1)
    if not @_colorFilter
      @_createColorFilter()
    @_colorFilter.setHue(@_hue)
    @_colorFilter.setBlendColor(@_blendColor)
    @_colorFilter.setColorTone(@_colorTone)
    on
  #刷新Shape对象的纹理和帧属性  
  _refresh: ->
    texture = @texture
    frameX = Math.floor(@_frame.x)
    frameY = Math.floor(@_frame.y)
    frameW = Math.floor(@_frame.width)
    frameH = Math.floor(@_frame.height)
    baseTexture = if @_bitmap then @_bitmap.baseTexture else null
    baseTextureW = if baseTexture then baseTexture.width else 0
    baseTextureH = if baseTexture then baseTexture.height else 0
    realX = frameX.clamp(0, baseTextureW)
    realY = frameY.clamp(0, baseTextureH)
    realW = (frameW - realX + frameX).clamp(0, baseTextureW - realX)
    realH = (frameH - realY + frameY).clamp(0, baseTextureH - realY)
    frame = new Rectangle(realX, realY, realW, realH)
    if texture
      @pivot.x = frameX - realX
      @pivot.y = frameY - realY
      if baseTexture
        texture.baseTexture = baseTexture
        try
          texture.frame = frame
        catch e
          texture.frame = new Rectangle()
    on

# 属性访问器
  Object.defineProperties Shape::, {
    bitmap:
      get: -> @_bitmap
      set: (value) ->
        if @_bitmap isnt value
          @_bitmap = value
          @_onBitmapChange()
        on
      configurable: true
    width:
      get: -> @_frame.width
      set: (value) ->
        @_frame.width = value
        @_refresh()
        on
      configurable: true
    height:
      get: -> @_frame.height
      set: (value) ->
        @_frame.height = value
        @_refresh()
        on
      configurable: true
    opacity:
      get: -> @alpha * 255
      set: (value) ->
        @alpha = Math.clamp(value, 0, 255) / 255
        on
      configurable: true
    blendMode:
      get: ->
       if @_colorFilter
        @_colorFilter.blendMode
       else
       @_blendMode
      set: (value) ->
        @_blendMode = value
        if @_colorFilter
          @_colorFilter.blendMode = value
        on
      configurable: true
  }
#位图  
class Bitmap
  constructor: -> @initialize.apply(@,arguments)
  Bitmap.prototype = Object.create(Bitmap.prototype)
  Bitmap.prototype.constructor = Bitmap
  #创建一个新的Bitmap对象并初始化它，然后设置Bitmap的_url属性为指定的URL，并开始加载图像。返回Bitmap对象。 
  @load:(url) ->
    bitmap = new Bitmap()
    bitmap.initialize()
    bitmap._url = url
    bitmap._startLoading()
    bitmap
  #创建一个新的Bitmap对象，并将舞台(stage)渲染到该对象上。返回渲染后的Bitmap对象。
  @snap:(stage) ->
    width = World.canvasWidth
    height = World.canvasHeight
    bitmap = new Bitmap(width,height)
    renderTexture = PIXI.RenderTexture.create(width,height)
    if stage
      renderer = World.app.renderer
      renderer.render(stage,renderTexture)
      stage.worldTransform.identity()
      canvas = renderer.extract.canvas(renderTexture)
      bitmap.context.drawImage(canvas, 0, 0)
      canvas.width = 0
      canvas.height = 0
    renderTexture.destroy {destroyBase:true}
    bitmap.baseTexture.update()
    bitmap
  #初始化Bitmap对象，设置各种属性，包括画布(canvas)、上下文(context)、基础纹理(baseTexture)等。
  initialize: (width, height) ->
    @_canvas = null
    @_context = null
    @_baseTexture = null
    @_image = null
    @_url = ""
    @_paintOpacity = 255
    @_smooth = true
    @_loadListeners = []
    @_loadingState = "none"
    if width > 0 and height > 0
      @_createCanvas(width, height)
    @fontFace = "sans-serif"
    @fontSize = 16
    @fontBold = false
    @fontItalic = false
    @textColor = "#ffffff"
    @outlineColor = "rgba(0, 0, 0, 0.5)"
    @outlineWidth = 3
    on
  #检查Bitmap对象是否已加载并准备好使用。
  isReady : ->
    @_loadingState is "loaded" || @_loadingState is "none"
  #检查Bitmap对象是否加载过程中发生了错误。
  isError : -> 
    @_loadingState is "error"
  #销毁Bitmap对象，释放关联的资源。
  destroy : ->
    if @_baseTexture
      @_baseTexture.destroy()
      @_baseTexture = null
    @_destroyCanvas()
    on
  #调整Bitmap对象的宽度和高度。
  resize: (width, height) ->
    width = Math.max(width || 0, 1)
    height = Math.max(height || 0, 1)
    @canvas.width = width
    @canvas.height = height
    @baseTexture.width = width
    @baseTexture.height = height
    on
  #将源图像的一部分复制到Bitmap对象上。
  blt: (source, sx, sy, sw, sh, dx, dy, dw, dh) ->
    dw = dw or sw
    dh = dh or sh
    try
      image = source._canvas or source._image
      @context.globalCompositeOperation = "source-over"
      @context.drawImage(image, sx, sy, sw, sh, dx, dy, dw, dh)
      @_baseTexture.update()
      on
    catch e    
      on
  
  #添加一个加载监听器，用于在Bitmap对象加载完成时触发。
  addLoadListener: (listener) ->
    unless @isReady()
      @_loadListeners.push(listener)
      on
    else
      listener(@)
      on
  #获取Bitmap对象指定坐标位置的像素颜色。
  getPixel: (x, y) ->
    data = @context.getImageData(x, y, 1, 1).data
    result = "#"
    for i in [0..2]
      result += data[i].toString(16).padZero(2)
    result
  #获取Bitmap对象指定坐标位置的像素的Alpha通道值。
  getAlphaPixel: (x, y) ->
    data = @context.getImageData(x, y, 1, 1).data
    data[3]
  #在Bitmap对象上的指定矩形区域内清除像素。
  clearRect: (x, y, width, height) ->
    @context.clearRect(x, y, width, height)
    @_baseTexture.update()
  #清除整个Bitmap对象的内容。    
  clear: ->
    @clearRect(0, 0, @width, @height)
  #在Bitmap对象上的指定矩形区域内填充颜色。
  fillRect: (x, y, width, height, color) ->
    context = @context
    context.save()
    context.fillStyle = color
    context.fillRect(x, y, width, height)
    context.restore()
    @_baseTexture.update()
    on
  #在整个Bitmap对象上填充指定颜色。
  fillAll: (color) ->
    @fillRect(0, 0, @width, @height, color)
    on
  #在Bitmap对象上的指定矩形区域内绘制轮廓。
  strokeRect: (x, y, width, height, color) ->
    context = @context
    context.save()
    context.strokeStyle = color
    context.strokeRect(x, y, width, height)
    context.restore()
    @_baseTexture.update()
    on
  #在Bitmap对象上的矩形区域内使用渐变颜色填充。
  gradientFillRect: (x, y, width, height, color1, color2, vertical) ->
    context = @context
    x1 = if vertical then x else x + width
    y1 = if vertical then y + height else y
    grad = context.createLinearGradient(x, y, x1, y1)
    grad.addColorStop(0, color1)
    grad.addColorStop(1, color2)
    context.save()
    context.fillStyle = grad
    context.fillRect(x, y, width, height)
    context.restore()
    @_baseTexture.update()
    on
  #在Bitmap对象上绘制一个圆形。
  drawCircle: (x, y, radius, color) ->
    context = @context
    context.save()
    context.fillStyle = color
    context.beginPath()
    context.arc(x, y, radius, 0, Math.PI * 2, false)
    context.fill()
    context.restore()
    @_baseTexture.update()
    on
  #在Bitmap对象上绘制文本。
  drawText: (text, x, y, maxWidth, lineHeight, align) ->
    context = @context
    alpha = context.globalAlpha
    maxWidth = maxWidth or 0xffffffff
    tx = x
    ty = Math.round(y + lineHeight / 2 + @fontSize * 0.35)
    if align is "center"
      tx += maxWidth / 2
    else if align is "right"
      tx += maxWidth
    context.save()
    context.font = @_makeFontNameText()
    context.textAlign = align
    context.textBaseline = "alphabetic"
    context.globalAlpha = 1
    @_drawTextOutline(text, tx, ty, maxWidth)
    context.globalAlpha = alpha
    @_drawTextBody(text, tx, ty, maxWidth)
    context.restore()
    @_baseTexture.update()
    on
  #测量绘制指定文本所需的宽度。
  measureTextWidth: (text) ->
    context = @context
    context.save()
    context.font = @_makeFontNameText()
    width = context.measureText(text).width
    context.restore()
    width
  #添加一个加载监听器，用于在Bitmap对象加载完成时触发。
  addLoadListener: (listener) ->
    if not @isReady()
      @_loadListeners.push(listener)
    else
      listener(@)
  #重新尝试加载Bitmap对象的图像资源。
  retry: ->
    @_startLoading()
    on
  #确保Canvas存在，如果没有则创建一个。
  _ensureCanvas: ->
    unless @_canvas
      if @_image
        @_createCanvas(@_image.width, @_image.height)
        @_context.drawImage(@_image, 0, 0)
      else
        @_createCanvas(0, 0)
    on
  #创建并设置Bitmap对象的基础纹理(baseTexture)属性。
  _createBaseTexture: (source) ->
    @_baseTexture = new PIXI.BaseTexture(source)
    @_baseTexture.mipmap = false
    @_baseTexture.width= source.width
    @_baseTexture.height= source.height
    @_updateScaleMode()
    on
  #销毁Bitmap对象的画布。    
  _destroyCanvas: ->
    if @_canvas
      @_canvas.width = 0
      @_canvas.height = 0
      @_canvas = null
    on  
  #创建并设置Bitmap对象的基础纹理(baseTexture)属性。
  _startLoading: ->
    @_image = new Image()
    @_image.onload = @_onLoad.bind(this)
    @_image.onerror = @_onError.bind(this)
    @_destroyCanvas()
    @_loadingState = "loading"
    @_image.src = @_url
    if @_image.width > 0
      @_image.onload = null
      @_onLoad()
    on
  #根据Bitmap对象的字体属性生成字体样式字符串。
  _makeFontNameText: ->
    italic = if @fontItalic then "Italic " else ""
    bold = if @fontBold then "Bold " else ""
    "#{italic}#{bold}#{@fontSize}px #{@fontFace}"

  #在指定位置绘制文本轮廓。
  _drawTextOutline: (text, tx, ty, maxWidth) ->
    context = @context
    context.strokeStyle = @outlineColor
    context.lineWidth = @outlineWidth
    context.lineJoin = "round"
    context.strokeText(text, tx, ty, maxWidth)
    on
  #在指定位置绘制文本内容。
  _drawTextBody: (text, tx, ty, maxWidth) ->
    context = @context
    if gradient
      metrics = context.measureText(text);
      textWidth = metrics.width;
      context.fillText(text, tx , ty, maxWidth);
    else   
      context.fillStyle = @textColor
      context.fillText(text, tx, ty, maxWidth)
    on
  #创建一个新的画布并设置其宽度和高度，同时创建与之相关联的2D上下文和基础纹理。
  _createCanvas:(width,height)->
    @_canvas = document.createElement("canvas")
    @_context = @_canvas.getContext("2d")
    @_canvas.width=width
    @_canvas.height=height
    @_createBaseTexture(@_canvas)
    on
  #图像加载完成时的回调函数，设置加载状态并触发加载监听器。
  _onLoad: ->
    @_loadingState = "loaded"
    @_createBaseTexture(@_image)
    @_callLoadListeners()
    on
  #触发所有加载监听器的回调函数。
  _callLoadListeners: ->
    while @_loadListeners.length > 0
      listener = @_loadListeners.shift()
      listener(@)
    on
  #开始加载Bitmap对象的图像资源。
  _startLoadin:->
    @_image = new Image()
    @_image.onload = @_onLoad.bind @
    @_image.onerror = @_onError.bind @
    @_destroyCanvas()
    @_loadingState = "loading"
    @_image.src = @_url
    if @_image.width > 0
      @_image.onload = null
      @_onLoad()
    on
  #更新基础纹理 对象的缩放模式，根据Bitmap对象的平滑属性选择线性或最近邻插值。
  _updateScaleMode :->
    if @_baseTexture
      if @_smooth
        @_baseTexture.scaleMode = PIXI.SCALE_MODES.LINEAR;
      else 
        @_baseTexture.scaleMode = PIXI.SCALE_MODES.NEAREST;
    on    
  #图像加载过程中发生错误时的回调函数，设置加载状态为"error"。
  _onError :->
    @_loadingState = "error";
    on
  Object.defineProperties Bitmap::, {
    url:
     get: -> @_url
     configurable: true
    baseTexture:
     get: -> @_baseTexture
     configurable: true
    image:
      get: -> @_image
      configurable: true
    canvas:
      get: ->
        @_ensureCanvas()
        @_canvas
      configurable: true
    context:
      get: ->
       @_ensureCanvas()
       @_context
      configurable: true
    width:
      get: ->
       image = @_canvas || @_image
       image.width||0
      configurable: true
    height:
      get: ->
        image = @_canvas || @_image
        image.height|| 0
      configurable: true
    rect:
      get: -> new Rectangle(0, 0, @width, @height)
      configurable: true
    smooth:
      get: -> @_smooth
      set:(value) ->
        if @_smooth isnt value
          @_smooth = value
          @_updateScaleMode()
      configurable: true
    paintOpacity:
      get: -> @_paintOpacity
      set: (value) ->
        if @_paintOpacity isnt value
          @_paintOpacity = value
          @context.globalAlpha = @_paintOpacity / 255
      configurable: true 
  }
