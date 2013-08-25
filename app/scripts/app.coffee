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
        bigKid1: null
        bigKid2: null
        bigKid1Actions: null
        bigKid2Actions: null

        # History of time!
        Action: null
        Actions: null
        actions: null
        PastSelf: null
        PastSelves: null
        pastSelves: null

        # Intro animation
        introActions: null

        # The time of the most recently completed render
        timeThen: null

        # Is the game over?
        won: false

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

            # Create world 1
            @world = new World(@canvas.width, @canvas.height)

            # Create the history backbone objects
            @Action = Backbone.Model.extend()
            @Actions = Backbone.Collection.extend
                model: @Action
            @actions = new @Actions()

            # Create the player at his starting position
            @player = new Player(@world.getTileWidth(), @world.getTileHeight(), @world.tileToPixelX(11), @world.tileToPixelY(10))
            @player.x = 11
            @player.y = 10

            # Create big kid 1
            @bigKid1 = new Player(@world.getTileWidth(), @world.getTileHeight(), @world.tileToPixelX(7), @world.tileToPixelY(4), "images/bigKid1.png")
            @bigKid1.x = 7
            @bigKid1.y = 4
            @bigKid1Actions = new @Actions()
            @bigKid1Actions.push new @Action
                playerX: @bigKid1.x
                playerY: -1
            @bigKid1Actions.push new @Action
                waitFor: 12
            @bigKid1Actions.push new @Action
                playerX: @bigKid1.x
                playerY: 1
            @bigKid1Actions.push new @Action
                waitFor: 8

            # Create big kid 2
            @bigKid2 = new Player(@world.getTileWidth(), @world.getTileHeight(), @world.tileToPixelX(8), @world.tileToPixelY(4), "images/bigKid2.png")
            @bigKid2.x = 8
            @bigKid2.y = 4
            @bigKid2Actions = new @Actions()
            @bigKid2Actions.push new @Action
                playerX: 7
                playerY: -1
            @bigKid2Actions.push new @Action
                waitFor: 6
            @bigKid2Actions.push new @Action
                playerX: 7
                playerY: 1
            @bigKid2Actions.push new @Action
                waitFor: 6
            @bigKid2Actions.push new @Action
                playerX: @bigKid2.x
                playerY: 1
            @bigKid2Actions.push new @Action
                waitFor: 12

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

                # Check if the player is on the backpack
                if !me.player.hasBackpack and me.world.isBackpack(me.player.x, me.player.y) and !me.world.textQueue.length
                    me.backpackGet()

                # Check if the player has escaped
                if me.player.y < 0 and !me.player.moving
                    me.win = true
                    me.world.win()

                # Render
                me.render(timeNow, dt)

                # Continue the loop
                if !me.win
                    me.timeThen = timeNow
                    requestAnimationFrame(me.mainFactory())

        # Render the scene on the canvas
        render: (timeNow, dt) ->
            # Reset the canvas
            @canvas.width = @canvas.width

            # Render the background
            @world.render(@ctx, timeNow)

            # Render npcs
            @renderNPC(@bigKid1, @bigKid1Actions, timeNow, dt)
            @renderNPC(@bigKid2, @bigKid2Actions, timeNow, dt)

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
                    player.render(me.ctx, dt, timeNow)

            # Render the player
            @player.render(@ctx, dt, timeNow)

        # Render a non-player and non-pastSelf character
        renderNPC: (player, actions, timeNow, dt) ->
            if !player.moving and !player.waitingUntil? and actions.length
                action = actions.pop()
                if action.get("waitFor")?
                    player.wait(timeNow + action.get("waitFor") * 1000)
                else
                    player.move(@world.tileToPixelX(action.get("playerX")), @world.tileToPixelY(action.get("playerY")))
            player.render(@ctx, dt, timeNow)

        timeTravel: (timeNow) ->
            # Can't time travel if nothing has happened, or no time travel backpack, or pastSelves exist
            if @actions.length and @player.hasBackpack and !@pastSelves.length
                # Set the destination for 10 SECONDS ago
                timeDest = timeNow - 10 * 1000

                # Find the nearest saved history
                timeDiffNearest = Infinity
                indexNearest = 0
                for i in [0..@actions.length - 1]
                    action = @actions.at(i)
                    timeDiff = Math.abs(action.get("time") - timeDest)
                    if timeDiff < timeDiffNearest
                        timeDiffNearest = timeDiff
                        indexNearest = i
                    else
                        break
                actionDest = @actions.at(indexNearest)

                # Create a past self
                player = new Player(@world.getTileWidth(), @world.getTileHeight(), @world.tileToPixelX(actionDest.get("playerX")), @world.tileToPixelY(actionDest.get("playerY")), "images/characterPast.png")
                player.x = actionDest.get("playerX")
                player.y = actionDest.get("playerY")
                pastSelf = new @PastSelf
                    player: player
                    actionIdNext: indexNearest + 1
                    timeRecreated: timeNow
                    timeDest: timeDest
                @pastSelves.add(pastSelf)

                # Add this to history
                @writeHistory(timeNow, @player.x, @player.y, true)

                # Tell the player to time travel
                @player.timeTravel(timeNow)

        # Tell the player to move to the given position
        movePlayer: (x = 0, y = 0, timeNow) ->
            if (!@player.moving)
                playerXNew = @player.x + x
                playerYNew = @player.y + y

                # For a climb move
                if (@world.isClimbable(playerXNew, playerYNew) && @isPastSelfAt(@player.x, @player.y))
                    @player.x = playerXNew + x
                    @player.y = playerYNew + y
                    @player.move(@world.tileToPixelX(@player.x), @world.tileToPixelY(@player.y))
                # For a regular walk move
                else if @world.isWalkable(playerXNew, playerYNew)
                    @player.x = playerXNew
                    @player.y = playerYNew
                    @player.move(@world.tileToPixelX(@player.x), @world.tileToPixelY(@player.y))

                # Write this new state to history
                @writeHistory(timeNow, @player.x, @player.y)

        # Pickup the backpack!
        backpackGet: () ->
            # Remove the backpack from the world
            @world.removeBackpack()

            # Give the player the backpack
            @player.hasBackpack = true

        # Returns true if a past self exists at the given location, false otherwise
        isPastSelfAt: (x, y) ->
            exists = false
            @pastSelves.forEach (pastSelf) ->
                player = pastSelf.get("player")
                if player.x == x and player.y == y
                    exists = true
            return exists

        writeHistory: (timeNow, playerX, playerY, timeTravel = false) ->
            action = new @Action
                time: timeNow
                playerX: playerX
                playerY: playerY
                timeTravel: timeTravel
            @actions.add(action)

