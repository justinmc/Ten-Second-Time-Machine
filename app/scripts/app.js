
/*
    global define
*/

(function() {

  define(["player", "world", "input"], function(Player, World, input) {
    "use strict";
    var App;
    return App = (function() {

      App.prototype.canvasRatio = 1.5;

      App.prototype.canvas = null;

      App.prototype.ctx = null;

      App.prototype.world = null;

      App.prototype.player = null;

      App.prototype.bigKid1 = null;

      App.prototype.bigKid2 = null;

      App.prototype.bigKid1Actions = null;

      App.prototype.bigKid2Actions = null;

      App.prototype.Action = null;

      App.prototype.Actions = null;

      App.prototype.actions = null;

      App.prototype.PastSelf = null;

      App.prototype.PastSelves = null;

      App.prototype.pastSelves = null;

      App.prototype.introActions = null;

      App.prototype.timeThen = null;

      App.prototype.won = false;

      function App() {
        var height, width, windowRatio;
        this.canvas = document.getElementById("app");
        this.ctx = this.canvas.getContext("2d");
        this.ctx.mozImageSmoothingEnabled = false;
        height = window.innerHeight - (window.innerHeight / 100);
        width = height * 1.5;
        windowRatio = window.innerWidth / window.innerHeight;
        if (windowRatio < this.canvasRatio) {
          width = window.innerWidth;
          height = width * this.canvasRatio;
        }
        this.canvas.width = width;
        this.canvas.height = height;
        this.world = new World(this.canvas.width, this.canvas.height);
        this.Action = Backbone.Model.extend();
        this.Actions = Backbone.Collection.extend({
          model: this.Action
        });
        this.actions = new this.Actions();
        this.player = new Player(this.world.getTileWidth(), this.world.getTileHeight(), this.world.tileToPixelX(11), this.world.tileToPixelY(10));
        this.player.x = 11;
        this.player.y = 10;
        this.bigKid1 = new Player(this.world.getTileWidth(), this.world.getTileHeight(), this.world.tileToPixelX(7), this.world.tileToPixelY(4), "images/bigKid1.png");
        this.bigKid1.x = 7;
        this.bigKid1.y = 4;
        this.bigKid1Actions = new this.Actions();
        this.bigKid1Actions.push(new this.Action({
          playerX: this.bigKid1.x,
          playerY: -1
        }));
        this.bigKid1Actions.push(new this.Action({
          waitFor: 12
        }));
        this.bigKid1Actions.push(new this.Action({
          playerX: this.bigKid1.x,
          playerY: 1
        }));
        this.bigKid1Actions.push(new this.Action({
          waitFor: 8
        }));
        this.bigKid2 = new Player(this.world.getTileWidth(), this.world.getTileHeight(), this.world.tileToPixelX(8), this.world.tileToPixelY(4), "images/bigKid2.png");
        this.bigKid2.x = 8;
        this.bigKid2.y = 4;
        this.bigKid2Actions = new this.Actions();
        this.bigKid2Actions.push(new this.Action({
          playerX: 7,
          playerY: -1
        }));
        this.bigKid2Actions.push(new this.Action({
          waitFor: 6
        }));
        this.bigKid2Actions.push(new this.Action({
          playerX: 7,
          playerY: 1
        }));
        this.bigKid2Actions.push(new this.Action({
          waitFor: 6
        }));
        this.bigKid2Actions.push(new this.Action({
          playerX: this.bigKid2.x,
          playerY: 1
        }));
        this.bigKid2Actions.push(new this.Action({
          waitFor: 12
        }));
        this.PastSelf = Backbone.Model.extend();
        this.PastSelves = Backbone.Collection.extend({
          model: this.PastSelf
        });
        this.pastSelves = new this.PastSelves();
        this.timeThen = Date.now();
        this.writeHistory(this.timeThen, 0, 0);
        this.main();
      }

      App.prototype.main = function() {
        return (this.mainFactory())();
      };

      App.prototype.mainFactory = function() {
        var me;
        me = this;
        return function() {
          var dt, timeNow;
          timeNow = Date.now();
          dt = (timeNow - me.timeThen) / 1000.0;
          if (input.isDown("UP")) me.movePlayer(0, -1, timeNow);
          if (input.isDown("DOWN")) me.movePlayer(0, 1, timeNow);
          if (input.isDown("LEFT")) me.movePlayer(-1, 0, timeNow);
          if (input.isDown("RIGHT")) me.movePlayer(1, 0, timeNow);
          if (input.isDown("SPACE")) me.timeTravel(timeNow, timeNow);
          if (!me.player.hasBackpack && me.world.isBackpack(me.player.x, me.player.y) && !me.world.textQueue.length) {
            me.backpackGet();
          }
          if (me.player.y < 0 && !me.player.moving) {
            me.win = true;
            me.world.win();
          }
          me.render(timeNow, dt);
          if (!me.win) {
            me.timeThen = timeNow;
            return requestAnimationFrame(me.mainFactory());
          }
        };
      };

      App.prototype.render = function(timeNow, dt) {
        var me;
        this.canvas.width = this.canvas.width;
        this.world.render(this.ctx, timeNow);
        this.renderNPC(this.bigKid1, this.bigKid1Actions, timeNow, dt);
        this.renderNPC(this.bigKid2, this.bigKid2Actions, timeNow, dt);
        me = this;
        this.pastSelves.each(function(pastSelf) {
          var action, player;
          player = pastSelf.get("player");
          action = me.actions.at(pastSelf.get("actionIdNext"));
          if ((action != null) && (timeNow - pastSelf.get("timeRecreated") + pastSelf.get("timeDest")) >= action.get("time")) {
            if (action.get("timeTravel")) {
              return me.pastSelves.remove(pastSelf);
            } else {
              player.x = action.get("playerX");
              player.y = action.get("playerY");
              player.move(me.world.tileToPixelX(player.x), me.world.tileToPixelY(player.y));
              player.render(me.ctx, dt);
              return pastSelf.set("actionIdNext", pastSelf.get("actionIdNext") + 1);
            }
          } else {
            return player.render(me.ctx, dt, timeNow);
          }
        });
        return this.player.render(this.ctx, dt, timeNow);
      };

      App.prototype.renderNPC = function(player, actions, timeNow, dt) {
        var action;
        if (!player.moving && !(player.waitingUntil != null) && actions.length) {
          action = actions.pop();
          if (action.get("waitFor") != null) {
            player.wait(timeNow + action.get("waitFor") * 1000);
          } else {
            player.move(this.world.tileToPixelX(action.get("playerX")), this.world.tileToPixelY(action.get("playerY")));
          }
        }
        return player.render(this.ctx, dt, timeNow);
      };

      App.prototype.timeTravel = function(timeNow) {
        var action, actionDest, i, indexNearest, pastSelf, player, timeDest, timeDiff, timeDiffNearest, _ref;
        if (this.actions.length && this.player.hasBackpack && !this.pastSelves.length) {
          timeDest = timeNow - 10 * 1000;
          timeDiffNearest = Infinity;
          indexNearest = 0;
          for (i = 0, _ref = this.actions.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
            action = this.actions.at(i);
            timeDiff = Math.abs(action.get("time") - timeDest);
            if (timeDiff < timeDiffNearest) {
              timeDiffNearest = timeDiff;
              indexNearest = i;
            } else {
              break;
            }
          }
          actionDest = this.actions.at(indexNearest);
          player = new Player(this.world.getTileWidth(), this.world.getTileHeight(), this.world.tileToPixelX(actionDest.get("playerX")), this.world.tileToPixelY(actionDest.get("playerY")), "images/characterPast.png");
          player.x = actionDest.get("playerX");
          player.y = actionDest.get("playerY");
          pastSelf = new this.PastSelf({
            player: player,
            actionIdNext: indexNearest + 1,
            timeRecreated: timeNow,
            timeDest: timeDest
          });
          this.pastSelves.add(pastSelf);
          this.writeHistory(timeNow, this.player.x, this.player.y, true);
          return this.player.timeTravel(timeNow);
        }
      };

      App.prototype.movePlayer = function(x, y, timeNow) {
        var playerXNew, playerYNew;
        if (x == null) x = 0;
        if (y == null) y = 0;
        if (!this.player.moving) {
          playerXNew = this.player.x + x;
          playerYNew = this.player.y + y;
          if (this.world.isClimbable(playerXNew, playerYNew) && this.isPastSelfAt(this.player.x, this.player.y)) {
            this.player.x = playerXNew + x;
            this.player.y = playerYNew + y;
            this.player.move(this.world.tileToPixelX(this.player.x), this.world.tileToPixelY(this.player.y));
          } else if (this.world.isWalkable(playerXNew, playerYNew)) {
            this.player.x = playerXNew;
            this.player.y = playerYNew;
            this.player.move(this.world.tileToPixelX(this.player.x), this.world.tileToPixelY(this.player.y));
          }
          return this.writeHistory(timeNow, this.player.x, this.player.y);
        }
      };

      App.prototype.backpackGet = function() {
        this.world.removeBackpack();
        return this.player.hasBackpack = true;
      };

      App.prototype.isPastSelfAt = function(x, y) {
        var exists;
        exists = false;
        this.pastSelves.forEach(function(pastSelf) {
          var player;
          player = pastSelf.get("player");
          if (player.x === x && player.y === y) return exists = true;
        });
        return exists;
      };

      App.prototype.writeHistory = function(timeNow, playerX, playerY, timeTravel) {
        var action;
        if (timeTravel == null) timeTravel = false;
        action = new this.Action({
          time: timeNow,
          playerX: playerX,
          playerY: playerY,
          timeTravel: timeTravel
        });
        return this.actions.add(action);
      };

      return App;

    })();
  });

}).call(this);
