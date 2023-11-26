class StorageSave
  @key :CryptoJS.enc.Hex.parse('123318efc4b6388888af51a6cd932b12')

  @makeSaveContents: (savefileId) ->
    contents = {}
    if savefileId < 0
      contents.storage = {}
    else if savefileId == 0
      contents.storage = {}
    else
      contents.storage =
        key: LIM.$data.key
        seed: LIM.$data.seed
        init_seed: LIM.$data.init_seed
        count_seed: LIM.$data.count_seed
        inn: LIM.$data.inn
        bool: LIM.$bool.arr
        number: LIM.$number.arr
        
    contentsString = JSON.stringify(contents)
    encrypted = CryptoJS.AES.encrypt(contentsString, CryptoJS.enc.Utf8.parse(@key), mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.Pkcs7)
    encrypted.toString()
    
  @loadSaveContents: (savefileId, data) ->
    return unless data
    contents = JSON.parse(CryptoJS.AES.decrypt(data, CryptoJS.enc.Utf8.parse(@key), mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.Pkcs7).toString(CryptoJS.enc.Utf8))
    if savefileId < 0
      on
    else if savefileId == 0
      on
    else
      LIM.$data.key = contents.storage.key
      LIM.$data.seed = contents.storage.seed
      LIM.$data.init_seed = contents.storage.init_seed
      LIM.$data.count_seed = contents.storage.count_seed
      LIM.$data.inn = contents.storage.inn
      LIM.$bool.arr = contents.storage.bool
      LIM.$number.arr = contents.storage.number
      on
    
  @save: (savefileId) ->
    if Utils.isNwjs()
      @saveToLocalFile(savefileId, @makeSaveContents(savefileId))
    else
      @saveToWebStorage(savefileId, @makeSaveContents(savefileId))
    on  

  @load: (savefileId) ->
    if Utils.isNwjs()
      @loadSaveContents(savefileId, @loadFromLocalFile(savefileId))
    else
      @loadSaveContents(savefileId, @loadFromWebStorage(savefileId))
    on
    
  @saveToLocalFile: (savefileId, json) ->
    fs = require('fs')
    dirPath = @localFileDirectoryPath()
    filePath = @localFilePath(savefileId)
    fs.mkdirSync(dirPath) unless fs.existsSync(dirPath)
    fs.writeFileSync(filePath, json)
    on

  @loadFromLocalFile: (savefileId) ->
    data = null
    fs = require('fs')
    filePath = @localFilePath(savefileId)
    data = fs.readFileSync(filePath, encoding: 'utf8') if fs.existsSync(filePath)
    data

  @saveToWebStorage: (savefileId, json) ->
    key = @webStorageKey(savefileId)
    localStorage.setItem(key, json)
    on

  @loadFromWebStorage: (savefileId) ->
    key = @webStorageKey(savefileId)
    data = localStorage.getItem(key)
    data
    
  @localFileDirectoryPath: ->
    path = require('path')
    base = path.dirname(process.mainModule.filename)
    path.join(base, 'save/')

  @localFilePath: (savefileId) ->
    name = if savefileId < 0 then 'config.lim' else if savefileId == 0 then 'global.lim' else 'save%1.lim'.format(savefileId)
    @localFileDirectoryPath() + name
    
  @webStorageKey: (savefileId) ->
    if savefileId < 0 then 'RPG Config' else if savefileId == 0 then 'LIM Global' else 'LIM save%1'.format(savefileId)