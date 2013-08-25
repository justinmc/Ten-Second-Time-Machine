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
        textHeight: 64   # height of text bar in pixels
        fontFamily: "Press Start 2P"
        fontSize: 16
        sprite: "images/tile_sand.png"
        spriteWidth: 32
        spriteHeight: 32

        # The size of the canvas in pixels
        canvasWidth: 0
        canvasHeight: 0

        # Tile backbone containers
        Tile: null
        Tiles: null
        tilesActive: null

        # World 1
        world1: null

        # Intro content
        introTextCurrent: ""
        introText: [
            "*Our hero, playing in the sand...*"
            "Big kid 1: This playground sucks!  Let's go to our secret hideout, big kid 2!"
            "Big kid 2: Our secret hideout is the coolest."
            "Big kid 1: Alright, boost me over the wall!"
            "Hero: Hey, you guys have a secret hideout?"
            "Big kid 2: So long!"
            "Hero: ..."
            ""
        ]
        introInterval: 4
        introTimePlay: null

        # Create the world at the given size in pixels
        constructor: (x, y) ->
            @canvasWidth = x
            @canvasHeight = y

            # Create the tile backbone objects
            @Tile = Backbone.Model.extend()
            @Tiles = Backbone.Collection.extend
                model: @Tile
            @tilesActive = new @Tiles()

            # Create the starting world
            @world1 = new @Tiles()
            for x in [0..@width - 1]
                for y in [0..@height - 1]
                    spritePos = @getSpritePos()
                    walkable = true
                    climbable = false
                    if (y == 0)
                        spritePos = @getSpritePosFence()
                        walkable = false
                        climbable = true
                    tile = new @Tile
                        x: x
                        y: y
                        spriteX: spritePos.x
                        spriteY: spritePos.y
                        walkable: walkable
                        climbable: climbable

                    @world1.add(tile)

            # Set world 1 as active
            @tilesActive = @world1

            @elt = new Image()
            @elt.src = @sprite

        # Render the world in the given context
        render: (ctx, timeNow) ->
            # Render the active world
            me = @
            @tilesActive.forEach (tile) ->
                ctx.drawImage(me.elt, tile.get("spriteX"), tile.get("spriteY"), me.spriteWidth, me.spriteHeight, me.tileToPixelX(tile.get("x")), me.tileToPixelY(tile.get("y")), me.getTileWidth(), me.getTileHeight())

            # Render the text at the bottom
            if !@introTimePlay? and @introText.length
                @introTimePlay = timeNow
            else if @introText.length and (timeNow - @introTimePlay) / 1000 >= @introInterval
                @introTextCurrent = @introText.splice(0, 1)
                @introTimePlay = timeNow
            ctx.font = @fontSize + "px '" + @fontFamily + "'"
            ctx.fillText(@introTextCurrent, 0, @canvasHeight - @textHeight + @fontSize)

        # Returns true if the given tile for the current world is walkable, false otherwise
        isWalkable: (x, y) ->
            tile = @tilesActive.findWhere({"x": x, "y": y})
            if tile?
                return tile.get("walkable")
            else
                return false

        # Returns true if the given tile for the current world is climbale, false otherwise
        isClimbable: (x, y) ->
            tile = @tilesActive.findWhere({"x": x, "y": y})
            if tile?
                return tile.get("climbable")
            else
                return false

        # Converts a tile coords to pixel coords
        tileToPixelX: (x) ->
            if (x < 0)
                x = 0
            if (x >= @width)
                x = @width - 1
            return Math.floor(x * @getTileWidth())
        tileToPixelY: (y) ->
            if (y < 0)
                y = -1
            if (y >= @height)
                y = @heigth - 1
            return Math.floor(y * @getTileHeight())

        # Calculate the size of a tile
        getTileWidth: () ->
            return Math.floor(@canvasWidth / @width)
        getTileHeight: () ->
            return Math.floor((@canvasHeight - @textHeight) / @height)

        # Get the default empty sand sprite dimensions
        getSpritePos: () ->
            pos =
                x: 0
                y: 0
            return pos

        # Get the low fence sprite dimensions
        getSpritePosFence: () ->
            pos =
                x: 0
                y: @spriteHeight
            return pos

