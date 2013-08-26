var Cursor, CursorManager, Flip, LeapElement, LeapManager, LeapManagerUtils, Particle,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Particle = (function() {
  function Particle(elem) {
    this.elem = elem;
    this.style = elem.style;
    this.elem.style['zIndex'] = 9999;
    this.transformX = 0;
    this.transformY = 0;
    this.transformRotation = 0;
    this.offsetTop = this.getOffset(this.elem).top;
    this.offsetLeft = this.getOffset(this.elem).left;
    this.velocityX = 0;
    this.velocityY = 0;
  }

  Particle.prototype.getOffset = function(el) {
    var body, _x, _y;
    body = document.getElementsByTagName("body")[0];
    _x = 0;
    _y = 0;
    while (el && !isNaN(el.offsetLeft) && !isNaN(el.offsetTop)) {
      _x += el.offsetLeft - el.scrollLeft;
      _y += el.offsetTop - el.scrollTop;
      el = el.offsetParent;
    }
    return {
      top: _y + body.scrollTop,
      left: _x + body.scrollLeft
    };
  };

  Particle.prototype.tick = function(finger) {
    var distX, distY, distance, previousRotation, previousStateX, previousStateY, transform;
    previousStateX = this.transformX;
    previousStateY = this.transformY;
    previousRotation = this.transformRotation;
    if (this.velocityX > 1.0) {
      this.velocityX -= 1.0;
    } else if (this.velocityX < -1.0) {
      this.velocityX += 1.0;
    } else {
      this.velocityX = 0;
    }
    if (this.velocityY > 1.0) {
      this.velocityY -= 1.0;
    } else if (this.velocityY < -1.0) {
      this.velocityY += 1.0;
    } else {
      this.velocityY = 0;
    }
    if (finger) {
      distX = this.offsetLeft + this.transformX - finger.x;
      distY = this.offsetTop + this.transformY - finger.y;
      distance = Math.sqrt(Math.pow(distX, 2) + Math.pow(distY, 2));
      if (distance > 0 && distance < 35) {
        this.velocityX = +finger.velocityX;
        this.velocityY = +finger.velocityY;
      }
    }
    this.transformX = this.transformX + this.velocityX;
    this.transformY = this.transformY + this.velocityY;
    this.transformRotation = this.transformX * -1;
    if ((Math.abs(previousStateX - this.transformX) > 1 || Math.abs(previousStateY - this.transformY) > 1 || Math.abs(previousRotation - this.transformRotation) > 1) && ((this.transformX > 1 || this.transformX < -1) || (this.transformY > 1 || this.transformY < -1))) {
      transform = "translate(" + this.transformX + "px, " + this.transformY + "px) rotate(" + this.transformRotation + "deg)";
      this.style['WebkitTransform'] = transform;
      this.style['msTransform'] = transform;
      return this.style['transform'] = transform;
    }
  };

  return Particle;

})();

this.Particle = Particle;

Flip = (function() {
  function Flip() {
    this.updateChars = __bind(this.updateChars, this);
    var char, confirmation, style,
      _this = this;
    if (window.LEAP_JS_DEMO_LOADED) {
      return;
    }
    window.LEAP_JS_DEMO_LOADED = true;
    if (!window.HIDE_CONFIRMATION) {
      confirmation = true;
    }
    this.body = document.getElementsByTagName("body")[0];
    this.setUpNodes(this.body.childNodes);
    this.chars = (function() {
      var _i, _len, _ref, _results;
      _ref = document.getElementsByTagName('particle');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        char = _ref[_i];
        _results.push(new Particle(char, this.body));
      }
      return _results;
    }).call(this);
    if (confirmation != null) {
      style = document.createElement('style');
      style.innerHTML = "div#confirmation {\nposition: absolute;\ntop: -200px;\nleft: 0px;\nright: 0px;\nbottom: none;\nwidth: 100%;\npadding: 18px;\nmargin: 0px;\nbackground: #e8e8e8;\ntext-align: center;\nfont-size: 14px;\nline-height: 14px;\nfont-family: verdana, sans-serif;\ncolor: #000;\n-webkit-transition: all 1s ease-in-out;\n-moz-transition: all 1s ease-in-out;\n-o-transition: all 1s ease-in-out;\n-ms-transition: all 1s ease-in-out;\ntransition: all 1s ease-in-out;\n-webkit-box-shadow: 0px 3px 3px rgba(0,0,0,0.20);\n-moz-box-shadow: 0px 3px 3px rgba(0,0,0,0.20);\nbox-shadow: 0px 3px 3px rgba(0,0,0,0.20);\nz-index: 100000002;\n}\ndiv#confirmation span,div#confirmation a {\ncolor: #fe3a1a;\n}\ndiv#confirmation.show {\ntop:0px;\ndisplay:block;\n}";
      document.head.appendChild(style);
      this.confirmation = document.createElement("div");
      this.confirmation.id = 'confirmation';
      this.confirmation.innerHTML = "<span style='font-weight:bold;'>LeapJS Demo is Loaded!</span> Let's mess up the " + (document.title.substring(0, 50));
      this.body.appendChild(this.confirmation);
      setTimeout(function() {
        return _this.confirmation.className = 'show';
      }, 10);
      setTimeout(function() {
        return _this.confirmation.className = '';
      }, 5000);
    }
  }

  Flip.prototype.setUpNodes = function(nodes) {
    var node, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      node = nodes[_i];
      _results.push(this.setUpNode(node));
    }
    return _results;
  };

  Flip.prototype.setUpNode = function(node) {
    var name, newNode, _i, _len, _ref;
    _ref = ['script', 'style', 'iframe', 'canvas', 'video', 'audio', 'textarea', 'embed', 'object', 'select', 'area', 'map', 'input'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      name = _ref[_i];
      if (node.nodeName.toLowerCase() === name) {
        return;
      }
    }
    switch (node.nodeType) {
      case 1:
        return this.setUpNodes(node.childNodes);
      case 3:
        if (!/^\s*$/.test(node.nodeValue)) {
          if (node.parentNode.childNodes.length === 1) {
            return node.parentNode.innerHTML = this.setUpText(node.nodeValue);
          } else {
            newNode = document.createElement("particles");
            newNode.innerHTML = this.setUpText(node.nodeValue);
            return node.parentNode.replaceChild(newNode, node);
          }
        }
    }
  };

  Flip.prototype.setUpText = function(string) {
    var char, chars, index;
    chars = (function() {
      var _i, _len, _ref, _results;
      _ref = string.split('');
      _results = [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        char = _ref[index];
        if (!/^\s*$/.test(char)) {
          _results.push("<particle style='display:inline-block;'>" + char + "</particle>");
        } else {
          _results.push('&nbsp;');
        }
      }
      return _results;
    })();
    chars = chars.join('');
    chars = (function() {
      var _i, _len, _ref, _results;
      _ref = chars.split('&nbsp;');
      _results = [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        char = _ref[index];
        if (!/^\s*$/.test(char)) {
          _results.push("<word style='white-space:nowrap'>" + char + "</word>");
        } else {
          _results.push(char);
        }
      }
      return _results;
    })();
    return chars.join(' ');
  };

  Flip.prototype.updateChars = function(finger) {
    var char, _i, _len, _ref, _results;
    _ref = this.chars;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      char = _ref[_i];
      _results.push(char.tick(finger));
    }
    return _results;
  };

  return Flip;

})();

this.Flip = new Flip();

LeapElement = (function() {
  function LeapElement(element) {
    this.element = element;
    this.cursor = null;
  }

  LeapElement.prototype.appendChild = function(element) {
    if (element instanceof HTMLElement) {
      return this.element.appendChild(element);
    } else {
      return this.element.appendChild(element.getElement());
    }
  };

  LeapElement.prototype.removeChild = function(element) {
    if (element instanceof HTMLElement) {
      return this.element.removeChild(element);
    } else {
      return this.element.removeChild(element.getElement());
    }
  };

  LeapElement.prototype.getID = function() {
    return this.element.id;
  };

  LeapElement.prototype.setStyle = function(style) {
    var key, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = style.length; _i < _len; _i++) {
      key = style[_i];
      _results.push(this.element.style[key] = style[key]);
    }
    return _results;
  };

  LeapElement.prototype.getParent = function() {
    return this.element.parentNode;
  };

  LeapElement.prototype.getWidth = function() {
    return this.element.offsetWidth;
  };

  LeapElement.prototype.getHeight = function() {
    return this.element.offsetHeight;
  };

  LeapElement.prototype.getElement = function() {
    return this.element;
  };

  LeapElement.prototype.hasCursor = function() {
    return this.cursor !== null;
  };

  LeapElement.prototype.capture = function(cursor) {
    this.cursor = cursor;
    return this.cursor.capture(this);
  };

  LeapElement.prototype.setXY = function(x, y) {
    this.setX(x);
    return this.setY(y);
  };

  LeapElement.prototype.setX = function(x) {
    return this.element.style.left = x + "px";
  };

  LeapElement.prototype.setY = function(y) {
    return this.element.style.top = y + "px";
  };

  LeapElement.prototype.getX = function() {
    return this.element.getBoundingClientRect().left;
  };

  LeapElement.prototype.getY = function() {
    return this.element.getBoundingClientRect().top;
  };

  LeapElement.prototype.addClass = function(classname) {
    var cn;
    cn = this.element.className;
    if (cn && cn.indexOf(classname) !== -1) {
      return;
    }
    if (cn !== '') {
      classname = ' ' + classname;
    }
    return this.element.className = cn + classname;
  };

  LeapElement.prototype.removeClass = function(classname) {
    var cn, rxp;
    cn = this.element.className;
    rxp = new RegExp("\\s?\\b" + classname + "\\b", "g");
    cn = cn.replace(rxp, '');
    return this.element.className = cn;
  };

  LeapElement.prototype.fireEvent = function(event) {
    return this.element.dispatchEvent(event);
  };

  return LeapElement;

})();

this.LeapElement = LeapElement;

LeapManagerUtils = (function() {
  function LeapManagerUtils() {}

  LeapManagerUtils.ELEMENT_ID_PREFIX = "leap_element_";

  LeapManagerUtils.extend = function(a, b) {
    var i, _i, _len;
    for (_i = 0, _len = b.length; _i < _len; _i++) {
      i = b[_i];
      a[i] = b[i];
    }
    return void 0;
  };

  LeapManagerUtils.extendIf = function(a, b) {
    var i;
    for (i in b) {
      if (b[i] instanceof Object && b[i].constructor === Object) {
        if (a[i] === void 0 || a[i] === null) {
          a[i] = {};
        }
        LeapManagerUtils.extendIf(a[i], b[i]);
      } else {
        if (a[i] === void 0 || a[i] === null) {
          a[i] = b[i];
        }
      }
    }
    return void 0;
  };

  LeapManagerUtils.exists = function(obj) {
    return obj !== void 0 && obj !== null;
  };

  LeapManagerUtils.map = function(value, srcLow, srcHigh, resultLow, resultHigh) {
    if (value === srcLow) {
      return resultLow;
    } else {
      return (value - srcLow) * (resultHigh - resultLow) / (srcHigh - srcLow) + resultLow;
    }
  };

  LeapManagerUtils.error = function(error) {
    return console.log(error);
  };

  LeapManagerUtils.testStructure = function(obj, structure) {
    var i, value, _i, _ref;
    value = null;
    for (i = _i = 0, _ref = structure.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      value = structure[i];
      if (typeof value === "string") {
        if (!this.exists(obj[value])) {
          return false;
        } else {
          obj = obj[value];
        }
      }
    }
    return true;
  };

  LeapManagerUtils.createStructure = function(obj, structure) {
    var i, structureExists, value, _i, _ref;
    structureExists = true;
    value = null;
    for (i = _i = 0, _ref = structure.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      value = structure[i];
      if (typeof value === "string") {
        if (!this.exists(obj[value])) {
          obj = obj[value] = {};
          structureExists = false;
        }
      }
    }
    return structureExists;
  };

  return LeapManagerUtils;

})();

this.LeapManagerUtils = LeapManagerUtils;

Cursor = (function() {
  function Cursor(config) {
    var halfHeight, halfWidth;
    if (!config) {
      LeapManagerUtils.error('Cursor#constructor: You must specify a config object.');
      return null;
    }
    if (!config.source) {
      LeapManagerUtils.error('Cursor#constructor: You must specify a `source`.');
      return null;
    }
    if (!config.id) {
      LeapManagerUtils.error('Cursor#constructor: You must specify a `id`.');
      return null;
    }
    if (!config.icon) {
      LeapManagerUtils.error('Cursor#constructor: You must specify a `icon`.');
      return null;
    }
    this.defaultConfig = {
      easing: 0.2
    };
    LeapManagerUtils.extendIf(config, this.defaultConfig);
    this.source = config.source;
    this.id = config.id;
    this.type = config.type;
    this.icon = config.icon;
    this.easing = config.easing;
    this.x = 0;
    this.y = 0;
    this.z = 0;
    this.X = 0;
    this.Y = 0;
    this.Z = 0;
    this.vX = 0;
    this.vY = 0;
    this.vZ = 0;
    this.enabled = true;
    this.element = null;
    this.type = "real";
    if (this.icon instanceof HTMLElement) {
      this.icon = new LeapElement(this.icon);
    }
    if (config.position) {
      this.update(config.position.x, config.position.y);
      halfWidth = this.icon.getWidth() / 2;
      halfHeight = this.icon.getHeight() / 2;
      this.icon.setX((config.position.x * window.innerWidth) + halfWidth);
      this.icon.setY((config.position.y * window.innerHeight) + halfHeight);
    }
  }

  Cursor.prototype.setManager = function(manager) {
    return this.manager = manager;
  };

  Cursor.prototype.setEnabled = function(value) {
    return this.enabled = value;
  };

  Cursor.prototype.isEnabled = function() {
    return this.enabled;
  };

  Cursor.prototype.setElement = function(element) {
    return this.element = element;
  };

  Cursor.prototype.getElement = function() {
    return this.element;
  };

  Cursor.prototype.hasElement = function() {
    return this.element !== null;
  };

  Cursor.prototype.update = function(x, y, z) {
    this.setPositionX(x);
    this.setPositionY(y);
    return this.setPositionZ(z);
  };

  Cursor.prototype.setPositionX = function(value) {
    this.X = value - this.x;
    return this.x = value;
  };

  Cursor.prototype.setPositionY = function(value) {
    this.Y = value - this.y;
    return this.y = value;
  };

  Cursor.prototype.setPositionZ = function(value) {
    this.Z = value - this.z;
    return this.z = value;
  };

  Cursor.prototype.getX = function() {
    return this.x;
  };

  Cursor.prototype.getY = function() {
    return this.y;
  };

  Cursor.prototype.getZ = function() {
    return this.z;
  };

  Cursor.prototype.setVelocityXYZ = function(x, y, z) {
    this.setVelocityX(x);
    this.setVelocityY(y);
    return this.setVelocityZ(z);
  };

  Cursor.prototype.setVelocityX = function(value) {
    return this.vX = value;
  };

  Cursor.prototype.setVelocityY = function(value) {
    return this.vY = value;
  };

  Cursor.prototype.setVelocityZ = function(value) {
    return this.vZ = value;
  };

  Cursor.prototype.getVelocityX = function() {
    return this.vX;
  };

  Cursor.prototype.getVelocityY = function() {
    return this.vY;
  };

  Cursor.prototype.getVelocityZ = function() {
    return this.vZ;
  };

  Cursor.prototype.getEasing = function() {
    return this.easing;
  };

  Cursor.prototype.dispatchMove = function(element) {
    var mouseEvent;
    if (element) {
      this.setElement(element);
    }
    if (this.hasElement()) {
      mouseEvent = document.createEvent("MouseEvent");
      return mouseEvent.initMouseEvent("mousemove", true, false, window, 1, this.icon.getX(), this.icon.getY(), this.icon.getX(), this.icon.getY(), false, false, false, false, 0, this.element);
    }
  };

  return Cursor;

})();

this.Cursor = Cursor;

CursorManager = (function() {
  function CursorManager(config) {
    var root;
    this.cursorContainerClass = 'leap-cursor-container';
    this.leapCursorClass = 'leap-cursor';
    if (!this.cursorContainer) {
      this.cursorContainer = new LeapElement(document.createElement('div'));
      root = config.root || document.body;
      root.appendChild(this.cursorContainer.element);
      this.cursorContainer.addClass(this.cursorContainerClass);
      this.cursorContainer.setStyle({
        zIndex: 100000,
        position: "fixed",
        top: "0px",
        left: "0px"
      });
    }
    this.elementLookup = {};
    this.cursorLookup = {};
  }

  CursorManager.prototype.get = function(source, id, type) {
    if (type === null || type === void 0) {
      type = "real";
    }
    LeapManagerUtils.createStructure(this.cursorLookup, [type, source]);
    return this.cursorLookup[type][source][id];
  };

  CursorManager.prototype.add = function(cursor) {
    var id, source, type;
    type = cursor.type || "real";
    source = cursor.source || "default";
    id = cursor.id || 0;
    LeapManagerUtils.createStructure(this.cursorLookup, [type, source]);
    if (!LeapManagerUtils.exists(this.cursorLookup[type][source][id])) {
      this.cursorLookup[type][source][id] = cursor;
      this.cursorContainer.appendChild(cursor.icon);
      cursor.icon.addClass(this.leapCursorClass);
      cursor.setManager(this);
      return cursor;
    } else {
      return this.cursorLookup[type][source][id];
    }
  };

  CursorManager.prototype.remove = function(cursor) {
    var id, source, type;
    type = cursor.type || "real";
    source = cursor.source || "default";
    id = cursor.id || 0;
    if (LeapManagerUtils.testStructure(this.elementLookup, [cursor.source, cursor.id])) {
      this.elementLookup[cursor.source][cursor.id] = null;
    }
    cursor.virtualCursors = [];
    cursor.setManager(null);
    if (LeapManagerUtils.exists(cursor.icon.getParent())) {
      this.cursorContainer.removeChild(cursor.icon);
    }
    if (LeapManagerUtils.testStructure(this.cursorLookup, [type, source])) {
      this.cursorLookup[type][source][cursor.id] = null;
      delete this.cursorLookup[type][source][cursor.id];
    }
    return true;
  };

  CursorManager.prototype.pruneCursors = function(source, activeIDs, type) {
    var cursor, cursorIndex, i, remove, _i, _ref;
    if (!LeapManagerUtils.exists(type)) {
      type = "real";
    }
    if (LeapManagerUtils.testStructure(this.cursorLookup, [type, source])) {
      remove = [];
      for (cursorIndex in this.cursorLookup[type][source]) {
        cursor = this.cursorLookup[type][source][cursorIndex];
        if (cursor instanceof Cursor) {
          if (activeIDs.indexOf(cursor.id) === -1) {
            remove.push(cursor);
          }
        }
      }
      for (i = _i = 0, _ref = remove.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        this.remove(remove[i]);
      }
    }
    return void 0;
  };

  CursorManager.prototype.update = function() {
    var cursor, cursorIndex, element, halfHeight, halfWidth, sourceIndex, transformX, transformY, typeIndex, windowPoint, xDiff, yDiff;
    for (typeIndex in this.cursorLookup) {
      for (sourceIndex in this.cursorLookup[typeIndex]) {
        for (cursorIndex in this.cursorLookup[typeIndex][sourceIndex]) {
          cursor = this.cursorLookup[typeIndex][sourceIndex][cursorIndex];
          if (cursor instanceof Cursor) {
            if (!this.elementLookup[cursor.source]) {
              this.elementLookup[cursor.source] = {};
            }
            if (!this.elementLookup[cursor.source][cursor.id]) {
              this.elementLookup[cursor.source][cursor.id] = null;
            }
            windowPoint = {
              x: Math.round(cursor.getX() * window.innerWidth),
              y: Math.round(cursor.getY() * window.innerHeight)
            };
            element = this.elementLookup[cursor.source][cursor.id];
            if (!cursor.isEnabled()) {
              if (element) {
                this.elementLookup[cursor.source][cursor.id] = null;
              }
              continue;
            }
            halfWidth = cursor.icon.getWidth() / 2;
            halfHeight = cursor.icon.getHeight() / 2;
            xDiff = (windowPoint.x - halfWidth) - cursor.icon.getX();
            yDiff = (windowPoint.y - halfHeight) - cursor.icon.getY();
            cursor.setVelocityXYZ(xDiff * cursor.getEasing(), yDiff * cursor.getEasing(), 0);
            transformX = cursor.icon.getX() + cursor.getVelocityX();
            transformY = cursor.icon.getY() + cursor.getVelocityY();
            cursor.icon.setX(transformX);
            cursor.icon.setY(transformY);
            Flip.updateChars({
              x: transformX + halfWidth,
              y: transformY + document.body.scrollTop + halfHeight,
              velocityX: cursor.getVelocityX(),
              velocityY: cursor.getVelocityY()
            });
          }
        }
      }
    }
    return void 0;
  };

  CursorManager.prototype.cursorMove = function(cursor, element) {
    cursor.dispatchMove(element);
    return void 0;
  };

  return CursorManager;

})();

this.CursorManager = CursorManager;

LeapManager = (function() {
  function LeapManager() {
    this.LEAP_POINTABLE_CURSOR_CLASS = "leap-pointable-cursor";
    this.LEAP_SOURCE = "leap";
    this.defaultConfig = {
      maxCursors: 1,
      enableInBackground: false,
      root: null,
      boundary: {
        top: 350,
        left: -100,
        right: 100,
        bottom: 150
      },
      cursorConfig: {},
      loopConfig: {
        enableGestures: false
      }
    };
    this.cursorManager = null;
    this.isActiveWindow = false;
    this.init({
      maxCursors: 1
    });
  }

  LeapManager.prototype.init = function(config) {
    var callback, style,
      _this = this;
    LeapManagerUtils.extendIf(config, this.defaultConfig);
    this.boundary = config.boundary;
    this.maxCursors = config.maxCursors;
    this.cursorConfig = config.cursorConfig;
    this.cursorManager = new CursorManager({
      root: config.root
    });
    style = document.createElement('style');
    style.innerHTML = ".leap-cursor {\nposition: absolute;\ntransition-property: background-color; }\n\n.leap-pointable-cursor {\nwidth: 60px;\nheight: 60px;\nz-index: 999999;\n\nborder-radius: 100%;\n/* IE10 Consumer Preview */\nbackground-image: -ms-linear-gradient(bottom, #FD2D65 0%, #FF5E3A 100%);\n/* Mozilla Firefox */\nbackground-image: -moz-linear-gradient(bottom, #FD2D65 0%, #FF5E3A 100%);\n/* Opera */\nbackground-image: -o-linear-gradient(bottom, #FD2D65 0%, #FF5E3A 100%);\n/* Webkit (Safari/Chrome 10) */\nbackground-image: -webkit-gradient(linear, left bottom, left top, color-stop(0, #FD2D65), color-stop(1, #FF5E3A));\n/* Webkit (Chrome 11+) */\nbackground-image: -webkit-linear-gradient(bottom, #FD2D65 0%, #FF5E3A 100%);\n/* W3C Markup, IE10 Release Preview */\nbackground-image: linear-gradient(to top, #FD2D65 0%, #FF5E3A 100%);\n\noverflow:hidden;\nbox-shadow:  0px 2px 4px 0px rgba(0, 0, 0, 0.4);\nmargin: 0 auto;\n}\n\n.finger {\n/*\nwidth:84px;\nheight:170px;\n*/\nwidth:30px;\nheight:70px;\nposition:absolute;\nbackground:#fff;\n/*  top:20px;\nleft:38px;\n*/\ntop:10px;\nleft:15px;\nborder-radius:20px;\n}\n.finger:after {\ncontent:\"\";\nwidth:22px;\nheight:26px;\n/* IE10 Consumer Preview */\nbackground-image: -ms-linear-gradient(bottom, #FC3D5F 0%, #FC584A 100%);\n/* Mozilla Firefox */\nbackground-image: -moz-linear-gradient(bottom, #FC3D5F 0%, #FC584A 100%);\n/* Opera */\nbackground-image: -o-linear-gradient(bottom, #FC3D5F 0%, #FC584A 100%);\n/* Webkit (Safari/Chrome 10) */\nbackground-image: -webkit-gradient(linear, left bottom, left top, color-stop(0, #FC3D5F), color-stop(1, #FC584A));\n/* Webkit (Chrome 11+) */\nbackground-image: -webkit-linear-gradient(bottom, #FC3D5F 0%, #FC584A 100%);\n/* W3C Markup, IE10 Release Preview */\nbackground-image: linear-gradient(to top, #FC3D5F 0%, #FC584A 100%);\nposition:absolute;\ntop:5px;\nleft:4px;\nborder-radius:10px;\n}\n.burb {\nheight:2px;\nwidth:10px;\nposition:absolute;\nbackground:#FF3162;\ntop:47px;\nleft:25px;\n}\n.burb:after {\ncontent:\"\";\nheight:2px;\nwidth:15px;\nposition:absolute;\nbackground:#FF3162;\ntop:5px;\nleft:-2px;\n}";
    document.head.appendChild(style);
    this.isActiveWindow = true;
    if (!config.enableInBackground) {
      window.addEventListener('blur', function() {
        return this.isActiveWindow = false;
      });
      window.addEventListener('focus', function() {
        return this.isActiveWindow = true;
      });
    }
    callback = function(frame) {
      return _this.onLoop(frame);
    };
    if (Leap !== null) {
      return Leap.loop(config.loopConfig, callback);
    }
  };

  LeapManager.prototype.onLoop = function(frame) {
    if (this.isActiveWindow) {
      this.cursorManager.update();
      this.updatePointables(frame);
    }
    return void 0;
  };

  LeapManager.prototype.updatePointables = function(frame) {
    var currentCursors, cursor, pointable, pointableIndex, posX, posY, posZ, _i, _ref;
    currentCursors = [];
    if (frame && frame.pointables) {
      for (pointableIndex = _i = 0, _ref = frame.pointables.length; 0 <= _ref ? _i < _ref : _i > _ref; pointableIndex = 0 <= _ref ? ++_i : --_i) {
        if (pointableIndex < this.maxCursors) {
          pointable = frame.pointables[pointableIndex];
          if (pointable) {
            posX = LeapManagerUtils.map(pointable.tipPosition[0], this.boundary.left, this.boundary.right, 0, 1);
            posY = LeapManagerUtils.map(pointable.tipPosition[1], this.boundary.bottom, this.boundary.top, 1, 0);
            posZ = pointable.tipPosition[2];
            cursor = this.getCursor(pointable.id, {
              x: posX,
              y: posY,
              z: posZ
            });
            currentCursors.push(cursor.id);
            cursor.update(posX, posY, posZ);
          }
        }
      }
    }
    this.cursorManager.pruneCursors(this.LEAP_SOURCE, currentCursors);
    return void 0;
  };

  LeapManager.prototype.getCursor = function(id, position) {
    var burb, cfg, cursor, finger, icon;
    cursor = this.cursorManager.get(this.LEAP_SOURCE, id);
    if (cursor) {
      return cursor;
    }
    icon = new LeapElement(document.createElement('div'));
    icon.addClass(this.LEAP_POINTABLE_CURSOR_CLASS);
    finger = document.createElement('div');
    finger.className = "finger";
    icon.appendChild(finger);
    burb = document.createElement('div');
    burb.className = "burb";
    icon.appendChild(burb);
    cfg = {
      source: this.LEAP_SOURCE,
      id: id,
      position: position,
      icon: icon
    };
    LeapManagerUtils.extend(cfg, this.cursorConfig);
    cursor = new Cursor(cfg);
    this.cursorManager.add(cursor);
    return cursor;
  };

  return LeapManager;

})();

this.LeapManager = new LeapManager();

/*
//@ sourceMappingURL=app.js.map
*/