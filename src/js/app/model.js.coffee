module 'model'

class model.Model
  projects: {}
  
  addProject: (project) ->
    @projects[project.name] = project
  
  removeProject: (project) ->
    delete @projects[project.name]
  
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
    for own savedProjectName, savedProjectObject of savedProjects
      @projects[savedProjectName] = model.Project.load savedProjectObject
    console.log 'load:end'


class model.Project
  @load: (savedProject) ->
    p = new model.Project savedProject.name
    for own sceneName, sceneObject of savedProject.scenes
      s = model.Scene.load sceneObject
      p.addScene s
    for own sceneName, sceneObject of savedProject.scenes
      for own connectorName, connectorObject of sceneObject.connectors
        s1 = p.scenes[sceneName]
        s2 = p.scenes[connectorObject.target]
        s1.connectToNext s2
    return p
  
  constructor: (@name = 'Project 1') ->
    @scenes = {}
  
  addScene: (scene) ->
    @scenes[scene.name] = scene


class model.Scene
  @load: (savedScene) ->
    s = new model.Scene savedScene.name
    s.top = savedScene.top
    s.left = savedScene.left
    return s
    
  constructor: (@name = 'Scene 1') ->
    @top = 100
    @left = 100
    @connectors = {}

  connectToNext: (scene) ->
    connector = new model.SceneConnector @name, scene.name
    @connectors[scene.name] = connector


class model.SceneConnector
  constructor: (@source, @target) ->
    @name = "Connector [#{source} -> #{@target}]"

