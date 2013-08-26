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