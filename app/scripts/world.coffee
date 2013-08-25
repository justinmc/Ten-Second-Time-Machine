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
        sprite: "images/tiles.png"
        spriteWidth: 32
        spriteHeight: 32

        # The size of the canvas in pixels
        canvasWidth: 0
        canvasHeight: 0

        # Tiles
        Tile: null
        Tiles: null
        tilesActive: null

        # World 1
        world1: null

        # Text paramaters
        textCurrent: ""
        textQueue: [
            "*Our hero, playing in the sand...*"
            "Big Kid 1: This playground sucks!  Let's go to our secret hideout, Big Kid 2!"
            "Big Kid 2: Our secret hideout is the coolest."
            "Big Kid 1: Alright, boost me over the wall!"
            "Hero: Hey, you guys have a secret hideout?"
            "Big Kid 2: So long!"
            "Hero: ...Who's going to boost me over?"
            "Use the <arrow keys> to move"
        ]
        textBackpackGet: [
            "Hero: Hey, my portable 10 second time machine backpack!"
            "Hero: Not quite as practical as a ladder..."
            "Hero: Or as practical as a regular time machine..."
            "Hero: But I think it might work!"
            "Press <space> to use"
        ]
        textInterval: 4
        textTimePlay: null

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
                    backpack = false
                    if (y == 0)
                        spritePos = @getSpritePosFence()
                        walkable = false
                        climbable = true
                    if (x == 10 and y == 10)
                        spritePos = @getSpritePosBackpack()
                        backpack = true
                    tile = new @Tile
                        x: x
                        y: y
                        spriteX: spritePos.x
                        spriteY: spritePos.y
                        walkable: walkable
                        climbable: climbable
                        backpack: backpack

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
            ctx.font = @fontSize + "px '" + @fontFamily + "'"
            if !@textTimePlay? and @textQueue.length
                @textTimePlay = timeNow
            else if @textQueue.length and (timeNow - @textTimePlay) / 1000 >= @textInterval
                @textCurrent = @textQueue.splice(0, 1)
                @textTimePlay = timeNow
            ctx.fillText(@textCurrent, 0, @canvasHeight - @textHeight + @fontSize, @canvasWidth)

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

        # Returns true if the given tile for the current world is the backpack, false otherwise
        isBackpack: (x, y) ->
            tile = @tilesActive.findWhere({"x": x, "y": y})
            if tile?
                return tile.get("backpack")
            else
                return false

        # Removes the backpack from the world, as when it is picked up
        removeBackpack: () ->
            tile = @world1.findWhere({"backpack": true})
            spritePos = @getSpritePos()
            tile.set("backpack", false)
            tile.set("spriteX", spritePos.x)
            tile.set("spriteY", spritePos.y)

            # Show the backpack get text
            @textQueue = @textBackpackGet

        # Show the win text
        win: () ->
            @textCurrent = "YOU WIN!!!"

        # Converts a tile coords to pixel coords
        tileToPixelX: (x) ->
            if (x < 0)
                x = 0
            if (x >= @width)
                x = @width - 1
            return Math.floor(x * @getTileWidth())
        tileToPixelY: (y) ->
            if (y <= -1)
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

        # Get the backpack sprite dimensions
        getSpritePosBackpack: () ->
            pos =
                x: @spriteWidth
                y: 0
            return pos

