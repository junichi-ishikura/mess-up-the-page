class LeapManagerUtils
  #constructor:()->
  @ELEMENT_ID_PREFIX = "leap_element_"

  @extend:(a, b)->
    for i in b
      a[i] = b[i]
    return undefined

  @extendIf:(a, b)->
    for i of b
      if b[i] instanceof Object && b[i].constructor == Object
        a[i] = {} if a[i] == undefined || a[i] == null
        LeapManagerUtils.extendIf(a[i], b[i])
      else
        a[i] = b[i] if a[i] == undefined || a[i] == null
    return undefined

  @exists:(obj)->
    obj != undefined && obj != null

  @map:(value, srcLow, srcHigh, resultLow, resultHigh)->
    if value == srcLow
      resultLow
    else
      (value - srcLow) * (resultHigh - resultLow) / (srcHigh - srcLow) + resultLow

  @error:(error)->
    console.log(error)

  @testStructure:(obj, structure)->
    value = null
    for i in [0...structure.length]
      value = structure[i]
      if typeof(value) == "string"
        if !@exists(obj[value])
          return false;
        else
          obj = obj[value]
    return true

  @createStructure:(obj, structure)->
    structureExists = true
    value = null
    for i in [0...structure.length]
      value = structure[i]
      if typeof(value) == "string"
        if !@exists(obj[value])
          obj = obj[value] = {}
          structureExists = false
    return structureExists

this.LeapManagerUtils = LeapManagerUtils