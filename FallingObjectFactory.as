package {

	import flash.display.Bitmap;
	import FallingObject;
	import RandomArray;


	public class FallingObjectFactory {

		private var fruits:RandomArray = new RandomArray();
		private var frutiDiMares:RandomArray = new RandomArray();
		private var powerUps:RandomArray = new RandomArray();
		private var functionsArray:RandomArray = new RandomArray();
		
		public function FallingObjectFactory (imgCherry:Bitmap,
								    		  imgMelon:Bitmap,
								    		  imgLemon:Bitmap,
								    		  imgPapaya:Bitmap,
								    		  imgCod:Bitmap,
								    		  imgCrab:Bitmap,
								    		  imgShrimp:Bitmap,
								    		  imgSanna:Bitmap,
								    		  imgLeMarc:Bitmap,
								    		  imgEscobar:Bitmap,
								    		  imgMalin:Bitmap) {
			this.fruits.add(new Array(imgCherry, 1), 5);
			this.fruits.add(new Array(imgMelon, 1), 5);
			this.fruits.add(new Array(imgLemon, 1), 5);
			this.fruits.add(new Array(imgPapaya, 5), 2);
			this.frutiDiMares.add(imgCod, 1);
			this.frutiDiMares.add(imgCrab, 1);
			this.frutiDiMares.add(imgShrimp, 1);
			this.powerUps.add(new Array(imgSanna, FallingObject.TALL_PLAYER), 1);
			this.powerUps.add(new Array(imgLeMarc, FallingObject.FAT_PLAYER), 1);
			this.powerUps.add(new Array(imgEscobar, FallingObject.INVERT_LEFT_RIGHT), 1);
			this.powerUps.add(new Array(imgMalin, FallingObject.IMMORTAL_PLAYER), 1);
			this.functionsArray.add(this.getFruit, 4);
			this.functionsArray.add(this.getFrutiDiMare, 3);
			this.functionsArray.add(this.getPowerUp, 1);
		}
		
		public function getObject ():FallingObject {
			return this.functionsArray.getRandom()();
		}
		
		private function getFruit ():FallingObject {
			var fruit:Array = this.fruits.getRandom() as Array;
			return new FallingObject(new Bitmap(fruit[0].bitmapData), FallingObject.FRUIT, fruit[1]);
		}
		
		private function getFrutiDiMare ():FallingObject {
			var img:Bitmap = Bitmap(this.frutiDiMares.getRandom());
			return new FallingObject(new Bitmap(img.bitmapData), FallingObject.FRUTI_DI_MARE);
		}
		
		private function getPowerUp ():FallingObject {
			var powerUp:Array = this.powerUps.getRandom() as Array;
			return new FallingObject(new Bitmap(powerUp[0].bitmapData), FallingObject.POWER_UP, powerUp[1]);
		}	

	}
}