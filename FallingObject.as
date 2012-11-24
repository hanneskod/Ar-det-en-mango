package {

	import flash.display.Sprite;
	import flash.display.Bitmap;

	public class FallingObject extends Sprite{
		
		public static const FRUIT:int = 10;
		public static const FRUTI_DI_MARE:int = 11;
		public static const POWER_UP:int = 12;

		public static const INVERT_LEFT_RIGHT:int = 14;
		public static const FAT_PLAYER:int = 15;
		public static const TALL_PLAYER:int = 16;
		public static const IMMORTAL_PLAYER:int = 17;
	
		public var type:int;
		public var value:int;

		public var image:Bitmap;
		
		public function FallingObject (img:Bitmap, type:int, value:int=1) {
			this.image = img;
			addChild(image);
			this.type = type;
			this.value = value;
		}
}

}