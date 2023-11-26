#填充0
Number::padZero = (length) -> String @.padZero length
String::padZero = (length) -> @padStart length, '0'
#替换%n字符
String::format = -> 
  @replace /%([0-9]+)/g, (s, n) -> 
    arguments[Number(n) - 1]
    
String::replaceSymbol = (arr) ->
  arr.reduce((result, value, i) -> 
    result.replace new RegExp("%\\[" + (i + 1) + "\\]", 'g'), value,@)
#字符字节长度    
String::getLen = ->
  len = 0
  l = @length
  for i in [0...l]
    if @charCodeAt(i) > 255 then len += 2 else len += 1
  len
#字符串拼接  
String::splice=(start,del,newStr) -> @slice(0, start) + (newStr||"") + @slice(start+del)
#范围取值
Number::clamp = (min, max) -> Math.min(Math.max(this, min), max)
#随机数
Math.randomInt = (max) -> Math.floor(max * Math.random())
Array::clone = -> @slice(0)

Array::equals = (array) ->
  return false if not array or @length != array.length
  for i in [0...@length]
    if @[i] instanceof Array and array[i] instanceof Array
      return false if not @[i].equals(array[i])
    else if @[i] != array[i]
      return false
  true
Object.defineProperty Array::, "equals",
  enumerable: false
Object.defineProperty Array::, "clone",
  enumerable: false
class Utils
  @escapeHtml : (str) ->
    entityMap =
      '&': '&amp;'
      '<': '&lt;'
      '>': '&gt;'
      '"': '&quot;'
      "'": '&#39;'
      '/': '&#x2F;'
    String(str).replace(/[&<>"'/]/g, (s) ->entityMap[s])
  @encodeURI : (str) ->
    encodeURIComponent(str).replace(/%2F/g, '/')
  @isNwjs : ->
    typeof require is 'function' && typeof process is 'object'
  #进制转换
  @radixNum : (num, m, n) ->
    num = if typeof num == 'string' then num else String(num)
    _DEFAULT_ = initNum: 10
    m = if m == 0 then _DEFAULT_.initNum else m
    n = if n == 0 then _DEFAULT_.initNum else n
    n = if m && !n then _DEFAULT_.initNum else n
    parseInt(num, m).toString(n)
  #rgba转16进制  
  @rpgaReduce:(r,g,b,a)->
      @radixNum(Math.min(r||255,255),10,16)+
      @radixNum(Math.min(g||255,255),10,16)+
      @radixNum(Math.min(b||255,255),10,16)+
      @radixNum(Math.min(a||255,255),10,16)
  #返回a b的最大公约数    
  @commonDiv:(a,b) -> if(b==0) then a else @commonDiv(b,a%b)
  #返回a b的最小公倍数 
  @commonMul:(a,b) ->  a*b/@commonDiv(a,b)
  #求a开b次方的方根
  @rooting:(a,b) -> Math.abs(a)**(1/b)
  #求以a为底b的对数
  @bottnum:(a,b) -> Math.log(a)/Math.log(b)
  #平面方向角计算
  @azimuth:(dual,angle,d) -> {x:dual.x+d*Math.cos(angle),y:dual.y+d*Math.sin(angle)}
  #将分子 分母简化
  @fractionOth:(son,mum)->
    div=100
    while div>1
      div=@commonDiv(son,mum)
      son/=div
      mum/=div
    [son,mum]
  #将一个小数部分写为分子式  
  @fractionExp:(num)-> @fractionOth(num,Math.pow(10,num.toString().length))
  #返回质数组
  @angelPrime = (num) ->
    arr = [2, 3]
    i = 5
    while arr.length < num
      if not arr.some((n) -> i % n is 0 and n * n <= i)
        arr.push(i)
      i += if i % 6 is 1 then 4 else 2
    arr
  #返回正态分布随机数
  @getNormalRandom = (base, d, b, sd, sb) ->
    base += 1
    d += 2
    t = @normalRandom()
    num = parseInt(base + t * if t > 0 then (sd * 5 * d) / d else if sb then (sb * 5 * b) else (sd * 5 * b) / b).clamp(base - d, base + b)
    if num <= base - d or num >= base + b
      @getNormalRandom(base - 1, d - 2, b, sd, sb)
    else
      num
  @normalRandom = ->
    u = 0.0
    v = 0.0
    w = 0.0
    c = 0.0
    loop
      u = Math.random() * 2 - 1
      v = Math.random() * 2 - 1
      w = u * u + v * v
      break if w != 0 and w <= 1
    c = Math.sqrt((-2 * Math.log(w)) / w)
    u * c
  #验证数字
  @isNum=(num) -> num!=null&&num!=''&&!isNaN(num)
  #获取骰子值
  @D=(s,seed) ->
    [numDice, numSides] = s.match(/(\d+)d(\d+)/)[1..2]
    total = 0
    for _ in [1..numDice]
      roll = if seed then LIM.$data.pro(seed, numSides) + 1 else Math.floor(Math.random() * numSides) + 1
      total += roll
    total
 
  #计算正弦
  @sinNum=(max,i) -> Math.sin(Math.PI/2/max*i).toFixed(7)
  #获取二进制位  
  @atBit= (num,bit) -> num >> bit&1
  @setBit=(num,bit,bool) -> if bool then  num | (1 << bit) else num & ~(1 << bit)
  #获得百分比屏幕像素  
  @lengthNum = (num) ->
    try
      return parseFloat(num) if !isNaN(num)
      if num.match(/(\d+)w(\d*)/)
        [_, a, b] = num.match(/(\d+)w(\d*)/)
        return parseFloat(a) * 0.01 * World.canvasWidth + parseFloat(b || 0)
      else if num.match(/(\d+)h(\d*)/)
        [_, a, b] = num.match(/(\d+)h(\d*)/)
        return parseFloat(a) * 0.01 * World.canvasHeight + parseFloat(b || 0)
      else
        return 0
    catch e
      return 0
  #打乱数组
  @shuffleArr = (arr, seed) ->
    return [] unless Array.isArray(arr)
    newArr = []
    while arr.length
      index = if seed && LIM.$data then LIM.$data.pro(seed, arr.length) else Math.floor(Math.random() * arr.length)
      newArr.push(arr.splice(index, 1)[0])
    newArr
  #计数排序
  @countingSort = (arr) ->
    return arr if arr.length <= 1
    min = Math.min.apply(null, arr)
    count = []
    result = []
    index = 0
    count[num - min] ?= 0 for num in arr
    count[num - min]++ for num in arr
    result[index++] = i + min while count[i]-- > 0 for i in [0...count.length]
    result
  #快速排序
  @quickSort = (arr) ->
    return arr if arr.length <= 1
    pivot = arr.splice(Math.floor(arr.length / 2), 1)[0]
    left = []
    right = []
    for num in arr
      if num < pivot then left.push(num) else right.push(num)
    @quickSort(left).concat([pivot], @quickSort(right))
  #返回元素组合  
  @getCombinations: (array, s) ->
    combinations = []
    length = array.length
    return combinations if s <= 0 or s > length
    sortedArray = array.slice().sort((a, b) -> a - b)
    indices = (i for i in [0...s])
    while indices[0] <= length - s
      combinations.push indices.map((i) -> sortedArray[i])
      i = s - 1
      while i >= 0 and indices[i] is i + length - s
        i--
      break if i < 0
      indices[i]++
      indices[j] = indices[j - 1] + 1 for j in [i + 1...s]
    combinations
  #返回元素排列  
  @getPermute: (array) ->
    result = []
    backtrack = (current, remaining) ->
      if remaining.length is 0
        result.push(current.slice())
        return
      for i in [0...remaining.length]
        [remaining[i], remaining[0]] = [remaining[0], remaining[i]]
        current.push remaining.shift()
        backtrack(current, remaining)
        remaining.unshift(current.pop())
    backtrack([], array)
    result
  #计算两点之间的角度（0-359度）。  
  @calcAngle: (x1, y1, x2, y2) ->
    deltaX = x2 - x1
    deltaY = y2 - y1
    angle = Math.atan2(deltaY, deltaX) * (180 / Math.PI)
    angle += 360 if angle < 0
    angle

  #定义并填充一个数组
  @fillArray = (num, item) -> Array(num).fill(item)
  #并集 差集 交集
  @union = (array1, array2) -> array1.concat(array2).filter((item, index, self) -> self.indexOf(item) is index)
  @Difference = (array1, array2) -> array1.filter((item) -> array2.indexOf(item) is -1)
  @Intersection = (array1, array2) -> array1.filter((item) -> array2.indexOf(item) isnt -1)
  #反转字符串
  @reverseString = (input) -> input.split('').reverse().join('')
  # 对象内数值属性进行排序
  @sortBy = (property, desc = false) ->  (v1, v2) -> (v2[property] > v1[property] ? 1 : -1) *  if desc then -1 else 1
#禁用右键菜单  
window.document.oncontextmenu = -> false
