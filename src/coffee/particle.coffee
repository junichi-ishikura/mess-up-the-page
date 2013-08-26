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