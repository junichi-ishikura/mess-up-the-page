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