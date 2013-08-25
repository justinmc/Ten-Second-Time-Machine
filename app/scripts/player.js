
/*
    global define
*/

(function() {

  define([], function() {
    "use strict";
    var Player;
    return Player = (function() {

      Player.prototype.elt = null;

      Player.prototype.sprite = "images/character.png";

      Player.prototype.spriteWidth = 32;

      Player.prototype.spriteHeight = 32;

      Player.prototype.speed = 4;

      Player.prototype.buffer = 3;

      Player.prototype.moving = false;

      Player.prototype.movingToX = null;

      Player.prototype.movingToY = null;

      Player.prototype.waitingUntil = null;

      Player.prototype.hasBackpack = false;

      Player.prototype.timeTravelling = null;

      Player.prototype.timeAnimLength = 0.5;

      Player.prototype.timeAnimFrames = 7;

      Player.prototype.x = 0;

      Player.prototype.y = 0;

      Player.prototype.pxX = 0;

      Player.prototype.pxY = 0;

      Player.prototype.width = 0;

      Player.prototype.height = 0;

      function Player(width, height, startPxX, startPxY, sprite) {
        if (sprite == null) sprite = null;
        this.width = width;
        this.height = height;
        this.pxX = startPxX;
        this.pxY = startPxY;
        if (sprite != null) this.sprite = sprite;
        this.elt = new Image();
        this.elt.src = this.sprite;
      }

      Player.prototype.render = function(ctx, dt, timeNow) {
        var dirX, dirY, pxXNew, pxYNew, spritePos;
        if (this.moving) {
          if (this.pxX === this.movingToX && this.pxY === this.movingToY) {
            this.moving = false;
            this.movingToX = null;
            this.movingToY = null;
          } else {
            dirX = this.getMovingDirX();
            dirY = this.getMovingDirY();
            pxXNew = this.pxX + Math.round(dirX * dt * this.speed);
            pxYNew = this.pxY + Math.round(dirY * dt * this.speed);
            if ((pxXNew >= this.movingToX - this.buffer) && (pxXNew <= this.movingToX + this.buffer)) {
              this.pxX = this.movingToX;
            } else {
              this.pxX += Math.round(dirX * dt * this.speed * this.spriteWidth);
            }
            if ((pxYNew >= this.movingToY - this.buffer) && (pxYNew <= this.movingToY + this.buffer)) {
              this.pxY = this.movingToY;
            } else {
              this.pxY += Math.round(dirY * dt * this.speed * this.spriteHeight);
            }
          }
        }
        if (timeNow >= this.waitingUntil) this.waitingUntil = null;
        spritePos = this.getSpritePos(timeNow);
        return ctx.drawImage(this.elt, spritePos.x, spritePos.y, this.spriteWidth, this.spriteHeight, this.pxX, this.pxY, this.width, this.height);
      };

      Player.prototype.move = function(x, y) {
        this.moving = true;
        this.movingToX = x;
        return this.movingToY = y;
      };

      Player.prototype.wait = function(time) {
        return this.waitingUntil = time;
      };

      Player.prototype.timeTravel = function(time) {
        return this.timeTravelling = time;
      };

      Player.prototype.getMovingDirX = function() {
        if (!this.moving) {
          return 0;
        } else if (this.movingToX < this.pxX - this.buffer) {
          return -1;
        } else if (this.movingToX > this.pxX + this.buffer) {
          return 1;
        } else {
          return 0;
        }
      };

      Player.prototype.getMovingDirY = function() {
        if (!this.moving) {
          return 0;
        } else if (this.movingToY < this.pxY - this.buffer) {
          return -1;
        } else if (this.movingToY > this.pxY - this.buffer) {
          return 1;
        } else {
          return 0;
        }
      };

      Player.prototype.getSpritePos = function(timeNow) {
        var dirX, dirY, dt, pos;
        pos = {
          x: 0,
          y: 0
        };
        if (this.timeTravelling != null) {
          dt = (timeNow - this.timeTravelling) / 1000;
          if (dt / this.timeAnimLength < 1 * this.timeAnimLength / this.timeAnimFrames) {
            pos.x = 0;
            pos.y = this.spriteHeight * 3;
          } else if (dt / this.timeAnimLength < 2 * this.timeAnimLength / this.timeAnimFrames) {
            pos.x = this.spriteWidth;
            pos.y = this.spriteHeight * 3;
          } else if (dt / this.timeAnimLength < 3 * this.timeAnimLength / this.timeAnimFrames) {
            pos.x = this.spriteWidth * 2;
            pos.y = this.spriteHeight * 3;
          } else if (dt / this.timeAnimLength < 4 * this.timeAnimLength / this.timeAnimFrames) {
            pos.x = this.spriteWidth * 3;
            pos.y = this.spriteHeight * 3;
          } else if (dt / this.timeAnimLength < 5 * this.timeAnimLength / this.timeAnimFrames) {
            pos.x = this.spriteWidth * 2;
            pos.y = this.spriteHeight * 3;
          } else if (dt / this.timeAnimLength < 6 * this.timeAnimLength / this.timeAnimFrames) {
            pos.x = this.spriteWidth;
            pos.y = this.spriteHeight * 3;
          } else if (dt / this.timeAnimLength < 7 * this.timeAnimLength / this.timeAnimFrames) {
            pos.x = 0;
            pos.y = this.spriteHeight * 3;
          } else {
            this.timeTravelling = null;
          }
        } else if (this.moving) {
          dirX = this.getMovingDirX();
          dirY = this.getMovingDirY();
          if (dirY === -1) {
            pos.x = this.spriteWidth;
          } else if (dirY === 1) {
            pos.x = 0;
          }
          if (dirX === -1) {
            pos.x = this.spriteWidth * 2;
          } else if (dirX === 1) {
            pos.x = this.spriteWidth * 3;
          }
          if (this.hasBackpack) {
            pos.y = this.spriteHeight * 2;
          } else {
            pos.y = this.spriteHeight;
          }
        } else if (this.hasBackpack) {
          pos.x = this.spriteWidth;
          pos.y = 0;
        }
        return pos;
      };

      Player.prototype.reset = function(pxX, pxY, x, y) {
        if (pxX == null) pxX = 0;
        if (pxY == null) pxY = 0;
        if (x == null) x = 0;
        if (y == null) y = 0;
        this.moving = false;
        this.movingToX = null;
        this.movingToY = null;
        this.x = x;
        this.y = y;
        this.pxX = pxX;
        return this.pxY = pxY;
      };

      return Player;

    })();
  });

}).call(this);
