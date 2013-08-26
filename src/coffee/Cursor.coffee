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
