###
    global define
###

define [], () ->
    "use strict"

    class World
        
        # The actual canvas element
        elt: null

        # Config
        width: 16       # world width in tiles
        height: 16      # world height in tiles

        # The size of the canvas in pixels
        canvasWidth: 0
        canvasHeight: 0

        # Create the world at the given size in pixels
        constructor: (x, y) ->
            @canvasWidth = x
            @canvasHeight = y

        # Render the world in the given context
        render: (ctx) ->
            ctx.fillStyle = "#abcdef"
            ctx.fillRect(0, 0, @canvasWidth, @canvasHeight)

        # Converts a tile coords to pixel coords
        tileToPixelX: (x) ->
            if (x < 0)
                x = 0
            if (x >= @width)
                x = @width - 1
            return Math.round(x * @getTileWidth())
        tileToPixelY: (y) ->
            if (y < 0)
                y = 0
            if (y >= @height)
                y = @heigth - 1
            return Math.round(y * @getTileHeight())

        # Calculate the size of a tile
        getTileWidth: () ->
            return Math.floor(@canvasWidth / @width)
        getTileHeight: () ->
            return Math.floor(@canvasHeight / @height)

