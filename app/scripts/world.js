
/*
    global define
*/

(function() {

  define([], function() {
    "use strict";
    var World;
    return World = (function() {

      World.prototype.elt = null;

      World.prototype.width = 18;

      World.prototype.height = 12;

      World.prototype.textHeight = 64;

      World.prototype.fontFamily = "Press Start 2P";

      World.prototype.fontSize = 16;

      World.prototype.sprite = "images/tiles.png";

      World.prototype.spriteWidth = 32;

      World.prototype.spriteHeight = 32;

      World.prototype.canvasWidth = 0;

      World.prototype.canvasHeight = 0;

      World.prototype.Tile = null;

      World.prototype.Tiles = null;

      World.prototype.tilesActive = null;

      World.prototype.world1 = null;

      World.prototype.textCurrent = "";

      World.prototype.textQueue = ["*Our hero, playing in the sand...*", "Big Kid 1: This playground sucks!  Let's go to our secret hideout, Big Kid 2!", "Big Kid 2: Our secret hideout is the coolest.", "Big Kid 1: Alright, boost me over the wall!", "Hero: Hey, you guys have a secret hideout?", "Big Kid 2: So long!", "Hero: ...Who's going to boost me over?", "Use the <arrow keys> to move"];

      World.prototype.textBackpackGet = ["Hero: Hey, my portable 10 second time machine backpack!", "Hero: Not quite as practical as a ladder...", "Hero: Or as practical as a regular time machine...", "Hero: But I think it might work!", "Press <space> to use"];

      World.prototype.textInterval = 4;

      World.prototype.textTimePlay = null;

      function World(x, y) {
        var backpack, climbable, spritePos, tile, walkable, _ref, _ref2;
        this.canvasWidth = x;
        this.canvasHeight = y;
        this.Tile = Backbone.Model.extend();
        this.Tiles = Backbone.Collection.extend({
          model: this.Tile
        });
        this.tilesActive = new this.Tiles();
        this.world1 = new this.Tiles();
        for (x = 0, _ref = this.width - 1; 0 <= _ref ? x <= _ref : x >= _ref; 0 <= _ref ? x++ : x--) {
          for (y = 0, _ref2 = this.height - 1; 0 <= _ref2 ? y <= _ref2 : y >= _ref2; 0 <= _ref2 ? y++ : y--) {
            spritePos = this.getSpritePos();
            walkable = true;
            climbable = false;
            backpack = false;
            if (y === 0) {
              spritePos = this.getSpritePosFence();
              walkable = false;
              climbable = true;
            }
            if (x === 10 && y === 10) {
              spritePos = this.getSpritePosBackpack();
              backpack = true;
            }
            tile = new this.Tile({
              x: x,
              y: y,
              spriteX: spritePos.x,
              spriteY: spritePos.y,
              walkable: walkable,
              climbable: climbable,
              backpack: backpack
            });
            this.world1.add(tile);
          }
        }
        this.tilesActive = this.world1;
        this.elt = new Image();
        this.elt.src = this.sprite;
      }

      World.prototype.render = function(ctx, timeNow) {
        var me;
        me = this;
        this.tilesActive.forEach(function(tile) {
          return ctx.drawImage(me.elt, tile.get("spriteX"), tile.get("spriteY"), me.spriteWidth, me.spriteHeight, me.tileToPixelX(tile.get("x")), me.tileToPixelY(tile.get("y")), me.getTileWidth(), me.getTileHeight());
        });
        ctx.font = this.fontSize + "px '" + this.fontFamily + "'";
        if (!(this.textTimePlay != null) && this.textQueue.length) {
          this.textTimePlay = timeNow;
        } else if (this.textQueue.length && (timeNow - this.textTimePlay) / 1000 >= this.textInterval) {
          this.textCurrent = this.textQueue.splice(0, 1);
          this.textTimePlay = timeNow;
        }
        return ctx.fillText(this.textCurrent, 0, this.canvasHeight - this.textHeight + this.fontSize, this.canvasWidth);
      };

      World.prototype.isWalkable = function(x, y) {
        var tile;
        tile = this.tilesActive.findWhere({
          "x": x,
          "y": y
        });
        if (tile != null) {
          return tile.get("walkable");
        } else {
          return false;
        }
      };

      World.prototype.isClimbable = function(x, y) {
        var tile;
        tile = this.tilesActive.findWhere({
          "x": x,
          "y": y
        });
        if (tile != null) {
          return tile.get("climbable");
        } else {
          return false;
        }
      };

      World.prototype.isBackpack = function(x, y) {
        var tile;
        tile = this.tilesActive.findWhere({
          "x": x,
          "y": y
        });
        if (tile != null) {
          return tile.get("backpack");
        } else {
          return false;
        }
      };

      World.prototype.removeBackpack = function() {
        var spritePos, tile;
        tile = this.world1.findWhere({
          "backpack": true
        });
        spritePos = this.getSpritePos();
        tile.set("backpack", false);
        tile.set("spriteX", spritePos.x);
        tile.set("spriteY", spritePos.y);
        return this.textQueue = this.textBackpackGet;
      };

      World.prototype.win = function() {
        return this.textCurrent = "YOU WIN!!!";
      };

      World.prototype.tileToPixelX = function(x) {
        if (x < 0) x = 0;
        if (x >= this.width) x = this.width - 1;
        return Math.floor(x * this.getTileWidth());
      };

      World.prototype.tileToPixelY = function(y) {
        if (y <= -1) y = -1;
        if (y >= this.height) y = this.heigth - 1;
        return Math.floor(y * this.getTileHeight());
      };

      World.prototype.getTileWidth = function() {
        return Math.floor(this.canvasWidth / this.width);
      };

      World.prototype.getTileHeight = function() {
        return Math.floor((this.canvasHeight - this.textHeight) / this.height);
      };

      World.prototype.getSpritePos = function() {
        var pos;
        pos = {
          x: 0,
          y: 0
        };
        return pos;
      };

      World.prototype.getSpritePosFence = function() {
        var pos;
        pos = {
          x: 0,
          y: this.spriteHeight
        };
        return pos;
      };

      World.prototype.getSpritePosBackpack = function() {
        var pos;
        pos = {
          x: this.spriteWidth,
          y: 0
        };
        return pos;
      };

      return World;

    })();
  });

}).call(this);
