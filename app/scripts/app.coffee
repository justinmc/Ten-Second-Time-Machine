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
        history: []

        # The time of the most recently completed render
        timeThen: null
        
        constructor: () ->
            # Set up the canvas
            @canvas = document.getElementById("app")
            @ctx = @canvas.getContext("2d")
            @ctx.mozImageSmoothingEnabled = false

            # Set the canvas size
            height = window.innerHeight
            width = height * 1.5
            windowRatio = window.innerWidth / window.innerHeight
            if (windowRatio < @canvasRatio)
                width = window.innerWidth
                height = width * @canvasRatio
            @canvas.width = width
            @canvas.height = height

            # Create assets
            @player = new Player()
            @world = new World(@canvas.width, @canvas.height)

            @timeThen = Date.now()
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
                    me.movePlayer(1, 0)
                if (input.isDown("SPACE"))
                    me.timeTravel(timeNow, timeNow)

                # Reset the canvas
                me.canvas.width = me.canvas.width

                # Render the background
                me.world.render(me.ctx)

                # Render the player
                me.player.render(me.ctx, dt)

                # Continue the loop
                me.timeThen = timeNow
                requestAnimationFrame(me.mainFactory())

        timeTravel: (timeNow) ->
            # Can't time travel if nothing has happened
            if @history.length and !@timeTraveled
                # Set the destination for 10 SECONDS ago
                timeDest = timeNow - 10 * 1000

                # Find the nearest saved history
                timeDiffNearest = 0
                indexNearest = 0
                for frame, i in @history
                    if Math.abs(frame.time - timeDest) < timeDiffNearest
                        timeDiffNearest = frame.time
                        indexNearest = i
                    else
                        break
                frameDest = @history[indexNearest]

                # Restore this frame
                @player.reset(@world.tileToPixelX(frameDest.playerX), @world.tileToPixelY(frameDest.playerY), frameDest.playerX, frameDest.playerY)
            
        # Tell the player to move to the given position
        movePlayer: (x = 0, y = 0, timeNow) ->
            if (!@player.moving)
                @player.x += x
                @player.y += y
                @player.move(@world.tileToPixelX(@player.x), @world.tileToPixelY(@player.y))

                # Write this new state to history
                @writeHistory(timeNow, @player.x, @player.y)

        writeHistory: (timeNow, playerX, playerY) ->
            frame =
                time: timeNow
                playerX: playerX
                playerY: playerY
            @history.push frame

