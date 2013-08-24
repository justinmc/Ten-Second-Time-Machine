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
        speed: 100
        buffer: 3

        # Moving parameters
        moving: false
        movingToX: null
        movingToY: null

        # The location and size of the player
        x: 0
        y: 0
        pxX: 0
        pxY: 0
        width: 0
        height: 0

        constructor: (width, height) ->
            # Set the given parameters
            @width = width
            @height = height

            # Create the canvas element
            @elt = new Image()
            @elt.src = @sprite

        # Render the player at the given location in the given context
        render: (ctx, dt) ->
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
                      @pxX += Math.round(dirX * dt * @speed)
                  if ((pxYNew >= @movingToY - @buffer) && (pxYNew <= @movingToY + @buffer))
                      @pxY = @movingToY
                  else
                      @pxY += Math.round(dirY * dt * @speed)

            # Draw the player
            sprite = @getSpritePos()
            ctx.drawImage(@elt, sprite.x, sprite.y, @spriteWidth, @spriteHeight, @pxX, @pxY, @width, @height)

        # Tell the player to move to a point in pixels
        move: (x, y) ->
            @moving = true
            @movingToX = x
            @movingToY = y

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
        getSpritePos: () ->
            # Default at-rest sprite
            pos =
                x: 0
                y: 0

            if @moving
                dirX = @getMovingDirX()
                dirY = @getMovingDirY()
                # If moving up
                if (dirY == 1)
                    pos.x = 0
                    pos.y = 0
                # Moving down
                else if (dirY == -1)
                    pos.x = 1 * @spriteWidth
                    pos.y = 0
                # If moving left
                if (dirX == -1)
                    pos.x = 0
                    pos.y = 1 * @spriteHeight
                else if (dirX == 1)
                    pos.x = 1 * @spriteWidth
                    pos.y = 1 * @spriteHeight

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

