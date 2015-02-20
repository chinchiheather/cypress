@App.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Updater extends Entities.Model
    defaults: ->
      finished: false

    mutators:
      stateFormatted: ->
        switch @get("state")
          when "checking"     then "Checking for updates..."
          when "downloading"  then "Downloading updates..."
          when "applying"     then "Applying updates..."
          when "done"         then "Updates ready!"
          when "none"         then "No updates available."
          when "error"        then "An error occured updating."

      buttonFormatted: ->
        if @get("state") is "done" then "Restart" else "Close"

    getUpdater: ->
      @updater ? throw new Error("Updater object not found on model!")

    setUpdater: (upd) ->
      @updater = upd

      ## pull off additional properties
      ## like the tmpDestination, appPath, execPath, etc

    setState: (state) ->
      switch state
        when "error", "done", "none" then @setFinished()

      @set "state", state

    setNewVersion: (newVersion) ->
      @set "newVersion", newVersion

    setFinished: ->
      @set "finished", true

    hasError: ->
      @get("state") is "error"

    run: (options) ->
      @getUpdater().run(options)
      # path = "/var/folders/wr/3xdzqnq16lz5r1j_xtl443580000gn/T/cypress/cypress.app"
      # @getUpdater().runInstaller(path)

    install: (appPath, execPath) ->
      @getUpdater().install(appPath, execPath)

  API =
    newUpdater: (attrs) ->
      manifest = App.request "gui:manifest"

      updater = new Entities.Updater _.extend(attrs, {version: manifest.version})
      updater.setUpdater App.config.getUpdater()
      updater

  App.reqres.setHandler "new:updater:entity", (attrs = {}) ->
    API.newUpdater(attrs)