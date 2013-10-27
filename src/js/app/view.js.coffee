module 'view'

class view.Base
  constructor: (@canvas, @root, @model) ->
    #empty

  render: () ->
    console.log "#{@constructor.name}::render #{@model.name}"
  
  addShadowTo: (shape) ->
    shape.setShadow { color: '#003333', offsetX: 10, offsetY: 10, blur: 20 }


class view.Project extends view.Base
  constructor: (@canvas, @model) ->
    super @canvas, @model, @model
    @sceneViews = {}

  render: () ->
    super()
    
    name = new fabric.Text @model.name,
      left: @canvas.getWidth() / 2
      top: 15
      fontFamily: 'Comic Sans'
      fontSize: 16
    @canvas.add name
    
    for own sceneId, sceneObject of @model.scenes
      sv = new view.Scene @canvas, @model, sceneObject, @
      @sceneViews[sceneId] = sv
      sv.render()
    
    for own sceneId, sceneObject of @sceneViews
      for own connectorName, connectorObject of sceneObject.model.connectors
        cv = new view.SceneConnector @canvas, @root, connectorObject
        sceneObject.connectorViews.push cv
        @sceneViews[cv.model.target].connectorViews.push cv
        cv.render()
  
  applyCurrentObject: () ->
    console.log 'applyCurrentObject:start'
    scene = @model.scenes[@model.currentSceneId]
    if scene?
      console.log "current object is #{scene.name}"
      scene.name = @canvas.tools.currentName.val()
    console.log 'applyCurrentObject:end'


class view.Scene extends view.Base
  constructor: (@canvas, @root, @model, @projectView) ->
    super @canvas, @root, @model
    @connectorViews = []
  
  render: () ->
    super()
    
    body = new fabric.Rect
      fill: '#00CCCC'
      stroke: '#003333'
      strokeWidth: 2
      width: 200
      height: 50
      rx: 10
      ry: 10
      minScaleLimit: 0.5
      lockRotation: true
    
    copyButton = new fabric.Rect
      width: 25
      height: 25
      left: 80
      fill: 'orange'
      stroke: 'black'
    
    name = new fabric.Text @model.name,
      fontFamily: 'Comic Sans'
      fontSize: 15
    
    shape = new fabric.Group [ body, copyButton, name ],
      left: @model.left
      top: @model.top
      onMoving: () => 
        @model.left = shape.getLeft()
        @model.top = shape.getTop()
        for cv in @connectorViews
          cv.rerender()
      onClick: () =>
        @canvas.tools.currentName.val @model.name
        @root.currentSceneId = @model.id
    
    @addShadowTo body
    @canvas.add shape


class view.SceneConnector extends view.Base
  constructor: (@canvas, @root, @model) ->
    super @canvas, @root, @model
  
  render: () ->
    super()
    
    @s1 = @root.scenes[@model.source]
    @s2 = @root.scenes[@model.target]
    
    @shape = new fabric.Line [ @getX1(), @getY1(), @getX2(), @getY2() ],
      fill: '#003333'
      stroke: '#003333'
      strokeWidth: 5
      selectable: false
    
    @addShadowTo @shape
    @canvas.add @shape
  
  rerender: () ->
    @shape.set { x1: @getX1(), x2: @getX2(), y1: @getY1(), y2: @getY2() }
  
  getX1: -> @s1.left
  getY1: -> @s1.top + 25
  getX2: -> @s2.left
  getY2: -> @s2.top - 25
  

