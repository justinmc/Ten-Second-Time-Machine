###
    global define
###

define ["player", "world", "input"], (Player, World, input) ->
    "use strict"

    class App

        # Config
        canvasRatio: 1.5    # canvas size w/h ratio

        # Canvas variables
        canvas: null
        ctx: null

        # Assets
        world: null
        player: null

        timeTraveled: false

        # History of time!
        Action: null
        Actions: null
        actions: null
        PastSelf: null
        PastSelves: null
        pastSelves: null

        # The time of the most recently completed render
        timeThen: null

        constructor: () ->
            # Set up the canvas
            @canvas = document.getElementById("app")
            @ctx = @canvas.getContext("2d")
            @ctx.mozImageSmoothingEnabled = false

            # Set the canvas size
            height = window.innerHeight - (window.innerHeight / 100)
            width = height * 1.5
            windowRatio = window.innerWidth / window.innerHeight
            if (windowRatio < @canvasRatio)
                width = window.innerWidth
                height = width * @canvasRatio
            @canvas.width = width
            @canvas.height = height

            # Create assets
            @world = new World(@canvas.width, @canvas.height)
            @player = new Player(@world.getTileWidth(), @world.getTileHeight())

            # Create the history backbone objects
            @Action = Backbone.Model.extend()
            @Actions = Backbone.Collection.extend
                model: @Action
            @actions = new @Actions()

            # Create the old selfs backbone object
            @PastSelf = Backbone.Model.extend()
            @PastSelves = Backbone.Collection.extend
                model: @PastSelf
            @pastSelves = new @PastSelves()

            # Get the time and write an initial history record
            @timeThen = Date.now()
            @writeHistory(@timeThen, 0, 0)

            # Start the main game loop
            @main()

        # The main loop called at each iteration of the game
        main: () ->
          (@mainFactory())()

        # Return an instance of the main function
        mainFactory: () ->
            me = @
            return () ->
                # Get the changed time in seconds since last render
                timeNow = Date.now()
                dt = (timeNow - me.timeThen) / 1000.0

                # Handle user input
                if (input.isDown("UP"))
                    me.movePlayer(0, -1, timeNow)
                if (input.isDown("DOWN"))
                    me.movePlayer(0, 1, timeNow)
                if (input.isDown("LEFT"))
                    me.movePlayer(-1, 0, timeNow)
                if (input.isDown("RIGHT"))
                    me.movePlayer(1, 0, timeNow)
                if (input.isDown("SPACE"))
                    me.timeTravel(timeNow, timeNow)

                # Render
                me.render(timeNow, dt)

                # Continue the loop
                me.timeThen = timeNow
                requestAnimationFrame(me.mainFactory())

        # Render the scene on the canvas
        render: (timeNow, dt) ->
            # Reset the canvas
            @canvas.width = @canvas.width

            # Render the background
            @world.render(@ctx)

            # Render the player
            @player.render(@ctx, dt)

            # Render any past selves
            me = @
            @pastSelves.each (pastSelf) ->
                player = pastSelf.get("player")

                # Do an action if needed
                action = me.actions.at(pastSelf.get("actionIdNext"))
                if action? and (timeNow - pastSelf.get("timeRecreated") + pastSelf.get("timeDest")) >= action.get("time")
                    # If the action is a timetravel, destroy the pastSelf
                    if (action.get("timeTravel"))
                        me.pastSelves.remove(pastSelf)
                    # Otherwise, perform the action
                    else
                        player.x = action.get("playerX")
                        player.y = action.get("playerY")
                        player.move(me.world.tileToPixelX(player.x), me.world.tileToPixelY(player.y))
                        player.render(me.ctx, dt)
                        pastSelf.set("actionIdNext", pastSelf.get("actionIdNext") + 1)
                # Otherwise keep the pastSelf where it is
                else
                    player.render(me.ctx, dt)

        timeTravel: (timeNow) ->
            # Can't time travel if nothing has happened
            if @actions.length and !@timeTraveled
                @timeTraveled = true
                # Set the destination for 10 SECONDS ago
                timeDest = timeNow - 10 * 1000

                # Find the nearest saved history
                timeDiffNearest = Infinity
                indexNearest = 0
                for i in [0..@actions.length]
                    action = @actions.at(i)
                    timeDiff = Math.abs(action.get("time") - timeDest)
                    if timeDiff < timeDiffNearest
                        timeDiffNearest = timeDiff
                        indexNearest = i
                    else
                        break
                actionDest = @actions.at(indexNearest)

                # Create a past self
                pastSelf = new @PastSelf
                    player: new Player(@world.getTileWidth(), @world.getTileHeight())
                    actionIdNext: indexNearest + 1
                    timeRecreated: timeNow
                    timeDest: timeDest
                pastSelf.get("player").reset(@world.tileToPixelX(actionDest.get("playerX")), @world.tileToPixelY(actionDest.get("playerY")), actionDest.get("playerX"), actionDest.get("playerY"))
                @pastSelves.add(pastSelf)

                # Add this to history
                @writeHistory(timeNow, @player.x, @player.y, true)

        # Tell the player to move to the given position
        movePlayer: (x = 0, y = 0, timeNow) ->
            if (!@player.moving)
                @player.x += x
                @player.y += y
                @player.move(@world.tileToPixelX(@player.x), @world.tileToPixelY(@player.y))

                # Write this new state to history
                @writeHistory(timeNow, @player.x, @player.y)

        writeHistory: (timeNow, playerX, playerY, timeTravel = false) ->
            action = new @Action
                time: timeNow
                playerX: playerX
                playerY: playerY
                timeTravel: timeTravel
            @actions.add(action)

