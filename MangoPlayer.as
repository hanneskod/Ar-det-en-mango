package {

	import flash.display.Sprite;
	import flash.display.Bitmap;
	
	import flash.geom.Point;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import caurina.transitions.Tweener;


	public class MangoPlayer extends Sprite {
		//konstanter
		public static const POS_NOT_SET:int = -1;
		public static const STATE_NORMAL:int = 0;
		public static const STATE_LEFT:int = 1;
		public static const STATE_RIGHT:int = 2;
		public static const STATE_HAPPY:int = 3;
		public static const STATE_SHORT:int = 4;
		public static const STATE_DEAD:int = 5;
		public static const STATE_TALL:int = 6;
		public static const STATE_FAT:int = 7;
		public static const STATE_SURPRISED:int = 8;
		public static const STATE_GLOW:int = 9;
		//spelarens aktuella status
		private var state:int;
		//den bild av spelaren som visas
		private var imageOnDisplay:int;
		private var images:Array;
		//den angivna startpositionen
		private var startY:int = POS_NOT_SET;
		private var startX:int = POS_NOT_SET;
		private var resetX:int = POS_NOT_SET;
		//planet spelaren arbetar på just nu
		private var activeY:int = POS_NOT_SET;
		//planet en lång spelare arbetar på
		private var tallPlayerActiveY:int = POS_NOT_SET;
		//flaggor
		private var imageLocked:Boolean;
		private var dead:Boolean;
		private var invertedLeftRight:Boolean;
		private var moveSlow:Boolean;
		private var moveEnabled:Boolean;
		//hastighet
		private var velX:int;
		//multi purpose timer
		private var timer:Timer;

		//konstruktor
		public function MangoPlayer (startPosX:int,
									 resetPosX:int,
									 startPosY:int,
									 imgNorm:Bitmap,
									 imgLeft:Bitmap,
									 imgRight:Bitmap,
									 imgHappy:Bitmap,
									 imgShort:Bitmap,
									 imgDead:Bitmap,
									 imgTall:Bitmap,
									 imgFat:Bitmap,
									 imgSurp:Bitmap,
									 imgGlow:Bitmap) {			
			//ladda in bilder
			this.images=[imgNorm,imgLeft,imgRight,imgHappy,imgShort,imgDead,imgTall,imgFat,imgSurp,imgGlow];
			this.addChild(imgNorm);
			//sätt startpositioner
			this.startX = startPosX;
			this.resetX = resetPosX;
			this.startY = startPosY;
			this.tallPlayerActiveY = startPosY - 45;
			//sätt övriga värden
			this.reset();
		}

		//återställ alla värden för nytt spel
		public function reset ():void {
			this.unlockImage();
			this.setState(STATE_NORMAL);
			this.resetPosition();
			this.dead = false;
			this.invertedLeftRight = false;
			this.moveSlow = false;
			this.moveEnabled = true;
		}


		/************* STATE *************/
		
		public function setState (state:int):void {
			//ändra alltid state
			this.state = state;
			//ändra bara bild om den inte är låst
			if (!this.imageLocked) this.setImage(state);
		}
		
		private function setImage (imgNr:int):void {
			if (imgNr != this.imageOnDisplay) {
				//ändra bild, bara om den behöver bytas
				this.imageOnDisplay = imgNr;
				this.removeChildAt(0);
				this.addChild(images[imgNr]);
			}
		}
		
		private function updateImage ():void {
			if (this.imageOnDisplay != this.state) this.setImage(this.state);
		}
		
		public function getState ():int {
			return this.state;
		}
		
		public function lockImage ():void {
			this.imageLocked = true;
		}
		
		public function unlockImage ():void {
			this.imageLocked = false;
		}

		public function getImageState ():int {
			return this.imageOnDisplay;
		}

		/************* POSITION *************/
		
		public function getStartPosition ():Point {
			return new Point(this.startX, this.startY);
		}

		public function setPosition (x:int, y:int):void {
			this.x = x;
			this.y = y;
		}

		public function resetPosition ():void {
			this.x = this.resetX;
			this.y = this.startY;
			this.activeY = this.startY;
		}

		public function slideToStartPos ():void {
			//startMove får inte stoppa sliden
			this.moveEnabled = false;
			//spalaren glider till höger
			this.setState(STATE_RIGHT);
			var tweenSettings:Object = {x: this.startX,
							 			time: 0.8,
							 			delay: 0.2,
							 			transition: "easeOutQuad",
							 			onComplete: this.allowNewMove}
			Tweener.addTween(this, tweenSettings);
		}
		
		public function slideOut ():void {
			this.setState(STATE_LEFT);
			var tweenSettings:Object = {x: -70,
							 			time: 0.8,
							 			delay: 0.2,
							 			transition: "easeOutQuad"}
			Tweener.addTween(this, tweenSettings);
		}


		/************* RÖRELSE *************/

		public function startMove (state:int):void {
			//ingen rörelse när spelaren är död
			if (this.dead) return;
			//ingen ny rörelse om det redan finna en X-rörelse
			if (!this.moveEnabled) return;
			else this.moveEnabled = false;
			//ändra vänster till höger om det är inverterat
			if (this.invertedLeftRight) state = this.invert(state);
			this.setState(state);
			//starta rörelsen
			this.continuousMove(state);			
		}
								
		private function continuousMove (state:int, velX:int=-1):void {
			//använd standardhastighet om inget skickats med
			if (velX != -1) this.velX = velX;
			else this.velX = 3;
			//öka hastighet succsesivt
			if (this.velX < 20) this.velX += 2;
			//långsammare rörelse om spelare är fet
			if (this.moveSlow) {
				if (this.velX > 7) this.velX = 7;
			}
			//rörelsens delmål
			var targetX:int;
			if (state == STATE_RIGHT) targetX = this. x + this.velX;
			if (state == STATE_LEFT) targetX = this. x - this.velX;
			//rörelsens mål för inte vara utanför scenen
			if (outOfBounds(targetX)) return;
			//starta rörelsen
			var tweenSettings:Object = {x: targetX,
										time: 0.06,
										transition: "linear",
										onComplete: this.continuousMove,
										onCompleteParams: [state, this.velX]}
			Tweener.addTween(this, tweenSettings);
		}
		
		public function stopMove (state:int):void {
			//inverterad rörelse
			if (this.invertedLeftRight) state = this.invert(state);
			//stoppa bara om rätt knapp släppts upp
			if (this.state == state) {
				this.moveEnabled = true;
				//studsa tillbaka lite snyggt
				//att skapa en ny tween avbryter dessutom den rörelse som redan ligger
				var targetX:int;
				if (state == STATE_LEFT) targetX = this.x - this.velX;
				if (state == STATE_RIGHT) targetX = this.x + this.velX;
				var tweenSettings:Object = {x: targetX,
											time: 0.3,
											transition: "easeOutBack",
											onComplete: this.setState,
											onCompleteParams: [STATE_NORMAL]}
				Tweener.addTween(this, tweenSettings);
			}
		}
				
		private function outOfBounds (x:int):Boolean {
			//studsa tillbaka om spelaren är utanför scenen
			var state:int = -1;
			if (x < 0) state = STATE_RIGHT;
			if (x > stage.stageWidth-this.width) state = STATE_LEFT;
			//returnera false om x är på scenen
			if (state == -1) return false;
			//studsa tillbaka
			this.setState(state);
			var targetX:int;
			if (state == STATE_LEFT) targetX = this.x - this.velX;
			if (state == STATE_RIGHT) targetX = this.x + this.velX;
			var tweenSettings:Object = {x: targetX,
										time: 0.3,
										transition: "easeOutBack",
										onComplete: this.allowNewMove}
			Tweener.addTween(this, tweenSettings);
			return true;
		}

		private function allowNewMove ():void {
			this.setState(STATE_NORMAL);
			this.moveEnabled = true;
		}

		private function invert (currentState:int):int {
			var newState:int;
			if (currentState == STATE_LEFT) newState = STATE_RIGHT;
			else if (currentState == STATE_RIGHT) newState = STATE_LEFT;
			return newState;
		}

		private function stopAllMoves ():void {
			Tweener.removeTweens(this);
		}
		
		private function stopXMove ():void {
			if (this.state == STATE_LEFT || this.state == STATE_RIGHT) {
				var invState:int;
				if (this.invertedLeftRight) invState = this.invert(this.state);
				else invState = this.state;
				this.stopMove(invState);
			}
		}


		/************* POWER UP *************/

		public function setPowerUp (powerUp:int):Boolean {
			if (!this.imageLocked) {
				this.setImage(powerUp);
				this.lockImage();
				if (powerUp == STATE_TALL) {
					this.y = this.tallPlayerActiveY;
					this.activeY = this.tallPlayerActiveY;
				} else if (powerUp == STATE_SURPRISED) {
					this.invertedLeftRight = true;
					//avsluta X-rörelse, annars kan det bli kaka
					this.stopXMove();
				} else if (powerUp == STATE_FAT) {
					this.moveSlow = true;
				}
				this.timer = new Timer(8408, 1);
				this.timer.addEventListener(TimerEvent.TIMER, removePowerUp);
				this.timer.start();
				//power-up sattes
				return true;
			} else {
				//ingen ny power-up
				return false;
			}
		}
		
		private function removePowerUp (event:TimerEvent):void {
			if (this.invertedLeftRight) {
				this.invertedLeftRight = false;
				this.stopXMove();
			}
			this.moveSlow = false;
			this.unlockImage();
			this.updateImage();
			this.activeY = this.startY;
			this.y = this.activeY;
		}

		/************* HOPPA OCH VAR GLAD *************/

		public function jump (height:int = 20, time:Number = 0.2, up:Boolean = true):void {
			if (!this.dead) {
				var tweenSettings:Object;
				if (up) {
					var tweens:Array = Tweener.getTweens(this);
					for (var i:int=0; i<tweens.length; i++) {
						if (tweens[i] == "y") {
							//hoppa bara om det inte redan finns en tween på y-axeln
							return;
						}
					}
					//hoppa upp
					tweenSettings = {y: this.activeY - height,
									 time: time,
									 transition: "easeOutCubic",
									 onComplete: this.jump,
									 onCompleteParams:[height, time, false]}
					Tweener.addTween(this, tweenSettings);
				} else {
					//falla ner
					tweenSettings = {y: this.activeY,
									 time: time,
									 transition:"easeOutBounce"}
					Tweener.addTween(this, tweenSettings);
				}
			}
		}

		public function celebrate ():void {
			if (this.state == STATE_NORMAL)	this.setState(STATE_HAPPY);
			this.jump();
		}


		/************* DUCKA OCH RESA SIG *************/
		
		public function duck ():void {
			this.setState(STATE_SHORT);
		}
		
		public function stand ():void {
			if (this.state == STATE_SHORT) this.setState(STATE_NORMAL);
		}


		/************* DÖ *************/

		public function die ():void {
			this.stopAllMoves();
			this.unlockImage();
			this.setState(STATE_DEAD);
			this.dead = true;
			var tweenSettings:Object 
			tweenSettings = {y: stage.stageHeight + 110,
							 time: 1.5,
							 delay: 0.5,
							 transition: "easeInCirc"}
			Tweener.addTween(this, tweenSettings);
			if (this.timer != null) this.timer.stop();
		}
		
		public function undie ():void {
			this.dead = false;
		}
		
		public function isDead ():Boolean {
			return this.dead;
		}
		
	}

}