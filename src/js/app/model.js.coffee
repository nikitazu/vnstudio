module 'model'

class model.Model
  projects: {}
  
  addProject: (project) ->
    @projects[project.id] = project
  
  removeProject: (project) ->
    delete @projects[project.id]
  
  save: () ->
    console.log 'save:start'
    data = JSON.stringify(@projects)
    localStorage.setItem 'model', data
    console.log 'save:end'
  
  load: () ->
    console.log 'load:start'
    data = localStorage.getItem 'model'
    console.log data
    savedProjects = jQuery.parseJSON(data)
    @projects = {}
    for own savedProjectId, savedProjectObject of savedProjects
      @projects[savedProjectId] = model.Project.load savedProjectObject
    console.log 'load:end'
  
  applyCurrentObject: (project, tools) ->
    console.log 'applyCurrentObject:start'
    p = @projects[project.id]
    s = p.scenes[p.currentSceneId]
    if s?
      console.log "current object is #{s.name}"
      s.name = tools.currentName.val()
    console.log 'applyCurrentObject:end'


class model.Project
  @load: (savedProject) ->
    console.log "loading project #{savedProject.name}"
    p = new model.Project savedProject.name
    p.id = savedProject.id
    for own sceneId, sceneObject of savedProject.scenes
      s = model.Scene.load sceneObject
      p.addScene s
    for own sceneId, sceneObject of savedProject.scenes
      for own connectorName, connectorObject of sceneObject.connectors
        s1 = p.scenes[sceneId]
        s2 = p.scenes[connectorObject.target]
        s1.connectToNext s2
    return p
  
  constructor: (@name = 'Project 1') ->
    @id = guid()
    @scenes = {}
  
  addScene: (scene) ->
    @scenes[scene.id] = scene


class model.Scene
  @load: (savedScene) ->
    console.log "loading scene #{savedScene.name}"
    s = new model.Scene savedScene.name
    s.id = savedScene.id
    s.top = savedScene.top
    s.left = savedScene.left
    return s
    
  constructor: (@name = 'Scene 1') ->
    @id = guid()
    @top = 100
    @left = 100
    @connectors = {}

  connectToNext: (scene) ->
    connector = new model.SceneConnector @id, scene.id
    @connectors[scene.id] = connector


class model.SceneConnector
  constructor: (@source, @target) ->
    @name = "Connector [#{source} -> #{@target}]"

