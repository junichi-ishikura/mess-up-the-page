class Particle
  constructor:(elem)->
    @elem                 = elem
    @style                = elem.style
    @elem.style['zIndex'] = 9999
    @transformX           = 0
    @transformY           = 0
    @transformRotation    = 0
    @offsetTop  = @getOffset(@elem).top
    @offsetLeft = @getOffset(@elem).left
    @velocityX  = 0
    @velocityY  = 0

  getOffset: (el)->
    body = document.getElementsByTagName("body")[0]
    _x = 0
    _y = 0
    while el and !isNaN(el.offsetLeft) and !isNaN(el.offsetTop)
      _x += el.offsetLeft - el.scrollLeft
      _y += el.offsetTop - el.scrollTop
      el = el.offsetParent
    top: _y + body.scrollTop, left: _x + body.scrollLeft

  tick:(finger)->
    previousStateX = @transformX
    previousStateY = @transformY
    previousRotation = @transformRotation
    if @velocityX > 1.0 then @velocityX -= 1.0 else if @velocityX < -1.0 then @velocityX += 1.0 else @velocityX = 0
    if @velocityY > 1.0 then @velocityY -= 1.0 else if @velocityY < -1.0 then @velocityY += 1.0 else @velocityY = 0
    if finger
      distX  = @offsetLeft + @transformX - finger.x
      distY  = @offsetTop + @transformY - finger.y
      distance = Math.sqrt(Math.pow(distX,2) + Math.pow(distY,2));
      if distance > 0 && distance < 35
        @velocityX =+ finger.velocityX
        @velocityY =+ finger.velocityY
    @transformX = @transformX + @velocityX
    @transformY = @transformY + @velocityY

    @transformRotation = @transformX*-1
    
    if (Math.abs(previousStateX - @transformX) > 1 or Math.abs(previousStateY - @transformY) > 1 or Math.abs(previousRotation - @transformRotation) > 1) and ((@transformX > 1 or @transformX < -1) or (@transformY > 1 or @transformY < -1)) 
      transform = "translate(#{@transformX}px, #{@transformY}px) rotate(#{@transformRotation}deg)"
      @style['WebkitTransform'] = transform
      @style['msTransform']     = transform
      @style['transform']       = transform

this.Particle = Particle
class Flip
  constructor: ()->
    return if window.LEAP_JS_DEMO_LOADED
    window.LEAP_JS_DEMO_LOADED = true
    confirmation = true unless window.HIDE_CONFIRMATION
    @body = document.getElementsByTagName("body")[0]
    @setUpNodes @body.childNodes
    @chars = for char in document.getElementsByTagName('particle')
      new Particle(char, @body)

    if confirmation?
      style = document.createElement('style')
      style.innerHTML = """
                        div#confirmation {
                        position: absolute;
                        top: -200px;
                        left: 0px;
                        right: 0px;
                        bottom: none;
                        width: 100%;
                        padding: 18px;
                        margin: 0px;
                        background: #e8e8e8;
                        text-align: center;
                        font-size: 14px;
                        line-height: 14px;
                        font-family: verdana, sans-serif;
                        color: #000;
                        -webkit-transition: all 1s ease-in-out;
                        -moz-transition: all 1s ease-in-out;
                        -o-transition: all 1s ease-in-out;
                        -ms-transition: all 1s ease-in-out;
                        transition: all 1s ease-in-out;
                        -webkit-box-shadow: 0px 3px 3px rgba(0,0,0,0.20);
                        -moz-box-shadow: 0px 3px 3px rgba(0,0,0,0.20);
                        box-shadow: 0px 3px 3px rgba(0,0,0,0.20);
                        z-index: 100000002;
                        }
                        div#confirmation span,div#confirmation a {
                        color: #fe3a1a;
                        }
                        div#confirmation.show {
                        top:0px;
                        display:block;
                        }
                        """
      document.head.appendChild style
      @confirmation = document.createElement("div")
      @confirmation.id = 'confirmation'
      @confirmation.innerHTML = "<span style='font-weight:bold;'>LeapJS Demo is Loaded!</span> Let's mess up the #{document.title.substring(0,
        50)}"
      @body.appendChild @confirmation
      setTimeout(=>
        @confirmation.className = 'show'
      , 10)
      setTimeout(=>
        @confirmation.className = ''
      , 5000)

  setUpNodes: (nodes)->
    for node in nodes
      @setUpNode(node)

  setUpNode: (node)->
    for name in ['script', 'style', 'iframe', 'canvas', 'video', 'audio', 'textarea', 'embed', 'object', 'select',
                 'area', 'map', 'input']
      return if node.nodeName.toLowerCase() == name
    switch node.nodeType
      when 1 then @setUpNodes(node.childNodes)
      when 3
        unless /^\s*$/.test(node.nodeValue)
          if node.parentNode.childNodes.length == 1
            node.parentNode.innerHTML = @setUpText(node.nodeValue)
          else
            newNode = document.createElement("particles")
            newNode.innerHTML = @setUpText(node.nodeValue)
            node.parentNode.replaceChild newNode, node

  setUpText: (string)->
    chars = for char, index in string.split ''
      unless /^\s*$/.test(char) then "<particle style='display:inline-block;'>#{char}</particle>" else '&nbsp;'
    chars = chars.join('')
    chars = for char, index in chars.split '&nbsp;'
      unless /^\s*$/.test(char) then "<word style='white-space:nowrap'>#{char}</word>" else char
    chars.join(' ')

  updateChars: (finger)=>
    char.tick(finger) for char in @chars


this.Flip = new Flip()
class LeapElement
  constructor:(element)->
    @element = element
    @cursor = null

  appendChild:(element)->
    if element instanceof HTMLElement
      @element.appendChild(element)
    else
      @element.appendChild(element.getElement())

  removeChild:(element)->
    if element instanceof HTMLElement
      @element.removeChild(element)
    else
      @element.removeChild(element.getElement())

  getID:->
    @element.id

  setStyle:(style)->
    for key in style
      @element.style[key] = style[key]

  getParent:->
    @.element.parentNode

  getWidth:->
    @.element.offsetWidth

  getHeight:->
    @.element.offsetHeight

  getElement:->
    @.element

  hasCursor:->
    @.cursor != null

  capture:(cursor)->
    @cursor = cursor;
    @cursor.capture(this)

  setXY:(x, y)->
    @setX(x)
    @setY(y)

  setX:(x)->
    @element.style.left = x + "px"

  setY:(y)->
    @element.style.top = y + "px"

  getX:->
    @element.getBoundingClientRect().left

  getY:->
    @element.getBoundingClientRect().top

  addClass:(classname)->
    cn = @element.className
    #test for existance
    if cn && cn.indexOf(classname) != -1
      return
    #add a space if the element already has class
    if cn != ''
      classname = ' ' + classname
    @element.className = cn + classname

  removeClass:(classname)->
    cn = @element.className
    rxp = new RegExp("\\s?\\b" + classname + "\\b", "g")
    cn = cn.replace(rxp, '')
    @element.className = cn

  fireEvent:(event)->
    @element.dispatchEvent(event)

this.LeapElement = LeapElement
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
class Cursor

  constructor:(config)->
    if !config
      LeapManagerUtils.error('Cursor#constructor: You must specify a config object.')
      return null

    if !config.source
      LeapManagerUtils.error('Cursor#constructor: You must specify a `source`.')
      return null

    if !config.id
      LeapManagerUtils.error('Cursor#constructor: You must specify a `id`.')
      return null

    if !config.icon
      LeapManagerUtils.error('Cursor#constructor: You must specify a `icon`.')
      return null

    @defaultConfig = {
      easing: 0.2
    }
    LeapManagerUtils.extendIf(config, @defaultConfig)
    @source = config.source
    @id = config.id
    @type = config.type
    @icon = config.icon
    @easing = config.easing

    #Positoin
    @x = 0
    @y = 0
    @z = 0
    #Speed
    @X = 0
    @Y = 0
    @Z = 0
    #Velocity
    @vX = 0
    @vY = 0
    @vZ = 0

    @enabled = true
    @element = null
    @type = "real"

    @icon = new LeapElement(@icon) if @icon instanceof HTMLElement
    if config.position
      @update(config.position.x, config.position.y)
      halfWidth = (this.icon.getWidth() / 2);
      halfHeight = (this.icon.getHeight() / 2);
      @icon.setX((config.position.x * window.innerWidth) + halfWidth)
      @icon.setY((config.position.y * window.innerHeight) + halfHeight)

  setManager:(manager)-> @manager = manager

  #Enabled
  setEnabled:(value)-> @enabled = value
  isEnabled:-> @enabled

  #Element
  setElement:(element)-> @element = element
  getElement:-> @element
  hasElement:-> @element != null

  #Callbacks from Manager for Element Interactions
  #onElementMove:(element)-> {}

  #Position
  update:(x, y, z)->
    @setPositionX(x)
    @setPositionY(y)
    @setPositionZ(z)

  setPositionX: (value)->
    @X = value - @x
    @x = value

  setPositionY:(value)->
    @Y = value - @y
    @y = value

  setPositionZ:(value)->
    @Z = value - @z
    @z = value

  #Speed
  getX: -> @x
  getY: -> @y
  getZ: -> @z

  #Velocity
  setVelocityXYZ:(x, y, z)->
    @setVelocityX(x)
    @setVelocityY(y)
    @setVelocityZ(z)

  setVelocityX:(value)-> @vX = value
  setVelocityY:(value)-> @vY = value
  setVelocityZ:(value)-> @vZ = value
  getVelocityX: -> @vX
  getVelocityY: -> @vY
  getVelocityZ: -> @vZ

  #Easing
  getEasing: -> @easing

  dispatchMove:(element)->
    @setElement(element) if element
    if @hasElement()
      mouseEvent = document.createEvent("MouseEvent")
      mouseEvent.initMouseEvent("mousemove", true, false, window, 1, @icon.getX(), @icon.getY(), @icon.getX(), @icon.getY(), false, false, false, false, 0, @element)
      ##@element.fireEvent(mouseEvent);
      #@onElementMove(@element)

this.Cursor = Cursor

class CursorManager

  constructor:(config)->
    @cursorContainerClass = 'leap-cursor-container'
    @leapCursorClass = 'leap-cursor'

    if !this.cursorContainer
      @cursorContainer = new LeapElement(document.createElement('div'))
      root = config.root || document.body;
      root.appendChild(this.cursorContainer.element)
      @cursorContainer.addClass(this.cursorContainerClass)
      @cursorContainer.setStyle({
        zIndex: 100000
        position: "fixed"
        top: "0px"
        left: "0px"
      })

    #@cursorContainer = null
    @elementLookup = {}
    @cursorLookup = {}

  get:(source, id, type)->
    type = "real" if type == null || type == undefined
    LeapManagerUtils.createStructure(@cursorLookup, [type, source])
    @cursorLookup[type][source][id]

  add:(cursor)->
    type = cursor.type || "real"
    source = cursor.source || "default"
    id = cursor.id || 0
    LeapManagerUtils.createStructure(@cursorLookup, [type, source])

    if !LeapManagerUtils.exists(@cursorLookup[type][source][id])
      @cursorLookup[type][source][id] = cursor
      @cursorContainer.appendChild(cursor.icon)
      cursor.icon.addClass(@leapCursorClass)
      cursor.setManager(this)
      cursor
    else
      @cursorLookup[type][source][id]


  remove:(cursor)->
    type = cursor.type || "real"
    source = cursor.source || "default"
    id = cursor.id || 0

    if(LeapManagerUtils.testStructure(this.elementLookup, [cursor.source, cursor.id]))
      @elementLookup[cursor.source][cursor.id] = null

    cursor.virtualCursors = []
    cursor.setManager(null)
    @cursorContainer.removeChild(cursor.icon) if(LeapManagerUtils.exists(cursor.icon.getParent()))
    if(LeapManagerUtils.testStructure(this.cursorLookup, [type, source]))
      @cursorLookup[type][source][cursor.id] = null
      delete @cursorLookup[type][source][cursor.id]

    return true

  pruneCursors:(source, activeIDs, type)->
    type = "real" if(!LeapManagerUtils.exists(type))
    if(LeapManagerUtils.testStructure(this.cursorLookup, [type, source]))
      remove = []
      for cursorIndex of @cursorLookup[type][source]
        cursor = @cursorLookup[type][source][cursorIndex]
        if(cursor instanceof Cursor)
          if(activeIDs.indexOf(cursor.id) == - 1)
            remove.push(cursor)

      for i in [0...remove.length]
        @remove(remove[i])

    return undefined

  update: ->
    for typeIndex of @cursorLookup
      for sourceIndex of this.cursorLookup[typeIndex]
        for cursorIndex of this.cursorLookup[typeIndex][sourceIndex]
          cursor = @cursorLookup[typeIndex][sourceIndex][cursorIndex]
          if(cursor instanceof Cursor)

            @elementLookup[cursor.source] = {} if (!@elementLookup[cursor.source])
            @elementLookup[cursor.source][cursor.id] = null if (!@elementLookup[cursor.source][cursor.id])
            windowPoint =
              x: Math.round(cursor.getX() * window.innerWidth)
              y: Math.round(cursor.getY() * window.innerHeight)

            element = this.elementLookup[cursor.source][cursor.id]
            #Cursor Is Not enabled, check for an object under it
            if (!cursor.isEnabled())
              if (element)
                @elementLookup[cursor.source][cursor.id] = null
              continue

            halfWidth = (cursor.icon.getWidth() / 2);
            halfHeight = (cursor.icon.getHeight() / 2);

            xDiff = (windowPoint.x - halfWidth) - cursor.icon.getX()
            yDiff = (windowPoint.y - halfHeight) - cursor.icon.getY()
            cursor.setVelocityXYZ(xDiff * cursor.getEasing(), yDiff * cursor.getEasing(), 0)

            transformX = cursor.icon.getX() + cursor.getVelocityX()
            transformY = cursor.icon.getY() + cursor.getVelocityY()
            cursor.icon.setX(transformX)
            cursor.icon.setY(transformY)

            Flip.updateChars({
              x:transformX + halfWidth
              y:transformY + document.body.scrollTop + halfHeight
              velocityX:cursor.getVelocityX()
              velocityY:cursor.getVelocityY()
            })
    return undefined

  cursorMove:(cursor, element)->
    cursor.dispatchMove(element)
    return undefined

this.CursorManager = CursorManager
class LeapManager

  constructor: ->
    @LEAP_POINTABLE_CURSOR_CLASS = "leap-pointable-cursor"
    @LEAP_SOURCE = "leap"
    @defaultConfig =
      maxCursors: 1
      enableInBackground: false
      root: null
      boundary:
        top: 350
        left: -100
        right: 100
        bottom: 150
      cursorConfig: {}
      loopConfig:
        enableGestures: false
    @cursorManager = null
    @isActiveWindow = false

    @init({
      maxCursors:1
    })

  init:(config)->
    LeapManagerUtils.extendIf(config, @defaultConfig)
    @boundary = config.boundary
    @maxCursors = config.maxCursors
    @cursorConfig = config.cursorConfig

    @cursorManager = new CursorManager({
      root: config.root
    })

    style = document.createElement('style')
    style.innerHTML = """
                      .leap-cursor {
                      position: absolute;
                      transition-property: background-color; }

                      .leap-pointable-cursor {
                      width: 60px;
                      height: 60px;
                      z-index: 999999;

                      border-radius: 100%;
                      /* IE10 Consumer Preview */
                      background-image: -ms-linear-gradient(bottom, #FD2D65 0%, #FF5E3A 100%);
                      /* Mozilla Firefox */
                      background-image: -moz-linear-gradient(bottom, #FD2D65 0%, #FF5E3A 100%);
                      /* Opera */
                      background-image: -o-linear-gradient(bottom, #FD2D65 0%, #FF5E3A 100%);
                      /* Webkit (Safari/Chrome 10) */
                      background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0, #FD2D65), color-stop(1, #FF5E3A));
                      /* Webkit (Chrome 11+) */
                      background-image: -webkit-linear-gradient(bottom, #FD2D65 0%, #FF5E3A 100%);
                      /* W3C Markup, IE10 Release Preview */
                      background-image: linear-gradient(to top, #FD2D65 0%, #FF5E3A 100%);

                      overflow:hidden;
                      box-shadow:  0px 2px 4px 0px rgba(0, 0, 0, 0.4);
                      margin: 0 auto;
                      }

                      .finger {
                      /*
                      width:84px;
                      height:170px;
                      */
                      width:30px;
                      height:70px;
                      position:absolute;
                      background:#fff;
                      /*  top:20px;
                      left:38px;
                      */
                      top:10px;
                      left:15px;
                      border-radius:20px;
                      }
                      .finger:after {
                      content:"";
                      width:22px;
                      height:26px;
                      /* IE10 Consumer Preview */
                      background-image: -ms-linear-gradient(bottom, #FC3D5F 0%, #FC584A 100%);
                      /* Mozilla Firefox */
                      background-image: -moz-linear-gradient(bottom, #FC3D5F 0%, #FC584A 100%);
                      /* Opera */
                      background-image: -o-linear-gradient(bottom, #FC3D5F 0%, #FC584A 100%);
                      /* Webkit (Safari/Chrome 10) */
                      background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0, #FC3D5F), color-stop(1, #FC584A));
                      /* Webkit (Chrome 11+) */
                      background-image: -webkit-linear-gradient(bottom, #FC3D5F 0%, #FC584A 100%);
                      /* W3C Markup, IE10 Release Preview */
                      background-image: linear-gradient(to top, #FC3D5F 0%, #FC584A 100%);
                      position:absolute;
                      top:5px;
                      left:4px;
                      border-radius:10px;
                      }
                      .burb {
                      height:2px;
                      width:10px;
                      position:absolute;
                      background:#FF3162;
                      top:47px;
                      left:25px;
                      }
                      .burb:after {
                      content:"";
                      height:2px;
                      width:15px;
                      position:absolute;
                      background:#FF3162;
                      top:5px;
                      left:-2px;
                      }
                      """
    document.head.appendChild style

    #Active Tab/Window Checking
    #me = this
    @isActiveWindow = true
    if (!config.enableInBackground)
      window.addEventListener 'blur', ->
        @isActiveWindow = false

      window.addEventListener 'focus', ->
        @isActiveWindow = true

    callback = (frame)=>
      @onLoop(frame)

    Leap.loop(config.loopConfig, callback) if(Leap != null)

  onLoop:(frame)->
    if @isActiveWindow
      @cursorManager.update()
      @updatePointables(frame)
    return undefined

  updatePointables:(frame)->
    currentCursors = []
    if frame && frame.pointables
      for pointableIndex in [0...frame.pointables.length]
        if pointableIndex < @maxCursors
          pointable = frame.pointables[pointableIndex]
          if pointable
            posX = LeapManagerUtils.map(pointable.tipPosition[0], @boundary.left, @boundary.right, 0, 1)
            posY = LeapManagerUtils.map(pointable.tipPosition[1], @boundary.bottom, @boundary.top, 1, 0)
            posZ = pointable.tipPosition[2]
            cursor = @getCursor(pointable.id, {
              x: posX
              y: posY
              z: posZ
            })
            currentCursors.push(cursor.id)
            cursor.update(posX, posY, posZ)

    @.cursorManager.pruneCursors(@LEAP_SOURCE, currentCursors)
    return undefined

  getCursor:(id, position)->
    cursor = this.cursorManager.get(@LEAP_SOURCE, id)
    return cursor if cursor

    icon = new LeapElement(document.createElement('div'))
    icon.addClass(@LEAP_POINTABLE_CURSOR_CLASS)

    finger = document.createElement('div')
    finger.className = "finger"
    icon.appendChild(finger)

    burb = document.createElement('div')
    burb.className = "burb"
    icon.appendChild(burb)

    cfg =
      source: @LEAP_SOURCE
      id: id
      position: position
      icon: icon

    LeapManagerUtils.extend(cfg, @cursorConfig)
    cursor = new Cursor(cfg)
    @cursorManager.add(cursor)
    cursor

this.LeapManager = new LeapManager()