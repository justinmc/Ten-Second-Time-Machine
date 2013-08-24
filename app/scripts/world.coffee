###
    global define
###

define [], () ->
    "use strict"

    class World

        # The actual canvas element
        elt: null

        # Config
        width: 18       # world width in tiles
        height: 12      # world height in tiles
        sprite: "images/tile_sand.png"

        # The size of the canvas in pixels
        canvasWidth: 0
        canvasHeight: 0

        # Create the world at the given size in pixels
        constructor: (x, y) ->
            @canvasWidth = x
            @canvasHeight = y

            @elt = new Image()
            @elt.src = @sprite

        # Render the world in the given context
        render: (ctx) ->
            # Render an image in every tile
            for x in [0..@width]
                for y in [0..@height]
                    ctx.drawImage(@elt, @tileToPixelX(x), @tileToPixelY(y), @getTileWidth(), @getTileHeight())

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

