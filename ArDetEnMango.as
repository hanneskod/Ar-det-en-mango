package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.SimpleButton;
	import flash.display.Loader;
	import flash.display.Bitmap;
	
	import flash.geom.Rectangle;
	import flash.geom.Point;

	import flash.net.URLRequest;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;

	import flash.utils.Timer;
	
	import flash.ui.Keyboard;	

	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.Font;
	import flash.text.TextFieldAutoSize;
	
	import flash.media.Sound;
	
	import caurina.transitions.Tweener;
	
	import GraphicalProgressIndicator;
	import FallingObjectFactory;
	import FallingObject;
	import MangoButton;
	import MangoPlayer;
	import RandomArray;


	public class ArDetEnMango extends Sprite {
		//asset-loader
		private var loader:Loader;
		private var indicator:GraphicalProgressIndicator;
		//falling objects
		private var objectFactory:FallingObjectFactory;
		private var fallingObjects:Array = new Array();
		//oftast ramlar objekten ner ett i taget, men ibland kommer det en stor klump
		private var fallingObjTransitions:Array = ["linear", "linear", "linear", "easeInOutBounce"];
		//clouds
		private var clouds:RandomArray;
		//spelaren mm.
		private var player:MangoPlayer;
		private var isGameRunning:Boolean = false;
		private var counter:TextField;
		private var counterFormatBig:TextFormat;
		private var counterFormatSmall:TextFormat;
		private var points:int;
		private var backgroundImage:Bitmap;
		private var gameOverText:TextField;
		private var txtHeader:TextField;
		private var youGotText:TextField;
		private var infoText:TextField;
		private var infoTextHead:TextField;
		private var avHannesText:TextField;
		private var jumpTimer:Timer;
		private var beginButton:MangoButton;
		private var infoButton:MangoButton;
		private var returnButton:MangoButton;
		private var infoImages:Array;
		private var infoImagesPositions:Array;
		//extraliven
		private var extraLife:Array;
		private var extraLifeImage:Bitmap;
		//ljud
		private var Sound_ArDetEnMango:Sound;
		private var Sound_ArDetEnPapaya:Sound;
		private var Sound_Grat:Sound;
		private var Sound_Najj:Sound;
		private var Sound_Rov:Sound;
		private var Sound_VadEDettaNu:Sound;
		private var Sound_Woho:Sound;
		private var Sound_Tjoho:Sound;
		private var Sound_Ododlig:Sound;


		public function ArDetEnMango () {
			stage.align = StageAlign.TOP_RIGHT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 36;
			//rita ram
			var frame:Sprite = new Sprite();
			frame.graphics.lineStyle(10, 0xFFFFFF);
			frame.graphics.drawRoundRect(-1, -1, stage.stageWidth+2, stage.stageHeight+2, 25);
			frame.graphics.lineStyle(4, 0x9933CC);
			frame.graphics.drawRoundRect(2, 2, stage.stageWidth-4, stage.stageHeight-4, 25);
			this.addChild(frame);
			//ladda in bilder, fonter, ljud
			indicator = new GraphicalProgressIndicator();
			indicator.x = 100;
			indicator.y = 170;
			addChildAt(indicator, 0);
			loader = new Loader();
			loader.load(new URLRequest("ArDetEnMango_Assets.swf"));
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, indicator.progressListener);
			loader.contentLoaderInfo.addEventListener(Event.INIT, assetsLoadedListener);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, assetsCompleteListener);
			//tangentbordshändelser
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpListener);
		}
	
		
		/************** WELCOME-VIEW ****************/

		private function showWelcomeView ():void {
			//spela ljud
			this.Sound_ArDetEnPapaya.play();
			var tweenSettings:Object;
			//spelare
			this.player.reset();
			this.player.setState(MangoPlayer.STATE_RIGHT);
			//glid in
			tweenSettings = {x: 50,
							 time: 1,
							 delay: 0.3,
							 transition:"easeOutSine",
							 onComplete: this.setRandomPlayerState}
			Tweener.addTween(this.player, tweenSettings);
			//hoppa upp och ner
			this.jumpTimer = new Timer(1600, 0);
			this.jumpTimer.addEventListener(TimerEvent.TIMER, this.playerJump);
			this.jumpTimer.start();
			//studsa in knappar
			tweenSettings = {x: 60,
							 time: 1.6,
							 delay: 1,
							 transition:"easeOutBounce"}
			Tweener.addTween(this.beginButton, tweenSettings);
			tweenSettings = {x: 215,
							 time: 1.6,
							 delay: 2,
							 transition:"easeOutBounce"}
			Tweener.addTween(this.infoButton, tweenSettings);
			//dra in överskrift
			tweenSettings = {x: (stage.stageWidth/2) - (this.txtHeader.width/2) + 5,
							 time: 1,
							 delay: 0.3,
							 transition:"easeOutCirc"}
			Tweener.addTween(this.txtHeader, tweenSettings);
			//grattistexten
			if (this.points > 0) {
				this.setYouGotText("Grattis!\nDu fick "+this.points+" poäng.");
				tweenSettings = {y: 175,
								 time: 1.3,
								 delay: 0.7,
								 transition:"easeOutElastic"}
				Tweener.addTween(this.youGotText, tweenSettings);
			}
		}
		
		private function playerJump (event:TimerEvent):void {
			this.player.jump(180, 0.5);
		}
		
		private function setRandomPlayerState ():void {
			var states:Array = [MangoPlayer.STATE_NORMAL,
								MangoPlayer.STATE_NORMAL,
								MangoPlayer.STATE_FAT,
								MangoPlayer.STATE_SURPRISED];
			var stateNr:int = Math.floor(Math.random() * states.length);
			this.player.setState(states[stateNr]);
		}

		private function hideWelcomeView (onComplete:Object):void {
			var tweenSettings:Object;
			//sluta hoppa
			this.jumpTimer.stop();
			//knapparna glider undan
			tweenSettings = {x: stage.stageWidth + 10,
							 time: 1,
							 delay: 0.35,
							 transition: "easeInBack",
							 onComplete: onComplete}
			Tweener.addTween(this.beginButton, tweenSettings);
			tweenSettings = {x: stage.stageWidth + 10,
							 time: 1,
							 delay: 0.2,
							 transition: "easeInBack"}
			Tweener.addTween(this.infoButton, tweenSettings);
			//överskriften bort
			tweenSettings = {x: -400,
							 time: 0.6,
							 delay: 0.4,
							 transition: "easeInBack"}
			Tweener.addTween(this.txtHeader, tweenSettings);
			//grattistexten
			tweenSettings = {y: 600,
							 time: 1.1,
							 delay: 0.25,
							 transition: "easeInQuad"}
			Tweener.addTween(this.youGotText, tweenSettings);
		}
		
		private function gotoInfoView (event:MouseEvent):void {
			this.hideWelcomeView(this.showInfoView);
		}
		
		private function gotoGameView (event:MouseEvent):void {
			this.hideWelcomeView(this.startGame);
		}


		/************** GAME-VIEW ****************/

		private function startGame ():void {
			//spela ljud
			this.Sound_ArDetEnMango.play();
			this.player.slideToStartPos();
			this.isGameRunning = true;
			this.createExtraLifes();
			this.fallingObjectsLoop();
			this.points = 0;
			//för att uppdatera poängräknaren
			this.addPoints(0);
		}


		/************** INFO-VIEW ****************/

		private function showInfoView ():void {
			var tweenSettings:Object;
			this.player.slideOut();
			//studsa in tillbakaknapp
			tweenSettings = {x: 250,
							 time: 1.6,
							 delay: 2.4,
							 transition:"easeOutBounce"}
			Tweener.addTween(this.returnButton, tweenSettings);
			//scrolla ner texten
			tweenSettings = {y: 20,
							 time: 1.6,
							 delay: 0.1,
							 transition:"easeOutQuad"}
			Tweener.addTween(this.infoText, tweenSettings);
			tweenSettings = {y: 20,
							 time: 0.5,
							 delay: 1.5,
							 transition:"easeOutBounce"}
			Tweener.addTween(this.infoTextHead, tweenSettings);
			//bilderna
			for (var i:int=0; i<11; i++){
				tweenSettings = {x: this.infoImagesPositions[i][0],
								 time: 1+0.1*1,
								 delay: 1.5+0.1*i,
								 transition:"easeOutBounce"}
				Tweener.addTween(this.infoImages[i], tweenSettings);			
			}
			//avHannes
			tweenSettings = {y: 483,
							 time: 0.4,
							 delay: 0.4,
							 transition:"easeOutBounce"}
			Tweener.addTween(this.avHannesText, tweenSettings);
		}

		private function hideInfoView (event:MouseEvent):void {
			var tweenSettings:Object;
			//glid undan tillbakaknapp
			tweenSettings = {x: stage.stageWidth + 10,
							 time: 1,
							 delay: 0.35,
							 transition: "easeInBack",
							 onComplete: this.showWelcomeView}
			Tweener.addTween(this.returnButton, tweenSettings);
			//texten
			tweenSettings = {y: -500,
							 time: 1.6,
							 delay: 0.1,
							 transition:"easeInQuad"}
			Tweener.addTween(this.infoText, tweenSettings);
			tweenSettings = {y: -20,
							 time: 0.3,
							 delay: 0.1,
							 transition:"easeInQuad"}
			Tweener.addTween(this.infoTextHead, tweenSettings);
			//bilderna
			for (var i:int=0; i<11; i++){
				tweenSettings = {x: stage.stageWidth + 10,
								 time: 0.7,
								 delay: 0.1*i,
								 transition:"easeInBack"}
				Tweener.addTween(this.infoImages[i], tweenSettings);
			}
			//avHannes
			tweenSettings = {y: 500,
							 time: 0.4,
							 delay: 0.1,
							 transition:"easeInBack"}
			Tweener.addTween(this.avHannesText, tweenSettings);
		}


		/************** GAME-OVER-VIEW ****************/

		private function showGameOverView ():void {
			this.toggleGameOverText();
		}

		private function toggleGameOverText (textIn:Boolean = true):void {
			var tweenSettings:Object;
			if (textIn) {
				//visa texten
				tweenSettings = {y: stage.stageHeight/2 - this.gameOverText.height*4,
								 time: 2,
								 delay: 2,
								 transition: "easeOutBounce",
								 onComplete: toggleGameOverText,
								 onCompleteParams:[false]}
				Tweener.addTween(this.gameOverText, tweenSettings);
			} else {
				//ta bort texten
				tweenSettings = {y: stage.stageHeight + 20,
								 time: 1,
								 delay: 3.5,
								 transition: "easeInCubic",
								 onComplete: this.showWelcomeView}
				Tweener.addTween(this.gameOverText, tweenSettings);
			}
		}


		/************** POÄNG ****************/
		
		private function addPoints (nrOfPoints:int = 1):void {
			if (!this.player.isDead()) {
				this.points += nrOfPoints;
				var pointsStr:String = String(this.points);
				this.counter.text = "poäng: " + pointsStr;
				this.counter.setTextFormat(this.counterFormatSmall, 0, 7);
				this.counter.setTextFormat(this.counterFormatBig, 7, 7+pointsStr.length);
			}
		}


		/************** FALLING-OBJECTS ****************/
		
		private function addFallingObject ():void {
			var newObj:FallingObject = objectFactory.getObject();
			newObj.y = 0;
			newObj.x = Math.floor(Math.random() * (stage.stageWidth-newObj.image.width));
			this.addChildAt(newObj, 1);
			var tweenSettings:Object = {x: newObj.x,
										y: stage.stageHeight,
										time: 4,
										transition: "easeInExpo",
										onComplete: this.removeFallingObject,
										onCompleteParams: [newObj],
										onUpdate: this.fallingObjectUpdate,
										onUpdateParams: [newObj]}
			Tweener.addTween(newObj, tweenSettings);
		}
		
		private function removeFallingObject (obj:FallingObject):void {
			this.removeChild(obj);
			obj = null;
		}
		
		private function fallingObjectUpdate (obj:FallingObject):void {
			if (!this.player.isDead()) {
				var playerBounds:Rectangle = player.getBounds(this);
				//gör spelarens område lite mindre än bilden
				playerBounds.x += 5;
				playerBounds.width -= 10;
				playerBounds.y += 10;
				playerBounds.height -= 10;
				var objBounds:Rectangle = obj.getBounds(this);
				//kolla om fallingObj krockar med spelaren
				if (objBounds.intersects(playerBounds)) {
					//kolla vilken sort fallingObj är, och ställ in player efter det
					if (obj.type == FallingObject.FRUIT) {
						this.player.celebrate();
						this.addPoints(obj.value);
						if (obj.value == 5) {
							this.Sound_ArDetEnPapaya.play();
						} else {
							//slumpa om det ska spelas ett ljud
							//var randnr:int = Math.floor(Math.random() * 3);
							//if (randnr==1) {
								var soundnr:int = Math.floor(Math.random() * 2);
								if (soundnr==1){
									this.Sound_Tjoho.play();
								}else{
									this.Sound_Woho.play();
								}
							//}
						}
					} else if (obj.type == FallingObject.FRUTI_DI_MARE) {
						if (this.player.getImageState() == MangoPlayer.STATE_GLOW) {
							//odödlig får poäng för fruti di mare
							this.player.celebrate();
							this.addPoints(1);
							//och spela ett ljud..
							soundnr = Math.floor(Math.random() * 2);
							if (soundnr==1){
								this.Sound_Tjoho.play();
							}else{
								this.Sound_Woho.play();
							}
						} else {
							//inte glödande = död
							this.Sound_Grat.play();
							this.removeExtraLife();
						}
					} else if (obj.type == FallingObject.POWER_UP) {
						if (obj.value == FallingObject.TALL_PLAYER) {
							if (player.setPowerUp(MangoPlayer.STATE_TALL)) {
								this.Sound_Najj.play();
							}
						} else if (obj.value == FallingObject.FAT_PLAYER) {
							if (player.setPowerUp(MangoPlayer.STATE_FAT)) {
								this.Sound_Rov.play();
							}
						} else if (obj.value == FallingObject.INVERT_LEFT_RIGHT) {
							if (player.setPowerUp(MangoPlayer.STATE_SURPRISED)) {
								this.Sound_VadEDettaNu.play();
							}
						} else if (obj.value == FallingObject.IMMORTAL_PLAYER) {
							if (player.setPowerUp(MangoPlayer.STATE_GLOW)) {
								this.player.celebrate();
								this.Sound_Ododlig.play();
							}
						}
					}
					//ta bort fallingObj
					Tweener.removeTweens(obj);
					removeFallingObject(obj);
				}
			}
		}

		private function fallingObjectsLoop (nrOfObjects:int = 4):void {
			if (this.isGameRunning) {
				//kör sig själv och sätter ut fler och fler objekt
				var transNr:int = Math.floor(Math.random() * this.fallingObjTransitions.length);
				var tweenSettings:Object = {time: 5,
											count: nrOfObjects,
											transition: this.fallingObjTransitions[transNr],
											onUpdate: this.addFallingObject,
											onComplete: this.fallingObjectsLoop,
											onCompleteParams: [nrOfObjects + 1]}
				Tweener.addCaller(this, tweenSettings);
			}
		}


		/************** DÖ ELLER TA BORT EXTRALIV ****************/

		private function removeExtraLife ():void {
			if (this.extraLife.length > 0) {
				var tweenSettings:Object = {y: stage.stageHeight + this.extraLife[0].height,
											time: 1.3,
											delay: 2.5,
											transition: "easeInQuad",
											onComplete: this.continueGame}
				Tweener.addTween(this.extraLife[this.extraLife.length-1], tweenSettings);
				this.isGameRunning = false;
				this.player.die();
				//stoppa objekts loopen
				Tweener.removeTweens(this);
				//starta moln-loopen igen - FULHACK!
				this.cloudLoop();
			} else {
				//game over
				this.showGameOverView();
				this.player.die();
				this.isGameRunning = false;
			}
		}
		
		private function continueGame ():void {
			//ta bort livet helt
			this.extraLife.length -= 1;
			//starta om gubben
			this.player.reset();
			this.player.slideToStartPos();
			//starta om objekts-loopen
			this.isGameRunning = true;
			this.fallingObjectsLoop();
		}


		/************** CLOUDS ****************/

		private function cloudLoop ():void {
			//kör sig själv och sätter ut fler och fler objekt
			var tweenSettings:Object = {time: 40,
										count: 1,
										transition: "linear",
										onUpdate: this.addCloud,
										onComplete: this.cloudLoop}
			Tweener.addCaller(this, tweenSettings);
		}

		private function addCloud ():void {
			var cloud:Bitmap = new Bitmap(Bitmap(this.clouds.getRandom()).bitmapData);
			cloud.scaleX = cloud.scaleY = (Math.floor(Math.random() * 4) + 6) / 10;
			cloud.smoothing = true;
			var direction:int = Math.floor(Math.random() * 2);
			var targetX:int;
			if (direction == 0) {
				cloud.x = 0 - cloud.width;
				targetX = stage.stageWidth + cloud.width;
			} else {
				cloud.x = stage.stageWidth + cloud.width;
				targetX = 0 - cloud.width;
			}
			cloud.y = Math.floor(Math.random() * 150);
			var time:int = Math.floor(Math.random() * 35) + 45;
			//placera molnet just under ramen
			this.addChildAt(cloud, this.numChildren-2);
			var tweenSettings:Object = {x: targetX,
										time: time,
										transition: "linear",
										onComplete: this.removeCloud,
										onCompleteParams: [cloud]}
			Tweener.addTween(cloud, tweenSettings);
		}
		
		private function removeCloud (obj:Bitmap):void {
			this.removeChild(obj);
			obj = null;
		}

		
		/************** USER-INPUT-LISTENERS ****************/

		public function keyDownListener (event:KeyboardEvent):void {
			if (this.isGameRunning) {
				if (event.keyCode == Keyboard.RIGHT) {
					this.player.startMove(MangoPlayer.STATE_RIGHT);
				}else if (event.keyCode == Keyboard.LEFT) {
					this.player.startMove(MangoPlayer.STATE_LEFT);
				}else if (event.keyCode == Keyboard.UP) {
					this.player.jump();
				}else if (event.keyCode == Keyboard.DOWN) {
					this.player.duck();
				}
			}
		}
		
		public function keyUpListener (event:KeyboardEvent):void {
			if (this.isGameRunning) {
				if (event.keyCode == Keyboard.RIGHT) {
					this.player.stopMove(MangoPlayer.STATE_RIGHT);
				}else if (event.keyCode == Keyboard.LEFT) {
					this.player.stopMove(MangoPlayer.STATE_LEFT);
				}else if (event.keyCode == Keyboard.DOWN) {
					this.player.stand();
				}
			}
		}


		/************** ASSET-LOAD-LISTENERS ****************/
		
		public function assetsLoadedListener (event:Event):void {
			//registrera fonter
			Font.registerFont(event.target.content.sprite);
			Font.registerFont(event.target.content.arial);
			//skapa object
			this.createCounter();
			this.extraLifeImage = new event.target.content.Head();
			this.createTxtHeader();		//rubriken
			this.createYouGotText();	//visas efter avklarat spel
			this.createGameOverText();
			this.createInfoText();
			this.createAvHannesText();
			this.beginButton = createButton("Starta spelet", stage.stageWidth+10, 120, this.gotoGameView);
			this.addChildAt(this.beginButton, 0);
			this.infoButton = createButton("Information", stage.stageWidth+10, 120, this.gotoInfoView);
			this.addChildAt(this.infoButton, 0);
			this.returnButton = createButton("Tillbaka", stage.stageWidth+10, 448, this.hideInfoView);
			this.addChildAt(this.returnButton, 0);
			//ladda bilder till info-view
			this.createInfoImages (new event.target.content.Cherry(),
								   new event.target.content.Melon(),
								   new event.target.content.Lemon(),
								   new event.target.content.Papaya(),
								   new event.target.content.Cod(),
								   new event.target.content.Crab(),
								   new event.target.content.Shrimp(),
								   new event.target.content.Sanna(),
								   new event.target.content.LeMarc(),
								   new event.target.content.Escobar(),
								   new event.target.content.NilsPetter());
			//sätt bakgrunden
			this.backgroundImage = new event.target.content.Background();
			this.addChildAt(this.backgroundImage, 0);
			//ladda bilder - falling objects
			this.objectFactory = new FallingObjectFactory(new event.target.content.Cherry(),
									 					  new event.target.content.Melon(),
									 					  new event.target.content.Lemon(),
														  new event.target.content.Papaya(),
									 					  new event.target.content.Cod(),
														  new event.target.content.Crab(),
														  new event.target.content.Shrimp(),
														  new event.target.content.Sanna(),
														  new event.target.content.LeMarc(),
														  new event.target.content.Escobar(),
														  new event.target.content.NilsPetter());
			//clouds
			this.clouds = new RandomArray();
			this.clouds.add(new event.target.content.Cloud1(), 1);
			this.clouds.add(new event.target.content.Cloud2(), 1);
			this.clouds.add(new event.target.content.Cloud3(), 1);
			//ett första moln på en gång
			this.addCloud();
			//starta loopen, molnen finns alltid
			this.cloudLoop();
			//lägg till spelare
			var startPosX:int = stage.stageWidth/2-30;
			var resetPosX:int = -100;
			var startPosY:int = stage.stageHeight-145;
			this.player = new MangoPlayer(startPosX,
										  resetPosX,
										  startPosY,
										  new event.target.content.Flicka(),
								   		  new event.target.content.FlickaLeft(),
							 	   		  new event.target.content.FlickaRight(),
							  	   		  new event.target.content.FlickaHappy(),
							  	  		  new event.target.content.FlickaShort(),
							  	 		  new event.target.content.FlickaDead(),
							  	 		  new event.target.content.FlickaLong(),
							  	 		  new event.target.content.FlickaFat(),
							  	 		  new event.target.content.FlickaSurprised(),
							  	 		  new event.target.content.FlickaGlow());
			this.addChildAt(this.player, 1);
			//ladda ljud
			Sound_ArDetEnMango = new event.target.content.Sound_ArDetEnMango() as Sound;
			Sound_ArDetEnPapaya = new event.target.content.Sound_ArDetEnPapaya() as Sound;
			Sound_Grat = new event.target.content.Sound_Grat() as Sound;
			Sound_Najj = new event.target.content.Sound_Najj() as Sound;
			Sound_Rov = new event.target.content.Sound_Rov() as Sound;
			Sound_VadEDettaNu = new event.target.content.Sound_VadEDettaNu() as Sound;
			Sound_Woho = new event.target.content.Sound_Woho() as Sound;
			Sound_Tjoho = new event.target.content.Sound_Tjoho() as Sound;
			Sound_Ododlig = new event.target.content.Sound_Ododlig() as Sound;
			//alla assets är inladdade, frigör minne
			loader = null;
			//börja spelet			
			showWelcomeView();
		}

		public function assetsCompleteListener (event:Event):void {
			removeChild(indicator);
			indicator = null;
		}


		/************** CREATING OBJECTS ****************/

		private function createCounter ():void {
			this.counterFormatBig = new TextFormat();
			this.counterFormatBig.font = "sprite";
			this.counterFormatBig.size = 14;
			this.counterFormatBig.bold = true;
			this.counterFormatSmall = new TextFormat();
			this.counterFormatSmall.font = "sprite";
			this.counterFormatSmall.size = 10;
			this.counterFormatSmall.bold = false;
			this.counter = new TextField();
			this.counter.embedFonts = true;
			this.counter.textColor = 0xFFFFFF;
			this.counter.selectable = false;
			this.counter.background = true;
			this.counter.backgroundColor = 0x9933CC;
			this.counter.text = "Poäng: 0";
			this.counter.width = 90;
			this.counter.height = 20;
			this.counter.x = stage.stageWidth - counter.width;
			this.counter.y = 3;
			this.counter.autoSize = TextFieldAutoSize.LEFT;
			this.counter.setTextFormat(this.counterFormatSmall, 0, 7);
			this.counter.setTextFormat(this.counterFormatBig, 7);
			this.addChildAt(this.counter, 1);
		}
		
		private function createTxtHeader ():void {
			var format:TextFormat = new TextFormat();
			format.font = "sprite";
			format.size = 24;
			format.bold = true;
			this.txtHeader = new TextField();
			this.txtHeader.embedFonts = true;
			this.txtHeader.textColor = 0x000000;
			this.txtHeader.selectable = false;
			this.txtHeader.text = "Är det en mango?";
			this.txtHeader.autoSize = TextFieldAutoSize.CENTER;
			this.txtHeader.setTextFormat(format);
			this.txtHeader.x = -400;
			this.txtHeader.y = 70;
			this.addChildAt(this.txtHeader, 0);
		}
		
		private function createYouGotText ():void {
			var format:TextFormat = new TextFormat();
			format.size = 13;
			format.font = "arial";
			format.bold = false;
			this.youGotText = new TextField();
			this.youGotText.embedFonts = true;
			this.youGotText.textColor = 0x000000;
			this.youGotText.selectable = false;
			this.youGotText.text = "Grattis!\nDu fick 100 poäng.";
			this.youGotText.autoSize = TextFieldAutoSize.CENTER;
			this.youGotText.setTextFormat(format);
			this.youGotText.x = 225;
			this.youGotText.y = 600;
			this.addChildAt(this.youGotText, 0);
		}

		private function setYouGotText(txt:String):void {
			var format:TextFormat = new TextFormat();
			format.size = 13;
			format.font = "arial";
			format.bold = false;
			this.youGotText.embedFonts = true;
			this.youGotText.text = txt;
			this.youGotText.autoSize = TextFieldAutoSize.CENTER;
			this.youGotText.setTextFormat(format);
		}
		
		private function createAvHannesText():void {
			var format:TextFormat = new TextFormat();
			format.size = 11;
			format.font = "arial";
			format.bold = false;
			this.avHannesText = new TextField();
			this.avHannesText.embedFonts = true;
			this.avHannesText.text = "programmering: hannes forsgård";
			this.avHannesText.autoSize = TextFieldAutoSize.CENTER;
			this.avHannesText.setTextFormat(format);
			this.avHannesText.x = 13;
			this.avHannesText.y = 500;
			this.addChildAt(this.avHannesText, 0);
		}
		
		private function createGameOverText ():void {
			var format:TextFormat = new TextFormat();
			format.font = "sprite";
			format.size = 22;
			format.bold = true;
			this.gameOverText = new TextField();
			this.gameOverText.embedFonts = true;
			this.gameOverText.textColor = 0xFFFFFF;
			this.gameOverText.selectable = false;
			this.gameOverText.text = "GAME OVER";
			this.gameOverText.width = 90;
			this.gameOverText.height = 40;
			this.gameOverText.x = (stage.stageWidth/2) - (this.gameOverText.width/2) + 5;
			this.gameOverText.y = stage.stageHeight + 20;
			this.gameOverText.autoSize = TextFieldAutoSize.CENTER;
			this.gameOverText.setTextFormat(format);
			this.addChildAt(this.gameOverText, 0);
		}

		private function createInfoText ():void {
			var headFormat:TextFormat = new TextFormat();
			headFormat.font = "sprite";
			headFormat.size = 11;
			headFormat.bold = false;
			this.infoTextHead = new TextField();
			this.infoTextHead.embedFonts = true;
			this.infoTextHead.selectable = false;
			this.infoTextHead.text = "Är det en mango?";
			this.infoTextHead.autoSize = TextFieldAutoSize.CENTER;
			this.infoTextHead.setTextFormat(headFormat);
			this.infoTextHead.x = 12;
			this.infoTextHead.y = -20;	//20 när den visas
			this.addChildAt(this.infoTextHead, 0);

			var format:TextFormat = new TextFormat();
			format.size = 11.5;
			format.font = "arial";
			format.bold = false;
			this.infoText = new TextField();
			this.infoText.embedFonts = true;
			//this.infoText.textColor = 0x000000;
			this.infoText.selectable = false;
			this.infoText.text = "                                        Nej, det är en papaya! Samla poäng genom \natt fånga papayor och andra frukter och bär som faller ner från himlen.\n\n\n\n\n\n\nMen passa dig för havets frukter. Dom vill dig illa!\n\n\n\n\n\n\nDet är ungefär allt du behöver veta. Men se upp, det är inte bara \nfrukter, fiskar och skaldjur som regnar ner över dig.\n\n\n\n\n\n\n\nSanna Nilsen får dig att växa på längden. Peter LeMarc \ndäremot gör dig tjock och långsam. Och det har du ju \ninte så mycket glädje av. Eskobar försätter dig i ett \nförvirrat tillstånd. Är du emo, eller är du helt enkel bara \nför gammal? Allt blir upp och ner, höger blir vänster och \ntvärt om. Nils Petter Sundgren gör dig odödlig \n(ungefär lika länge som Antonio Books karriär kommer vara).";
			this.infoText.autoSize = TextFieldAutoSize.CENTER;
			this.infoText.setTextFormat(format);
			this.infoText.x = 12;
			this.infoText.y = -500;		//20 när den visas
			this.addChildAt(this.infoText, 0);
		}

		private function createButton (text:String, x:int, y:int, listener:Function):MangoButton {
			var button:MangoButton = new MangoButton(text);
			button.x = x;
			button.y = y;
			button.addEventListener(MouseEvent.CLICK, listener);
			return button;
		}
		
		private function createInfoImages (cherry:Bitmap, melon:Bitmap, lemon:Bitmap, papaya:Bitmap, cod:Bitmap, crab:Bitmap, shrimp:Bitmap, sanna:Bitmap, leMarc:Bitmap, escobar:Bitmap, nilsPetter:Bitmap):void {
			this.infoImages = new Array(cherry, melon, lemon, papaya, cod, crab, shrimp, sanna, leMarc, escobar, nilsPetter);
			//positionerna bilderna ska ha när de visas
			this.infoImagesPositions = new Array();
			infoImagesPositions.push(new Array(45,54));
			infoImagesPositions.push(new Array(112,72));
			infoImagesPositions.push(new Array(206,62));
			infoImagesPositions.push(new Array(286,53));
			infoImagesPositions.push(new Array(70, 172));
			infoImagesPositions.push(new Array(165,148));
			infoImagesPositions.push(new Array(260, 165));
			infoImagesPositions.push(new Array(35,260));
			infoImagesPositions.push(new Array(105,270));
			infoImagesPositions.push(new Array(180,280));
			infoImagesPositions.push(new Array(290,260));
			//placera bilderna utanför skärmen
			for (var i:int=0; i<11; i++) {
				this.infoImages[i].x = 500;
				this.infoImages[i].y = infoImagesPositions[i][1];
				this.addChildAt(this.infoImages[i], 0);
			}
		}
		
		private function createExtraLifes ():void {
			this.extraLife = new Array(new Bitmap(this.extraLifeImage.bitmapData),
									   new Bitmap(this.extraLifeImage.bitmapData));
			this.extraLife[0].x = 10;
			this.extraLife[0].y = -50;
			this.extraLife[1].x = 45;
			this.extraLife[1].y = -50;
			this.addChildAt(this.extraLife[0], this.numChildren-2);
			this.addChildAt(this.extraLife[1], this.numChildren-2);
			var tweenSettings:Object;
			tweenSettings = {y: 7,
							 time: 1,
							 transition: "easeOutBounce"}
			Tweener.addTween(this.extraLife[0], tweenSettings);
			Tweener.addTween(this.extraLife[1], tweenSettings);
		}
		
	}
}