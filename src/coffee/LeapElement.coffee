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