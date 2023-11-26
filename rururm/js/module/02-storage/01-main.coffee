class StorageData
  constructor: -> @initialize.apply(@,arguments)
  StorageData.prototype = Object.create(StorageData.prototype)
  StorageData.prototype.constructor = StorageData
  initialize: ->
    @SEED_COUNT=256 # 种子数的数量
    @SEED_LINK="-"  # 种子之间的连接符 
    @KEY_MATRIX=36  # 矩阵的大小

    @key=""         # 存储密钥的字符串
    @inn=[]         # 存储inn的数组
    @seed=""        # 存储种子的字符串
    @init_seed=""   # 初始种子字符串
    @count_seed=""  # 计数种子字符串
    @initKey()      # 初始化密钥
    @initSeed()     # 初始化种子 
    on
  Object.defineProperties StorageData::, {
    id:
      get: -> Utils.radixNum(@key.substring(0,5),36,10).padZero(8)
      configurable: true
  }

# 初始化种子
  initSeed: ->
    for i in [0...@SEED_COUNT]
      @seed += if i then @SEED_LINK else ""
      @seed += Utils.radixNum(@seedNext(Math.randomInt(65535), i), 10, 36)
      @count_seed += if i then @SEED_LINK else ""
      @count_seed += Utils.radixNum(0)
    @init_seed = @seed
    on
# 初始化密钥
  initKey: ->
    for i in [0...(@KEY_MATRIX * @KEY_MATRIX)]
      @key += Utils.radixNum(Math.randomInt(@KEY_MATRIX), 10, @KEY_MATRIX)
    on
# 根据位置获取密钥的方法
  getKey : (location) ->
    x = location % @KEY_MATRIX
    y = parseInt(location / @KEY_MATRIX) % @KEY_MATRIX
    t1 = [
      (y * @KEY_MATRIX + (x % 6))
      (y * @KEY_MATRIX + ((x + 1) % 6))
      (y * @KEY_MATRIX + ((x + 2) % 6))
      (y * @KEY_MATRIX + ((x + 3) % 6))
      (y * @KEY_MATRIX + ((x + 4) % 6))
      (y * @KEY_MATRIX + ((x + 5) % 6))
      ((y + 1) * @KEY_MATRIX + (x % 6))
      ((y + 1) * @KEY_MATRIX + ((x + 1) % 6))
      ((y + 1) * @KEY_MATRIX + ((x + 2) % 6))
      ((y + 1) * @KEY_MATRIX + ((x + 3) % 6))
      ((y + 1) * @KEY_MATRIX + ((x + 4) % 6))
      ((y + 1) * @KEY_MATRIX + ((x + 5) % 6))
      ((y + 2) * @KEY_MATRIX + (x % 6))
      ((y + 2) * @KEY_MATRIX + ((x + 1) % 6))
      ((y + 2) * @KEY_MATRIX + ((x + 2) % 6))
      ((y + 2) * @KEY_MATRIX + ((x + 3) % 6))
      ((y + 2) * @KEY_MATRIX + ((x + 4) % 6))
      ((y + 2) * @KEY_MATRIX + ((x + 5) % 6))
      ((y + 3) * @KEY_MATRIX + (x % 6))
      ((y + 3) * @KEY_MATRIX + ((x + 1) % 6))
      ((y + 3) * @KEY_MATRIX + ((x + 2) % 6))
      ((y + 3) * @KEY_MATRIX + ((x + 3) % 6))
      ((y + 3) * @KEY_MATRIX + ((x + 4) % 6))
      ((y + 3) * @KEY_MATRIX + ((x + 5) % 6))
      ((y + 4) * @KEY_MATRIX + (x % 6))
      ((y + 4) * @KEY_MATRIX + ((x + 1) % 6))
      ((y + 4) * @KEY_MATRIX + ((x + 2) % 6))
      ((y + 4) * @KEY_MATRIX + ((x + 3) % 6))
      ((y + 4) * @KEY_MATRIX + ((x + 4) % 6))
      ((y + 4) * @KEY_MATRIX + ((x + 5) % 6))
      ((y + 5) * @KEY_MATRIX + (x % 6))
      ((y + 5) * @KEY_MATRIX + ((x + 1) % 6))
      ((y + 5) * @KEY_MATRIX + ((x + 2) % 6))
      ((y + 5) * @KEY_MATRIX + ((x + 3) % 6))
      ((y + 5) * @KEY_MATRIX + ((x + 4) % 6))
      ((y + 5) * @KEY_MATRIX + ((x + 5) % 6))
    ]
    t2 = [
      (x * @KEY_MATRIX + (y % 6))
      (x * @KEY_MATRIX + ((y + 1) % 6))
      (x * @KEY_MATRIX + ((y + 2) % 6))
      (x * @KEY_MATRIX + ((y + 3) % 6))
      (x * @KEY_MATRIX + ((y + 4) % 6))
      (x * @KEY_MATRIX + ((y + 5) % 6))
      ((x + 1) * @KEY_MATRIX + (y % 6))
      ((x + 1) * @KEY_MATRIX + ((y + 1) % 6))
      ((x + 1) * @KEY_MATRIX + ((y + 2) % 6))
      ((x + 1) * @KEY_MATRIX + ((y + 3) % 6))
      ((x + 1) * @KEY_MATRIX + ((y + 4) % 6))
      ((x + 1) * @KEY_MATRIX + ((y + 5) % 6))
      ((x + 2) * @KEY_MATRIX + (y % 6))
      ((x + 2) * @KEY_MATRIX + ((y + 1) % 6))
      ((x + 2) * @KEY_MATRIX + ((y + 2) % 6))
      ((x + 2) * @KEY_MATRIX + ((y + 3) % 6))
      ((x + 2) * @KEY_MATRIX + ((y + 4) % 6))
      ((x + 2) * @KEY_MATRIX + ((y + 5) % 6))
      ((x + 3) * @KEY_MATRIX + (y % 6))
      ((x + 3) * @KEY_MATRIX + ((y + 1) % 6))
      ((x + 3) * @KEY_MATRIX + ((y + 2) % 6))
      ((x + 3) * @KEY_MATRIX + ((y + 3) % 6))
      ((x + 3) * @KEY_MATRIX + ((y + 4) % 6))
      ((x + 3) * @KEY_MATRIX + ((y + 5) % 6))
      ((x + 4) * @KEY_MATRIX + (y % 6))
      ((x + 4) * @KEY_MATRIX + ((y + 1) % 6))
      ((x + 4) * @KEY_MATRIX + ((y + 2) % 6))
      ((x + 4) * @KEY_MATRIX + ((y + 3) % 6))
      ((x + 4) * @KEY_MATRIX + ((y + 4) % 6))
      ((x + 4) * @KEY_MATRIX + ((y + 5) % 6))
      ((x + 5) * @KEY_MATRIX + (y % 6))
      ((x + 5) * @KEY_MATRIX + ((y + 1) % 6))
      ((x + 5) * @KEY_MATRIX + ((y + 2) % 6))
      ((x + 5) * @KEY_MATRIX + ((y + 3) % 6))
      ((x + 5) * @KEY_MATRIX + ((y + 4) % 6))
      ((+ 5) * @KEY_MATRIX + ((y + 5) % 6))
    ]
    for i in [0...t1.length]
      t1[i] = parseInt(Utils.radixNum(@key[t1[i]], @KEY_MATRIX, 10))

    for i in [0...t2.length]
      t2[i] = parseInt(Utils.radixNum(@key[t2[i]], @KEY_MATRIX, 10))

    result1 =
      (t1[0] * t1[11] * t1[16] * t1[21] * t1[26] * t1[31] +
        t1[1] * t1[6] * t1[17] * t1[22] * t1[27] * t1[32] +
        t1[2] * t1[7] * t1[12] * t1[23] * t1[28] * t1[33] +
        t1[3] * t1[8] * t1[13] * t1[18] * t1[29] * t1[34] +
        t1[4] * t1[9] * t1[14] * t1[19] * t1[24] * t1[35] +
        t1[5] * t1[10] * t1[15] * t1[20] * t1[25] * t1[30]) -
        (t1[0] * t1[7] * t1[14] * t1[21] * t1[28] * t1[35] +
          t1[1] * t1[8] * t1[15] * t1[22] * t1[29] * t1[30] +
          t1[2] * t1[9] * t1[16] * t1[23] * t1[24] * t1[31] +
          t1[3] * t1[10] * t1[17] * t1[18] * t1[25] * t1[32] +
          t1[4] * t1[11] * t1[12] * t1[19] * t1[26] * t1[33] +
          t1[5] * t1[6] * t1[13] * t1[20] * t1[27] * t1[34])
    result2 =
      (t2[0] * t2[11] * t2[16] * t2[21] * t2[26] * t2[31] +
        t2[1] * t2[6] * t2[17] * t2[22] * t2[27] * t2[32] +
        t2[2] * t2[7] * t2[12] * t2[23] * t2[28] * t2[33] +
        t2[3] * t2[8] * t2[13] * t2[18] * t2[29] * t2[34] +
        t2[4] * t2[9] * t2[14] * t2[19] * t2[24] * t2[35] +
        t2[5] * t2[10] * t2[15] * t2[20] * t2[25] * t2[30]) -
        (t2[0] * t2[7] * t2[14] * t2[21] * t2[28] * t2[35] +
          t2[1] * t2[8] * t2[15] * t2[22] * t2[29] * t2[30] +
          t2[2] * t2[9] * t2[16] * t2[23] * t2[24] * t2[31] +
          t2[3] * t2[10] * t2[17] * t2[18] * t2[25] * t2[32] +
          t2[4] * t2[11] * t2[12] * t2[19] * t2[26] * t2[33] +
          t2[5] * t2[6] * t2[13] * t2[20] * t2[27] * t2[34])
    [result1, result2]
# 根据位置和值获取密钥编号的方法
  keyNumber: (location, val) ->
    arr = @getKey(location)
    Utils.radixNum((val - arr[1] * -2) * (arr[0] + 3), 10, 36)
# 根据位置和值获取值编号的方法
  valueNumber: (location, val) ->
    arr = @getKey(location)
    Math.round(Utils.radixNum(val, 36, 10) / (arr[0] + 3) - arr[1] * 2)
# 根据位置获取 inn 的值  
  getInn: (location) ->
    x = location % @KEY_MATRIX
    y = parseInt location/@KEY_MATRIX
    unless @inn[y] then @inn[y] = []
    unless @inn[y][x] then @inn[y][x] = @keyNumber location  0
    @valueNumber location @inn[y][x]
# 设置 inn 的值
  setInn: (location, val) ->
    x = location % @KEY_MATRIX
    y = parseInt(location / @KEY_MATRIX)
    unless @inn[y] then @inn[y] = []
    @inn[y][x] = @keyNumber(location, val)
    on
# 返回未使用的 inn 位置
  idleInn: ->
    c = 0
    for item of @inn
      for i in [0...@KEY_MATRIX]
        return c * @KEY_MATRIX + i unless @inn[c][i]
      c++
    c * @KEY_MATRIX
# 根据模式和最大值获取种子值
  pro : (mode, promax) -> @getSeed(mode)  % (promax or 100)
# 获取种子值的方法
  getSeed : (mode) ->
    seed_arr = @seed.split(@SEED_LINK)
    seed_count = @count_seed.split(@SEED_LINK)
    seed = @seedNext(Utils.radixNum(seed_arr[mode % @SEED_COUNT], 36, 10), mode % @SEED_COUNT)
    seed_arr[mode % @SEED_COUNT] = Utils.radixNum(seed, 10, 36)
    seed_count[mode % @SEED_COUNT]++
    @count_seed = seed_count.join(@SEED_LINK)
    @seed = seed_arr.join(@SEED_LINK)
    seed
# 计算下一个种子值的方法
  seedNext : (seed, mode) ->
    switch mode % 4
      when 0 then seed = (seed * 3877 + 139968) % 29573
      when 1 then seed = (seed * 421 + 259200) % 54773
      when 2 then seed = (seed * 9301 + 49297) % 233280
      when 3 then seed = (seed * 281 + 134456) % 28411
    Math.round(seed)


LIM.$data = new StorageData()    