###
    global define
###

define [], () ->
    "use strict"

    class Player
        
        # The actual canvas element
        elt: null

        # Config
        sprite: "images/character.png"
        speed: 100

        # Moving parameters
        moving: false
        movingToX: null
        movingToY: null

        # The location of the player
        x: 0
        y: 0
        pxX: 0
        pxY: 0

        constructor: () ->
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
                  dirX = 0
                  dirY = 0
                  if (@movingToX < @pxX)
                      dirX = -1
                  else if (@movingToX > @pxX)
                      dirX = 1
                  if (@movingToY < @pxY)
                      dirY = -1
                  else if (@movingToY > @pxY)
                      dirY = 1

                  # Set the new position, moving to the destinatiion
                  pxXNew = @pxX + Math.round(dirX * dt * @speed)
                  pxYNew = @pxY + Math.round(dirY * dt * @speed)
                  if ((pxXNew >= @movingToX - 5) && (pxXNew <= @movingToX + 5))
                      @pxX = @movingToX
                  else
                      @pxX += Math.round(dirX * dt * @speed)
                  if ((pxYNew >= @movingToY - 5) && (pxYNew <= @movingToY + 5))
                      @pxY = @movingToY
                  else
                      @pxY += Math.round(dirY * dt * @speed)

            # Draw the player
            ctx.drawImage(@elt, @pxX, @pxY)

        # Tell the player to move to a point in pixels
        move: (x, y) ->
            @moving = true
            @movingToX = x
            @movingToY = y

        # Reset position and status
        reset: (pxX = 0, pxY = 0, x = 0, y = 0) ->
            @moving = false
            @movingToX = null
            @movingToY = null
            @x = x
            @y = y
            @pxX = pxX
            @pxY = pxY

