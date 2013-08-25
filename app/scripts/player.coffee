###
    global define
###

define [], () ->
    "use strict"

    class Player

        # The actual canvas element
        elt: null

        # Config
        sprite: "images/character2.png"
        spriteWidth: 32
        spriteHeight: 32
        speed: 4              # body lengths/sec
        buffer: 3

        # Moving parameters
        moving: false
        movingToX: null
        movingToY: null

        # Time travel parameters
        timeTravelling: null
        timeAnimLength: 0.5
        timeAnimFrames: 7

        # The location and size of the player
        x: 0
        y: 0
        pxX: 0
        pxY: 0
        width: 0
        height: 0

        constructor: (width, height, startPxX, startPxY) ->
            # Set the given parameters
            @width = width
            @height = height
            @pxX = startPxX
            @pxY = startPxY

            # Create the canvas element
            @elt = new Image()
            @elt.src = @sprite

        # Render the player at the given location in the given context
        render: (ctx, dt, timeNow) ->
            # Move the player first if moving
            if (@moving)
              # Has the player arrived?
              if (@pxX == @movingToX and @pxY == @movingToY)
                  @moving = false
                  @movingToX = null
                  @movingToY = null
              # Otherwise, move the player towards the destination
              else
                  # Get correct x/y direction
                  dirX = @getMovingDirX()
                  dirY = @getMovingDirY()

                  # Set the new position, moving to the destinatiion
                  pxXNew = @pxX + Math.round(dirX * dt * @speed)
                  pxYNew = @pxY + Math.round(dirY * dt * @speed)
                  if ((pxXNew >= @movingToX - @buffer) && (pxXNew <= @movingToX + @buffer))
                      @pxX = @movingToX
                  else
                      @pxX += Math.round(dirX * dt * @speed * @spriteWidth)
                  if ((pxYNew >= @movingToY - @buffer) && (pxYNew <= @movingToY + @buffer))
                      @pxY = @movingToY
                  else
                      @pxY += Math.round(dirY * dt * @speed * @spriteHeight)

            # Draw the player
            spritePos = @getSpritePos(timeNow)
            ctx.drawImage(@elt, spritePos.x, spritePos.y, @spriteWidth, @spriteHeight, @pxX, @pxY, @width, @height)

        # Tell the player to move to a point in pixels
        move: (x, y) ->
            @moving = true
            @movingToX = x
            @movingToY = y

        # Tell the player to animate a time travel
        timeTravel: (time) ->
            @timeTravelling = time

        # Returns the direction currently moving along each axis
        # 1, -1, or 0
        getMovingDirX: () ->
            if !@moving
                return 0
            else if @movingToX < @pxX - @buffer
                return -1
            else if @movingToX > @pxX + @buffer
                return 1
            else
                return 0
        getMovingDirY: () ->
            if !@moving
                return 0
            else if @movingToY < @pxY - @buffer
                return -1
            else if @movingToY > @pxY - @buffer
                return 1
            else
                return 0

        # Get the sprite dimensions
        getSpritePos: (timeNow) ->
            # Default at-rest sprite
            pos =
                x: 0
                y: 0

            # If we're time travelling, animate that
            if @timeTravelling?
                dt = (timeNow - @timeTravelling) / 1000
                # Frame 1
                if dt / @timeAnimLength < 1 * @timeAnimLength / @timeAnimFrames
                    pos.x = 0
                    pos.y = @spriteHeight * 2
                else if dt / @timeAnimLength < 2 * @timeAnimLength / @timeAnimFrames
                    pos.x = @spriteWidth
                    pos.y = @spriteHeight * 2
                else if dt / @timeAnimLength < 3 * @timeAnimLength / @timeAnimFrames
                    pos.x = @spriteWidth * 2
                    pos.y = @spriteHeight * 2
                else if dt / @timeAnimLength < 4 * @timeAnimLength / @timeAnimFrames
                    pos.x = @spriteWidth * 3
                    pos.y = @spriteHeight * 2
                else if dt / @timeAnimLength < 5 * @timeAnimLength / @timeAnimFrames
                    pos.x = @spriteWidth * 2
                    pos.y = @spriteHeight * 2
                else if dt / @timeAnimLength < 6 * @timeAnimLength / @timeAnimFrames
                    pos.x = @spriteWidth
                    pos.y = @spriteHeight * 2
                else if dt / @timeAnimLength < 7 * @timeAnimLength / @timeAnimFrames
                    pos.x = 0
                    pos.y = @spriteHeight * 2
                else
                    @timeTravelling = null
            # Otherwise, animate a move
            else if @moving
                dirX = @getMovingDirX()
                dirY = @getMovingDirY()
                # If moving up
                if (dirY == -1)
                    pos.x = @spriteWidth
                    pos.y = @spriteHeight
                # Moving down
                else if (dirY == 1)
                    pos.x = 0
                    pos.y = @spriteHeight
                # If moving left
                if (dirX == -1)
                    pos.x = @spriteWidth * 2
                    pos.y = @spriteHeight
                else if (dirX == 1)
                    pos.x = @spriteWidth * 3
                    pos.y = @spriteHeight

            return pos

        # Reset position and status
        reset: (pxX = 0, pxY = 0, x = 0, y = 0) ->
            @moving = false
            @movingToX = null
            @movingToY = null
            @x = x
            @y = y
            @pxX = pxX
            @pxY = pxY

