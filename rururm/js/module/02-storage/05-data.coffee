class StorageData
  @dataFile=[]
  @addFile:->
    @dataFile.push {src:"Lim_Audio.json",name:"audio"}
    @dataFile.push {src:"Lim_Card.json",name:"card"}
    @loadDatabase()
    on
  @loadDatabase:->
   for item in @dataFile
     @loadDataFile item.name, item.src
     on
  @loadDataFile:(name,src)->
    xhr = new XMLHttpRequest()
    url = "data/#{src}"
    LIM[name] = null
    xhr.open "GET", url
    xhr.overrideMimeType"application/json"
    xhr.onload = () => @onXhrLoad(xhr, name, src, url)
    xhr.send()
  @onXhrLoad:(xhr, name, src, url)->
    if xhr.status < 400
      LIM[name] = JSON.parse(xhr.responseText)
    on  
      
      
StorageData.addFile() 