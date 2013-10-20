# ==============
# Initialization
# ==============

addShadowTo = (shape) ->
  shape.setShadow { color: '003333', offsetX: 10, offsetY: 10, blur: 20 }


canvas = new fabric.Canvas 'stage'

canvas.addShapesOf = (items) ->
  for item in items
    canvas.add item.shape

canvas.connectScenes = (output, input) ->
  path = new ScenePath output, input
  canvas.add path.shape

canvas.on 'object:moving', (event) -> 
  event.target.updatePathsPosition?()
  event.target.onMoving?()

canvas.on 'object:scaling', (event) -> event.target.updatePathsPosition?()
canvas.on 'mouse:down', (event) -> event.target?.onClick?(canvas, event)

# ==============
# Building model
# ==============

x = new model.Model
p = new model.Project 'Shangri-La'
x.addProject p

ss1 = new model.Scene 'Scene A'
ss2 = new model.Scene 'Scene B'

ss1.left = 200
ss2.top = 200
ss2.left = 200

p.addScene ss1
p.addScene ss2
ss1.connectToNext ss2

pv = new view.Project canvas, p
pv.render()

# =======
# Toolbox
# =======

$('#newSceneButton').on 'click', (event) ->
  console.log 'new scene begin'
  ns = new model.Scene 'Scene 1'
  ns.left = 200
  ns.top = 200
  p.addScene ns
  canvas.clear()
  pv = new view.Project canvas, p
  pv.render()
  console.log 'new scene end'

$('#clearButton').on 'click', (event) ->
  console.log 'clear begin'
  canvas.clear()
  console.log 'clear end'

$('#saveButton').on 'click', (event) ->
  x.save()

$('#loadButton').on 'click', (event) ->
  x.load()
  p = x.projects['Shangri-La']
  canvas.clear()
  pv = new view.Project canvas, p
  pv.render()

