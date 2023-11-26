 class ModuleManager
   @module = []
   @_path: ''
   @_scripts: []
   @_errorUrls: []
   @install: ->
     js={src:'js',data:[]}
     
     libs={src:'libs',data:[]}
     libs.data.push {src:"pixi"}
     libs.data.push {src:"crypto-js.min"}
     libs.data.push {src:"localforage.min"}
     libs.data.push {src:"tone"}

     
     module={src:"module",data:[]}
     
     core={src:'01-core',data:[]}
     core.data.push({src:"00-util"})
     core.data.push({src:"01-world"})
     core.data.push({src:"02-stage"})
     core.data.push({src:"03-shape"})
     core.data.push({src:"04-manager"})
     module.data.push core
     
     storage={src:'02-storage',data:[]}
     storage.data.push({src:"01-main"})
     storage.data.push({src:"02-save"})
     storage.data.push({src:"03-boolean"})
     storage.data.push({src:"04-number"})
     storage.data.push({src:"05-data"})
     module.data.push storage

     audio={src:'03-audio',data:[]}
     audio.data.push({src:"01-conductor"})
     module.data.push audio

     input={src:'04-input',data:[]}
     input.data.push({src:"01-keyboard"})
     input.data.push({src:"02-touch"})
     module.data.push input
    
     js.data.push libs
     js.data.push module
     js.data.push {src:"main"}
     @module.push js
     on
     
     
   @setup: (modules, src) ->
    for module in modules
      if module.data
        @setup module.data, "#{src}/#{module.src}"
      else
        name = "#{src}/#{module.src}.js"
        @loadScript name
        @_scripts.push name
    on
     
   @loadScript: (url) ->
    script = script = document.createElement 'script'
    script.type = 'text/javascript'
    script.src = url+"?"+(Math.random()*10000)
    script.async = false
    script._url = url
    script.onerror = @onError.bind @
    document.body.appendChild script
    on 
     
   @onError: (e) ->
    @_errorUrls.push e.target._url
    on
     
   @load: ->
    @install()
    try
     path = require 'path'
     base = path.dirname process.mainModule.filename
     @setup @module, base.slice(0, -1)
    catch e
     @setup @module, ""
    on
     
 LIM={}    
 ModuleManager.load()
   
