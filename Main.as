package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.getTimer;
	import flash.ui.Mouse;
	//import flash.desktop.NativeApplication;
	import flash.ui.Keyboard;

	//https://www.gamasutra.com/blogs/BrandonSheffield/20150709/248217/Asset_placement_in_a_pseudo_3D_world__tricks_of_the_trade.php
	//https://lodev.org/cgtutor/raycasting.html
	//https://lodev.org/cgtutor/raycasting2.html
	//http://fabiensanglard.net/doomIphone/doomClassicRenderer.php
	//https://permadi.com/1996/05/ray-casting-tutorial-8/
	//http://www.extentofthejam.com/pseudo/
	//https://medium.com/@btco_code/writing-a-retro-3d-fps-engine-from-scratch-b2a9723e6b06
	//https://en.wikipedia.org/wiki/Scanline_rendering
	//https://www.youtube.com/watch?v=ybLZyY655iY
	//https://permadi.com/tutorial/raycast/demo/1/ - DEMO!!!
	//https://permadi.com/tutorial/raycast/demo/1/sample1.js
	//https://www.youtube.com/watch?v=HQYsFshbkYw&vl=en
	//http://qzx.com/pc-gpe/
	//https://raytomely.itch.io/raycasting-floorcasting


	public class Main extends MovieClip {

		var colors: Array = [
			0x0000FF, 0xFF0000, 0xFFFF00, 0x33FF00, 0x0000FF, 0xFF0000,
			0xFFFF00, 0x33FF00, 0x0000FF, 0xFF0000, 0xFFFF00, 0x33FF00,
			0xFFFF00, 0x33FF00, 0x0000FF, 0xFF0000, 0xFFFF00, 0x33FF00,
			0xFFFF00, 0x33FF00, 0x0000FF, 0xFF0000, 0xFFFF00, 0x33FF00,
			0x0000FF, 0xFF0000, 0xFFFF00, 0x33FF00, 0x0000FF, 0xFF0000,
			0x0000FF, 0xFF0000, 0xFFFF00, 0x33FF00, 0x0000FF
		];


		private static var TEXTURED_WALLS: Boolean = true;
		private static var SHOW_RAYS: Boolean = false;
		private static var RAINBOW_RAYS: Boolean = false;
		private static var DARKEN_ENV: Boolean = false;
		private static var WALLS_ONLY: Boolean = false;
		private static var SHOW_FURNITURE: Boolean = true;
		private static var SHOW_ENEMIES: Boolean = true;
		private static var SHOW_FPS: Boolean = false;


		private var bob: Bob = new Bob();
		private var linesLayer: Shape = new Shape();
		private var keyCtrl: KeyboardCtrl;
		private var centerObj: Object;
		private var twoPi: Number = Math.PI * 2;

		private var bmd: BitmapData;
		private var mapWidth: int;
		private var mapHeight: int;
		private var numRays: Number;

		private var allWalls: BitmapData = new AllWalls();
		private var allWallsTS: int = 64;

		private var walls: Array;
		private var statics: Array = [new Img5(), new Img6(), new Img7(), new Img8()];
		private var enemySprites: Array = [new Img8()];
		private var enemyUpdateList: Array = [];
		private var furnitureUpdateList: Array = [];


		private var currLines: Array = [];

		private var mapHolder: Sprite = new Sprite();

		private var allEnemies: Array = [];
		private var allStatics: Array = [];
		private var objsList: Array = [];
		private var totalIterations: int = 0;

		//floor casting
		private var nearPlane: Number = 11;
		private var farPlane: Number = 102;
		private var floorTile: BlitTexture = new BlitTexture(3, 11, allWallsTS, allWalls);
		private var ceilTile: BlitTexture = new BlitTexture(0, 15, allWallsTS, allWalls);

		//top and bottom colors
		private var topRect: Rectangle;
		private var btmRect: Rectangle;

		public function Main() {
			walls = [
				new BlitTexture(0, 0, allWallsTS, allWalls),
				new BlitTexture(2, 2, allWallsTS, allWalls),
				new BlitTexture(4, 3, allWallsTS, allWalls),
				new BlitTexture(4, 4, allWallsTS, allWalls)
			];
			Model.windowH = stage.stageHeight;
			Model.windowW = stage.stageWidth / 2;
			Model.colW = 1;
			numRays = Model.windowW / Model.colW;

			for (var i: int = 0; i < numRays; i++) {
				currLines[i] = new ColCont();
			}

			mapWidth = Model.TILE_SIZE * Model.roomArr[0].length;
			mapHeight = Model.TILE_SIZE * Model.roomArr.length;
			keyCtrl = new KeyboardCtrl(stage);
			bmd = new BitmapData(Model.windowW, Model.windowH, false, 0x33ff00);
			topRect = new Rectangle(0, 0, bmd.width, bmd.height / 2);
			btmRect = new Rectangle(0, bmd.height / 2, bmd.width, bmd.height / 2);
			//floorBD = new BitmapData(mapWidth, mapHeight, false, 0xffffff);
			//ceilBD = new BitmapData(mapWidth, mapHeight, false, 0xffffff);
			var bmp: Bitmap = new Bitmap(bmd);
			stage.addChild(bmp);
			bmp.x = stage.stageWidth - bmp.width;

			createBoard();
			handle3D();
			stage.addEventListener(Event.ENTER_FRAME, update);
			stage.addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(KeyboardEvent.KEY_UP, myKeyDown);
			if(SHOW_FPS)
			{
				FPSCounter.fpsCounter(stage);
			}
			
		}



		function createBoard(): void {

			mapHolder.addChild(bob);
			bob.x = (Model.roomArr[0].length * Model.TILE_SIZE) / 2;
			bob.y = (Model.roomArr.length * Model.TILE_SIZE) / 4;
			bob.innerMC.rotation = -17; //104; //-91;//Model.INITIAL_ROTATION;
			var tile: Wall;

			for (var row: int = 0; row < Model.roomArr.length; row++) {
				allStatics[row] = [];
				allEnemies[row] = [];
				for (var col: int = 0; col < Model.roomArr[row].length; col++) {


					if (Model.roomArr[row][col] == 1 ||
						Model.roomArr[row][col] == 2 ||
						Model.roomArr[row][col] == 3 ||
						Model.roomArr[row][col] == 4) {
						tile = new Wall();
						tile.width = Model.TILE_SIZE
						tile.height = Model.TILE_SIZE
						mapHolder.addChild(tile);
						tile.alpha = 0.5;
						tile.x = col * Model.TILE_SIZE;
						tile.y = row * Model.TILE_SIZE;
					}

					if (true) {
						if (Model.enemiesArr[row][col] == 9) {
							var _type: int = 3; //Model.enemiesArr[row][col];
							tile = new Wall();
							tile.width = Model.TILE_SIZE * 0.3;
							tile.height = Model.TILE_SIZE * 0.3;
							tile.row = row;
							tile.col = col;
							mapHolder.addChild(tile);
							tile.alpha = 0.5;
							tile.x = col * Model.TILE_SIZE;
							tile.y = row * Model.TILE_SIZE;
							tile.x += Model.TILE_SIZE * 0.5;
							tile.y += Model.TILE_SIZE * 0.5;
							tile.seen = false;
							tile.type = _type;
							tile.staticType = "enemy";
							//allEnemies[row][col] = tile;
							enemyUpdateList.push(tile);
						}
					}

					if (true) {
						if (Model.objsArr[row][col] == 5 ||
							Model.objsArr[row][col] == 6 ||
							Model.objsArr[row][col] == 7 ||
							Model.objsArr[row][col] == 8) {
							var _type: int = Model.objsArr[row][col] - 5;
							tile = new Wall();
							tile.width = Model.TILE_SIZE * 0.5;
							tile.height = Model.TILE_SIZE * 0.5;
							tile.row = row;
							tile.col = col;
							mapHolder.addChild(tile);
							tile.alpha = 0.5;
							tile.x = col * Model.TILE_SIZE;
							tile.y = row * Model.TILE_SIZE;
							tile.x += Model.TILE_SIZE * 0.5;
							tile.y += Model.TILE_SIZE * 0.5;
							tile.seen = false;
							tile.staticType = "furniture";
							tile.type = _type;
							furnitureUpdateList.push(tile);
							//allStatics[row][col] = tile;
						}
					}

				}
			}


			mapHolder.addChild(linesLayer);
			stage.addChild(mapHolder);
			mapHolder.width = stage.stageWidth / 2;
			mapHolder.height = stage.stageHeight;
			mapHolder.y = 0;
			mapHolder.x = 0;
		}

		function myKeyDown(e: KeyboardEvent): void {
			
			/*
		private static var SHOW_ENEMIES: Boolean = true;
			
			*/
			
			if (e.keyCode == Keyboard.F1) {
				DARKEN_ENV = !DARKEN_ENV;
			}
			if (e.keyCode == Keyboard.F2) {
				TEXTURED_WALLS = !TEXTURED_WALLS;
				
				if(TEXTURED_WALLS)
				{
					DARKEN_ENV = false;
				}
			}
			if (e.keyCode == Keyboard.F3) {
				SHOW_RAYS = !SHOW_RAYS;
			}
			if (e.keyCode == Keyboard.F4) {
				RAINBOW_RAYS = !RAINBOW_RAYS;
			}
			
			if (e.keyCode == Keyboard.F5) {
				WALLS_ONLY = !WALLS_ONLY;
			}
			if (e.keyCode == Keyboard.F6) {
				SHOW_FURNITURE = !SHOW_FURNITURE;
			}
			if (e.keyCode == Keyboard.F7) {
				SHOW_ENEMIES = !SHOW_ENEMIES;
			}
		}

		function onClick(e: MouseEvent): void {
			trace(bob.innerMC.rotation, bob.x, bob.y);
		}

		function drawCrossHair(_pX: int, _pY: int): void {
			var color: uint = 0xff0000;

			bmd.setPixel(_pX, _pY - 3, color);
			bmd.setPixel(_pX, _pY - 2, color);
			bmd.setPixel(_pX, _pY - 1, color);

			bmd.setPixel(_pX, _pY, color);

			bmd.setPixel(_pX, _pY + 1, color);
			bmd.setPixel(_pX, _pY + 2, color);
			bmd.setPixel(_pX, _pY + 3, color);

			bmd.setPixel(_pX - 1, _pY, color);
			bmd.setPixel(_pX - 2, _pY, color);
			bmd.setPixel(_pX - 3, _pY, color);

			bmd.setPixel(_pX + 1, _pY, color);
			bmd.setPixel(_pX + 2, _pY, color);
			bmd.setPixel(_pX + 3, _pY, color);
		}

		function isBlocking(_x: Number, _y: Number): Boolean {

			if (_y < 0 || _y >= mapHeight || _x < 0 || _x >= mapWidth) {
				return true;
			}

			return (Model.roomArr[Math.floor(_y / Model.TILE_SIZE)][Math.floor(_x / Model.TILE_SIZE)] != 0);
		}

		function updateEnemies(leftAngle: Number, rightAngle: Number, totalViewRange: Number): void {
			for (var i: int = 0; i < enemyUpdateList.length; i++) {
				var enemy: Wall = enemyUpdateList[i];
				var row: int = enemy.y / Model.TILE_SIZE;
				var col: int = enemy.x / Model.TILE_SIZE;
				var xDiff: Number = (enemy.x - bob.x);
				var yDiff: Number = (enemy.y - bob.y);
				var distToPlayer: Number = Math.sqrt(xDiff * xDiff + yDiff * yDiff);

				getSpriteHit(enemy, leftAngle, rightAngle, totalViewRange);

				//if enemy is close to player
				if (distToPlayer < Model.ENEMY_RANGE && distToPlayer > Model.ENEMY_RANGE / 2) {
					var angleToPlayer: Number = Math.atan2(yDiff, xDiff);
					enemy.x -= Math.cos(angleToPlayer) * Model.ENEMY_SPEED;
					enemy.y -= Math.sin(angleToPlayer) * Model.ENEMY_SPEED;
					var new_row: int = enemy.y / Model.TILE_SIZE;
					var new_col: int = enemy.x / Model.TILE_SIZE;
					if (new_row != row || new_col != col) {
						Model.enemiesArr[row][col] = 0;
						Model.enemiesArr[new_row][new_col] = 9;
					}
				}
			}

		}

		function update(e: Event): void {

			if (Model.G) {
				farPlane -= 1;
				trace("far", farPlane);
			}
			if (Model.H) {
				farPlane += 1;
				trace("far", farPlane);
			}
			if (Model.B) {
				nearPlane -= 1;
				trace("near", nearPlane);
			}
			if (Model.N) {
				nearPlane += 1;
				trace("near", nearPlane);
			}




			totalIterations = 0;

			for (var i: int = 0; i < objsList.length; i++) {
				objsList[i].seen = false;
			}

			objsList = [];

			var origX: int = bob.x;
			var origY: int = bob.y;
			var newX: Number;
			var newY: Number

			if (Model.turnsObj.up || Model.turnsObj.down) {

				var rad: Number = Model.SPEED;
				var angle: Number = Utils.degFromRot(bob.innerMC.rotation) * Math.PI / 180;
				var dirX: Number = rad * Math.cos(angle);
				var dirY: Number = rad * Math.sin(angle);

				if (Model.turnsObj.up) {

					newX = bob.x + dirX;
					newY = bob.y + dirY;

					if (!isBlocking(newX, newY)) {
						bob.x = newX;
						bob.y = newY;
					} else {
						//check if i can move on x or y axis
						if (!isBlocking(origX, newY)) {
							bob.x = origX;
							bob.y = newY;
						} else if (!isBlocking(newX, origY)) {
							bob.x = newX;
							bob.y = origY;
						}
					}
				}

				if (Model.turnsObj.down) {
					newX = bob.x - dirX;
					newY = bob.y - dirY;

					if (!isBlocking(newX, newY)) {
						bob.x = newX;
						bob.y = newY;
					} else {
						if (!isBlocking(origX, newY)) {
							bob.x = origX;
							bob.y = newY;
						} else if (!isBlocking(newX, origY)) {
							bob.x = newX;
							bob.y = origY;
						}
					}
				}

			}

			var leftStrafeRot: Number = Utils.radFromDeg(Utils.degFromRot(bob.innerMC.rotation - 90));
			newX = Math.cos(leftStrafeRot) * Model.TURN_SPEED;
			newY = Math.sin(leftStrafeRot) * Model.TURN_SPEED;

			//added strafing!!!!
			if (Model.turnsObj.left) {
				if (!isBlocking(bob.x - newX, bob.y - newY)) {
					bob.x -= newX;
					bob.y -= newY;
				}

			}
			if (Model.turnsObj.right) {
				if (!isBlocking(bob.x + newX, bob.y + newY)) {
					bob.x += newX;
					bob.y += newY;
				}
			}

			bob.innerMC.rotation = stage.mouseX + (stage.stageWidth / 2) * 0.1;
			//Mouse.hide();


			handle3D();
			//
			//stage.removeEventListener(Event.ENTER_FRAME, update);
			//trace(bob.x, bob.y, bob.innerMC.rotation);
		}

		function floorCast(leftRay: Number, rightRay: Number, playerX: Number, playerY: Number): void {

			var leftRaySin: Number = Math.sin(leftRay);
			var leftRayCos: Number = Math.cos(leftRay);

			var rightRaySin: Number = Math.sin(rightRay);
			var rightRayCos: Number = Math.cos(rightRay);

			//far topleft
			var currentFarX1: Number = playerX + leftRayCos * farPlane;
			var currentFarY1: Number = playerY + leftRaySin * farPlane;

			//far top right
			var currentFarX2: Number = playerX + rightRayCos * farPlane;
			var currentFarY2: Number = playerY + rightRaySin * farPlane;

			//near bottom left
			var currentNearX1: Number = playerX + leftRayCos * nearPlane;
			var currentNearY1: Number = playerY + leftRaySin * nearPlane;

			//near bottom right
			var currentNearX2: Number = playerX + rightRayCos * nearPlane;
			var currentNearY2: Number = playerY + rightRaySin * nearPlane;

			//go from top to bottom
			for (var _y: int = 0; _y < (Model.windowH / 2); _y++) {
				//get percentage of descent
				var sampleDepth: Number = Number(_y) / Number(Model.windowH/2);

				//get start x and y pixel at this percentage
				var startX: Number = (currentFarX1 - currentNearX1) / (sampleDepth) + currentNearX1;
				var startY: Number = (currentFarY1 - currentNearY1) / (sampleDepth) + currentNearY1;

				var endX: Number = (currentFarX2 - currentNearX2) / (sampleDepth) + currentNearX2;
				var endY: Number = (currentFarY2 - currentNearY2) / (sampleDepth) + currentNearY2;

				//new find e percantage
				for (var _x: int = 0; _x < Model.windowW; _x++) {
					//get percentage of width
					var sampleWidth: Number = Number(_x) / Number(Model.windowW);
					var currX: Number = (endX - startX) * sampleWidth + startX;

					if (isNaN(currX)) {
						currX = 0;
					}


					var currY: Number = (endY - startY) * sampleWidth + startY;

					if (isNaN(currY)) {
						currY = 0;
					}

					//instead of getting the pixel from a large bitmapData, i can get it from the map
					//var pixel: uint = floorBD.getPixel(currX, currY);

					var mapRow: int = currY / Model.TILE_SIZE;
					var mapCol: int = currX / Model.TILE_SIZE;

					var tileRowThreshold: int = mapRow * Model.TILE_SIZE;
					var tileColThreshold: int = mapCol * Model.TILE_SIZE;

					var realX: int = currX - tileColThreshold;
					var realY: int = currY - tileRowThreshold;

					var pixel: uint = floorTile.getPixel(realX / Model.TILE_SIZE, realY / Model.TILE_SIZE);
					////////////////////////////////////////////////////////

					bmd.setPixel(_x, _y + (Model.windowH / 2), pixel);

					//pixel = ceilBD.getPixel(currX, currY);
					pixel = ceilTile.getPixel(realX / Model.TILE_SIZE, realY / Model.TILE_SIZE);

					bmd.setPixel(_x, (Model.windowH / 2) - _y, pixel);
				}
			}

		}

		function handle3D(): void {



			//set color for rays
			linesLayer.graphics.clear();
			linesLayer.graphics.lineStyle(1, 0xFF0000, 1);

			var rot: Number = Utils.degFromRot(bob.innerMC.rotation);
			var forwardRad: Number = Utils.radFromDeg(rot);
			//trace(rot,rad);

			var centerPoint: Point = new Point(bob.x, bob.y); //+ (Model.TILE_SIZE / 2),
			var count: int = 0;
			var per: Number;
			bmd.lock();

			if (!WALLS_ONLY) {
				floorCast(forwardRad - Model.RAD_VIEW_LIMIT, forwardRad + Model.RAD_VIEW_LIMIT, bob.x, bob.y);
			} else {
				//create ceiling and floor

				bmd.fillRect(topRect, 0x666666);
				bmd.fillRect(btmRect, 0x333333);
			}

			if (SHOW_ENEMIES) {
				updateEnemies(forwardRad - (Model.RAD_VIEW_LIMIT), forwardRad + (Model.RAD_VIEW_LIMIT), (2 * Model.RAD_VIEW_LIMIT));
			}
			if (SHOW_FURNITURE) {
				for (var h: int = 0; h < furnitureUpdateList.length; h++) {
					var fur: Wall = furnitureUpdateList[h];
					var row: int = fur.y / Model.TILE_SIZE;
					var col: int = fur.x / Model.TILE_SIZE;
					var xDiff: Number = (fur.x - bob.x);
					var yDiff: Number = (fur.y - bob.y);
					var distToPlayer: Number = Math.sqrt(xDiff * xDiff + yDiff * yDiff);
					getSpriteHit(fur, forwardRad - (Model.RAD_VIEW_LIMIT), forwardRad + (Model.RAD_VIEW_LIMIT), (2 * Model.RAD_VIEW_LIMIT));
				}

			}





			for (var i: Number = 0; i < numRays; i++) {

				per = i / numRays;
				var radInRange: Number = (Model.RAD_VIEW_LIMIT * 2) * per;
				var actualRad: Number = -Model.RAD_VIEW_LIMIT + radInRange + forwardRad;

				var endPoint: ColCont = rayCast(centerPoint, actualRad, forwardRad, i, forwardRad - Model.RAD_VIEW_LIMIT, 2 * Model.RAD_VIEW_LIMIT);

				if (SHOW_RAYS) {
					if (!RAINBOW_RAYS) {
						linesLayer.graphics.moveTo(centerPoint.x, centerPoint.y);
						linesLayer.graphics.lineTo(endPoint.x, endPoint.y);
					}

				} else {
					if (per == 0.5 || per == 0 || per == 0.9) {
						linesLayer.graphics.moveTo(centerPoint.x, centerPoint.y);
						linesLayer.graphics.lineTo(endPoint.x, endPoint.y);
					}
				}


			}

			/////////
			//now draw all cols
			var mousePer: Number = 0; //(Model.windowH / 2 - mouseY) / Model.windowH;

			var drawStartCol: int = 0;
			var perInTotalDistances: Number = 0;
			for (var j: int = 0; j < currLines.length; j++) {
				var rayObj: ColCont = currLines[j];

				var newStartCol: int = 0
				newStartCol = drawCol(rayObj, drawStartCol, mousePer);
				drawStartCol = newStartCol;

			}

			if (SHOW_FURNITURE || SHOW_ENEMIES) {
				//draw statics
				objsList.sortOn("imgHeight", Array.NUMERIC);

				for (j = 0; j < objsList.length; j++) {
					var obj: Wall = objsList[j];
					if (SHOW_FURNITURE == false && obj.staticType == "furniture") {
						continue;
					}

					if (SHOW_ENEMIES == false && obj.staticType == "enemy") {
						continue;
					}


					var img: BitmapData = statics[obj.type];

					per = (1 - (obj.imgScaleHeight) * 5);
					if (per > 1) {
						per = 1;
					} else if (per < 0) {
						per = 0;
					}


					var scale: Number = obj.imgHeight / img.height;
					var wallY: int = (Model.windowH - obj.imgHeight) / 2;
					wallY += Model.windowH * mousePer * obj.imgScaleHeight * 0.5;

					// need to scale the sprite based on its distance
					var matrix: Matrix = new Matrix();
					matrix.scale(scale, scale);
					var scaledBMD: BitmapData = new BitmapData(img.width * scale, img.height * scale, true, 0x000000);
					scaledBMD.draw(img, matrix, null, null, null, true);
					if (DARKEN_ENV) {
						for (var h: int = 0; h < scaledBMD.height; h++) {
							for (var g: int = 0; g < scaledBMD.width; g++) {
								var pixel: uint = scaledBMD.getPixel(g, h);
								if (pixel == 0) {
									continue;
								}
								if (per < 1) {
									pixel = ColorUtils.darken(pixel, per);
								}

								scaledBMD.setPixel(g, h, pixel);
							}
						}
					}

					var drawStartCol: int = obj.screenI;
					var halfW: int = (scaledBMD.width / 2);
					bmd.copyPixels(scaledBMD, new Rectangle(0, 0, scaledBMD.width, scaledBMD.height), new Point(drawStartCol - halfW, wallY));

					//now go over all walls that image may be in front of and repaint them
					for (i = drawStartCol - halfW; i < drawStartCol + halfW; i++) {
						if (i > 0 && i < numRays) {
							var wallCol: ColCont = currLines[i];
							if (wallCol.wallHeight > obj.imgHeight) {
								drawCol(wallCol, i, mousePer);
							}
						}

					}
				}
			}


			drawCrossHair(Model.windowW / 2, (Model.windowH / 2));
			bmd.unlock();
			totalIterations = 0;
		}




		function rayCast(point: Point, radAngle: Number, centerRad: Number, i: int, rangeMin: Number, totalViewRange: Number): ColCont {

			if (radAngle < 0) {
				radAngle += twoPi;
			} else if (radAngle > twoPi) {
				radAngle -= twoPi;
			}

			if (rangeMin < 0) {
				rangeMin += twoPi;
			} else if (rangeMin > twoPi) {
				rangeMin -= twoPi;
			}
			var color: int = 0;
			var row: int = bob.y / Model.TILE_SIZE;
			var col: int = bob.x / Model.TILE_SIZE;
			var textureX: Number; // the x-coord on the texture of the block, ie. what part of the texture are we going to render		

			var totalRadius: int = 0;
			var right: Boolean = (radAngle > (twoPi) * 0.75 || radAngle < (twoPi) * 0.25);
			var up: Boolean = (radAngle < 0 || radAngle > Math.PI);
			var angleSin: Number = Math.sin(radAngle);
			var angleCos: Number = Math.cos(radAngle);
			var angleTan: Number = Math.tan(radAngle);
			var newX: Number;
			var newY: Number;
			var found: Boolean = false;
			var newRow: int;
			var newCol: int;
			var goingToRow: Boolean;
			while (!found) {

				totalIterations++;
				var distToNextX: Number;
				var distToNextY: Number;
				var destCol: int;
				var destRow: int;

				if (right) {

					destCol = (Model.TILE_SIZE * (col + 1));
					distToNextX = destCol - point.x;
					if (!up) {
						//trace("right down");
						destRow = (Model.TILE_SIZE * (row + 1));
						distToNextY = destRow - point.y;

					} else {
						//trace("right up");
						destRow = (Model.TILE_SIZE * (row));
						distToNextY = point.y - destRow;
					}

				} else {
					destCol = (Model.TILE_SIZE * (col));
					distToNextX = point.x - destCol;

					if (!up) {
						//trace("left down");
						destRow = (Model.TILE_SIZE * (row + 1));
						distToNextY = destRow - point.y;
					} else {
						//trace("left up");
						destRow = (Model.TILE_SIZE * (row));
						distToNextY = point.y - (destRow);
					}
				}
				//trace("distToNextX", distToNextX, "destCol", destCol);
				//trace("distToNextY", distToNextY, "destRow", destRow);

				//if x is closer, we need to figure out how long y needs to be
				var tempDistY: Number = (distToNextX * angleTan);
				var tempDistX: Number = (distToNextY / angleTan);

				//now that i have x and y i can get the radius
				var radius1: Number = Math.sqrt(tempDistX * tempDistX + distToNextY * distToNextY);
				var radius2: Number = Math.sqrt(distToNextX * distToNextX + tempDistY * tempDistY);
				var radius: Number;


				radius = Math.min(radius1, radius2);

				//going to hit a row
				goingToRow = radius == radius1;

				if (goingToRow) {
					newY = Math.ceil((radius * angleSin) + point.y);
					newX = (radius * angleCos) + point.x;
				} else {
					newY = (radius * angleSin) + point.y;
					newX = Math.ceil((radius * angleCos) + point.x);
				}

				if (SHOW_RAYS && RAINBOW_RAYS) {
					linesLayer.graphics.moveTo(point.x, point.y);
					linesLayer.graphics.lineStyle(1, colors[color], 1);
					linesLayer.graphics.lineTo(newX, newY);
				}


				newRow = Math.ceil(newY) / Model.TILE_SIZE; //
				newCol = Math.ceil(newX) / Model.TILE_SIZE; //

				if (up) {
					newRow = (newY - 0.5) / Model.TILE_SIZE;
				}

				if (!right) {
					newCol = (newX - 0.5) / Model.TILE_SIZE;
				}

				if (SHOW_FURNITURE) {
					//getSpriteHit(allStatics[newRow][newCol], rangeMin, totalViewRange);
				}



				//trace(newY, newX, newRow, newCol);
				if (Model.roomArr[newRow][newCol] == 0) {
					if (goingToRow) {
						if (up) {
							row--;
						} else {
							row++;
						}
					} else {
						if (right) {
							col++;
						} else {
							col--;
						}
					}

					point = new Point(newX, newY);
					totalRadius += radius;
					color++;
				} else {
					found = true;
					if (goingToRow) {
						newY = newY - (newY % Model.TILE_SIZE);
					} else {
						newX = newX - (newX % Model.TILE_SIZE);

					}

					var x1: Number = Math.abs(newX - bob.x);
					var y1: Number = Math.abs(newY - bob.y);

					totalRadius = Math.sqrt(x1 * x1 + y1 * y1);
				}
			}



			//the distance on the wall itself from where the ray hit to the beginning of the tile
			var amountX: Number = Math.abs(newX - (newCol * Model.TILE_SIZE));
			var amountY: Number = Math.abs(newY - (newRow * Model.TILE_SIZE));

			//the percentage if the ray x,y of the tile size
			var perX: Number = amountX / Model.TILE_SIZE;
			var perY: Number = amountY / Model.TILE_SIZE;


			//if we hit a wall aligned with the x axis, our texture will be calculated along the y axis
			if (goingToRow) {
				textureX = perX;
				if (!up) textureX = 1 - textureX;

			} else {
				textureX = perY;
				if (!right) textureX = 1 - textureX;
			}


			//trace(totalRadius, Math.cos(radAngle-centerRad));
			//fish eye correction for walls facing you
			totalRadius = totalRadius * Math.cos(centerRad - radAngle);
			var wallHeight: Number = Math.ceil(Model.RANGE_OF_SIGHT / totalRadius);

			//used for calculating darkening of wall
			var scale: Number = wallHeight / Model.windowH;
			if (scale < 0) {
				scale = 0;
			}

			//trace(totalIterations);		

			var wallHitNum: int = Model.roomArr[newRow][newCol];


			//trace("goingToRow", goingToRow , "newRow", newRow, "newCol", newCol, "newX", newX, "newY", newY, "textureX", textureX, "scale", scale, "radious ", totalRadius, "wallHeight", wallHeight, "radAngle", radAngle, "centerRad", centerRad, "cos", Math.cos(centerRad - radAngle));
			//
			var currLine: ColCont = currLines[i];
			currLine.x = newX;
			currLine.y = newY;
			currLine.r = totalRadius;
			currLine.radAngle = radAngle;
			currLine.wallScaleHeight = scale;
			currLine.wallHeight = wallHeight;
			currLine.textureX = textureX;
			currLine.wallHitNum = wallHitNum;

			return currLine;


		}


		function getSpriteHit(obj: Wall, rangeMin: Number, rangeMax: Number, totalViewRange: Number): void {
			if (obj != null && obj.seen == false) {

				var objAngle = (Math.atan2((obj.y + (obj.height / 2)) - bob.y, (obj.x + (obj.width / 2)) - bob.x)); //Utils.radRotationFromRad



				if (objAngle < 0) {
					objAngle += twoPi;
				}
				//this takes care of the edge case where the left angle is approaching 360 degrees and the object has passed
				//360 meaning it is seamingly smaller than the left angle
				if (rangeMin > objAngle && rangeMin > Math.PI && objAngle < Math.PI) {
					objAngle += twoPi;
				}

				if (rangeMax < objAngle && rangeMax < Math.PI && objAngle > Math.PI) {
					rangeMin += twoPi;
					rangeMax += twoPi;
				}

				//trace("objAngle", objAngle, "rangeMin", rangeMin, "rangeMax", rangeMax);

				if (objAngle > rangeMin && objAngle < rangeMax) {

					objsList.push(obj);
					obj.seen = true;
					//current object angle minus the left most angle to get a number within view range
					var r: Number = objAngle - rangeMin;

					//divide the angle by the total angles to get percentage
					var r1: Number = r / totalViewRange;
					//get screen column by multiplying number of rays
					obj.screenI = r1 * numRays;

					//trace("objAngle", objAngle, "rangeMin", rangeMin, "per", r);

					var x1: Number = Math.abs(obj.x - bob.x);
					var y1: Number = Math.abs(obj.y - bob.y);
					obj.radius = Math.sqrt(x1 * x1 + y1 * y1);
					obj.imgHeight = Math.ceil(Model.RANGE_OF_SIGHT / obj.radius);

					var scale: Number = obj.imgHeight / Model.windowH;
					if (scale < 0) {
						scale = 0;
					}
					obj.imgScaleHeight = scale;
				} else {
					//trace((objAngle > rangeMin), (objAngle < rangeMax));
				}
			}
		}


		function drawCol(endPoint: ColCont, drawStartCol: int, mousePer: Number): int {

			var wallHeight: Number = endPoint.wallHeight;
			//trace(wallH);
			var wallHitNum: int = endPoint.wallHitNum - 1;
			var wallBmd: BlitTexture = walls[wallHitNum];
			var wallY: int = (Model.windowH - wallHeight) / 2;

			wallY += Model.windowH * mousePer * endPoint.wallScaleHeight * 0.5;

			var colW: int = Model.colW;

			var perInTexture: Number = endPoint.textureX;
			var imgH: int = wallBmd.height;
			var imgW: int = wallBmd.width;

			var per: Number = (1 - (endPoint.wallScaleHeight) * 5);
			if (per > 1) {
				per = 1;
			} else if (per < 0) {
				per = 0;
			}


			var startColFromImg: int = imgW * perInTexture;
			var incrementXPer: Number = wallHeight / imgW;
			var incrementX: int = imgW * incrementXPer;

			for (var row: int = wallY; row <= wallHeight + wallY; row++) {
				for (var col: int = 0; col <= colW; col++) {
					var realCol: int = drawStartCol + col;
					if (row >= 0 && row <= Model.windowH && realCol >= 0 && realCol <= Model.windowW) {
						var yPerInWall: Number = (row - wallY) / wallHeight;
						var rowInImg: int = yPerInWall * imgH;
						var pixel: uint;

						if (TEXTURED_WALLS) {
							pixel = wallBmd.getPixel((startColFromImg + (col * incrementXPer)) / imgW, rowInImg / imgH);
							if (DARKEN_ENV) {

								if (per < 1) {
									pixel = ColorUtils.darken(pixel, per);
								}
							}

						} else {
							if (DARKEN_ENV) {
								pixel = ColorUtils.darken(0xffffff, (1 - (endPoint.wallScaleHeight)));
							}
							else
							{
								pixel = 0xffffff;
							}
							
						}
						bmd.setPixel(realCol, row, pixel);

					}


				}
			}


			return drawStartCol + colW;
		}


		/////////
		//old function
		function rayCastSlow(centerPoint: Point, radAngle: Number, centerRad: Number, i: int, rangeMin: Number, totalViewRange: Number): ColCont {

			radAngle = Utils.radRotationFromRad(radAngle);
			var dist: int = 0; // the distance to the block we hit
			var xHit: Number = 0; // the x and y coord of where the ray hit the block
			var yHit: Number = 0;
			var textureX: Number; // the x-coord on the texture of the block, ie. what part of the texture are we going to render		

			var angleSin: Number = Math.sin(radAngle);
			var angleCos: Number = Math.cos(radAngle);


			// moving right/left? up/down? Determined by which quadrant the angle is in.
			var right: Boolean = (radAngle > (twoPi) * 0.75 || radAngle < (twoPi) * 0.25);
			var up: Boolean = (radAngle < 0 || radAngle > Math.PI);

			//trace("right", right, "up", up, "radAngle", radAngle);

			var radious: Number = 0;
			var hitWall: Boolean = false;

			var endX: Number = centerPoint.x;
			var endY: Number = centerPoint.y;
			var tempX: Number = endX;
			var tempY: Number = endY;
			var wallHitNum: int = 0;
			var row: int;
			var col: int;

			while (!hitWall) {
				tempX = endX + (radious * angleCos);
				tempY = endY + (radious * angleSin);

				row = tempY / Model.TILE_SIZE;
				col = tempX / Model.TILE_SIZE;

				if (Model.roomArr[row] && Model.roomArr[row][col]) {
					if (Model.roomArr[row][col] > 0) {
						if (right) {
							tempX = endX + ((radious - 1) * angleCos);
							tempY = endY + ((radious - 1) * angleSin);
						}
						wallHitNum = Model.roomArr[row][col];
						hitWall = true;
						endX = tempX;
						endY = tempY;
					}
				} else {
					if (Model.roomArr[row] == undefined || Model.roomArr[row][col] == undefined) {
						hitWall = true;
						endX = tempX;
						endY = tempY;
					}
				}

				if (!hitWall) {


					//increment the "circle" radious, i.e. the distance in order to take a further step with our ray
					radious += Model.jumpFactor;
					totalIterations++;
				}
			}



			//the actual tile the ray hit
			var blockX: Number = col * Model.TILE_SIZE;
			var blockY: Number = row * Model.TILE_SIZE;

			//the distance on the wall itself from where the ray hit to the beginning of the tile
			var amountX: Number = Math.abs(endX - blockX);
			var amountY: Number = Math.abs(endY - blockY);

			//the percentage if the ray x,y of the tile size
			var perX: Number = amountX / Model.TILE_SIZE;
			var perY: Number = amountY / Model.TILE_SIZE;


			//if we hit a wall aligned with the x axis, our texture will be calculated along the y axis
			if (Math.ceil(endX) % Model.TILE_SIZE == 0) {
				textureX = perY;
				if (!right) textureX = 1 - textureX;
			} else {
				textureX = perX;
				if (!up) textureX = 1 - textureX;
			}

			//fish eye correction for walls facing you
			radious = radious * Math.cos(centerRad - radAngle);
			var wallHeight: Number = Math.ceil(Model.RANGE_OF_SIGHT / radious);

			//used for calculating darkening of wall
			var scale: Number = wallHeight / Model.windowH;
			if (scale < 0) {
				scale = 0;
			}


			//trace("textureX", textureX, "endX", endX, "endY", endY, "scale", scale, "radious ", radious, "wallHeight", wallHeight, "radAngle", radAngle, "centerRad", centerRad, "cos", Math.cos(centerRad - radAngle));
			var currLine: ColCont = currLines[i];
			currLine.x = endX;
			currLine.y = endY;
			currLine.r = radious;
			currLine.radAngle = radAngle;
			currLine.wallScaleHeight = scale;
			currLine.wallHeight = wallHeight;
			currLine.textureX = textureX;
			currLine.wallHitNum = wallHitNum;

			return currLine;


		}





	}

}