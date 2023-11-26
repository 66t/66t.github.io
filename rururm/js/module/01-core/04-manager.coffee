#图像管理
class ImageManager
  @cache : {};
  @system : {};
  @emptyBitmap : new Bitmap(1, 1);
  @loadBitmap: (folder, filename) ->
    if filename
      url = "#{folder}/#{Utils.encodeURI(filename)}.png"
      @loadBitmapFromUrl(url)
    else
      @emptyBitmap

  @loadBitmapFromUrl: (url) ->
    cache = if url.includes("/system/") then @system else @cache
    cache[url] ?= Bitmap.load(url)

  @clear: ->
    for url, bitmap of @cache
      bitmap.destroy()
    @cache = {}
    on

  @isReady: ->
    for cache in [ @_cache, @_system ]
     for url, bitmap of cache
       if bitmap.isError()
         @throwLoadError bitmap
       unless bitmap.isReady()
         return false
    true

  @throwLoadError: (bitmap) =>
    retry = bitmap.retry.bind(bitmap)
#字体管理    
class FontManager
  @urls: {}
  @states: {}
  @load: (family, filename) ->
    return if @states[family] is "loaded"
    if filename
      url = @makeUrl(filename)
      @startLoading(family, url)
    else 
      @urls[family] = ""
      @states[family] = "loaded"
  @isReady: ->
    for family, state of @states
      return no if state is "loading"
      @throwLoadError(family) if state is "error"
    on
  @startLoading: (family, url) ->
    source = "url(#{url})"
    font = new FontFace(family, source)
    @urls[family] = url
    @states[family] = "loading"
    font.load()
      .then(() ->
       # 加载成功，将字体添加到文档中，更新字体状态为已加载
        document.fonts.add(font)
        FontManager.states[family] = "loaded"
        0
      )
      .catch(() ->
      # 加载失败，更新字体状态为错误
        FontManager.states[family] = "error"
        no
      )
  @throwLoadError: (family) ->
    # 获取加载失败的字体的URL
    url = @urls[family]
    # 定义重试函数，用于重新加载字体
    retry = -> @startLoading(family, url)
    # 抛出加载错误，包含错误类型、字体URL和重试函数
    throw ["LoadError", url, retry]
  @makeUrl: (filename) ->
  # 根据文件名生成字体URL
    "fonts/#{Utils.encodeURI(filename)}"