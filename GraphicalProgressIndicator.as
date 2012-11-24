package {
	
	import flash.display.Sprite;
	import flash.display.Shape;

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	import flash.events.ProgressEvent;
	
	public class GraphicalProgressIndicator extends Sprite {
		public var percentDone:int;
		private var canvas:Shape;
		private var text:TextField;

		public function GraphicalProgressIndicator () {
			canvas = new Shape();
			canvas.graphics.lineStyle(2, 0x000000);
			canvas.graphics.drawRect(0, 0, 200, 15);
			canvas.y = 18;
			canvas.x = 2;
			addChild(canvas);
			text  = new TextField();
		 	text.textColor = 0x000000;
		 	text.autoSize = TextFieldAutoSize.LEFT; 
		 	text.selectable = false; 
		 	//text.text = "LADDAR..."; 
			text.text = "";
			addChild(text);
		}
		
		public function progressListener (event:ProgressEvent):void {
			percentDone = Math.floor((event.bytesLoaded/event.bytesTotal) * 100);
			update();
		}

		public function update ():void {
			canvas.graphics.beginFill(0x000000, 1);
			canvas.graphics.drawRect(0, 0, percentDone*2, 15);
			canvas.graphics.endFill();
		}

	}
}