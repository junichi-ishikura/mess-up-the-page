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
      @confirmation.innerHTML = "<span style='font-weight:bold;'>MessUpThePage is Loaded!</span> Let's mess up the #{document.title.substring(0,
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