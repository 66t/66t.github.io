class Conductor
  @_path:'audio'
  #音量
  @_VolVolume:1
  #音轨的音量
  @_TrajeVolume:[]
  #流
  @_Buffer:{}
  #自增id
  @_id:0
  #生成
  @play:(id) ->
    data=LIM.audio[id]
   
    if(data)
      player = new Tone.Player().toDestination()
      player._id=++@_id
      player.ep=data
      player.traje=data.traje
      @vol(player,data.volume||0,data.traje||0)
      @fade(player,data.fade) if data.fade
      @rate(player,data.rate) if data.rate
      @rever(player,data.rever) if data.rever
      @loop(player,data.loop) if data.loop
      @src(player,data.type,data.name,data.time)
      @pan(player,data.pan) if data.pan
      @dis(player,data.dis) if data.dis
      @filter(player,data.filter) if data.filter
    on
  #音量
  @vol:(player,val,traje) ->
    baseVol=@_VolVolume*(@_TrajeVolume[traje]||1)
    vol=val*baseVol
    player.volume.value = 12 * Math.log10 vol/10
    on
  #淡入淡出  
  @fade:(player,val)->
    player.fadeIn = val[0]
    player.fadeOut = val[1]
    on
  #播放速度  
  @rate:(player,val)->
    player.playbackRate = val
    on
  #倒放  
  @rever:(player,val)->
    player.reverse = val
    on
  #循环  
  @loop:(player,val)->
    player.loop=val[0] 
    if player.loop
      player.loopStart = val[1]
      player.loopEnd = val[2]
    on  
  #音道
  @pan:(player,val)->
    if !player.u_pan 
      panner = new Tone.Panner()
      player.connect(panner)
      player.u_pan=panner
      panner.toDestination()
    panner.pan.value = val  
    on
  #失真
  @dis:(player,val) ->
    if !player.u_dis
      distortion = new Tone.Distortion()
      player.connect(distortion)
      player.u_dis=distortion
      distortion.toDestination()
    distortion.distortion = val[0]
    distortion.oversample = val[1]
    on  
  @filter:(player,val) ->
    if !player.u_filter
      filter = new Tone.Filter({
        type: val[0],
        frequency: val[1],
        rolloff: val[2],
        Q: val[3],
        gain:val[4],
      })
      player.u_filter=filter
      player.connect(filter)
      filter.toDestination()
  #读取文件  
  @src:(player,type,name,time)->
    src ="#{@_path}/#{type}/#{name}.ogg"
    that=@
    player.load(src)
    .then(()-> 
      that.start player, time
      on
    )
    on
  #开始播放  
  @start:(player,time)->
    player.start "+0", time[0]
    if time[1]
      timeout=(time[1] - player.fadeOut) * 1000 / player.playbackRate
      if player.traje
        #有音轨时 设置一个定时器 到时会检查id是否一致
        setTimeout ( ->
          if Conductor._Buffer[player.traje]._id==player._id
            player.stop(player.fadeOut)
            Conductor._Buffer[player.traje] = null
            on
          on
        ), timeout
      else
       #没有音轨 设置一个定时器 来停止播放
       setTimeout ( ->
         player.stop(player.fadeOut)
         on
         ), timeout
    #设置音轨    
    if player.traje
      old=Conductor._Buffer[player.traje]
      old.stop(old.fadeOut) if old
      Conductor._Buffer[player.traje]=player  
    on
    