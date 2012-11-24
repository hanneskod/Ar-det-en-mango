package {

	import flash.display.SimpleButton;
	import flash.display.Shape;
	import flash.display.Sprite;

	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.Font;
	import flash.text.TextFieldAutoSize;

	public class MangoButton extends SimpleButton {

		private static const BUTTON_WIDTH:int = 130;
		private static const BUTTON_HEIGHT:int = 20;
		
		public function MangoButton (text:String) {
			this.upState = getButtonGraphics(0xDAA2D8, text);
			this.overState = getButtonGraphics(0xC983C7, text);
			this.downState = getButtonGraphics(0xCCCCCC, text);
			this.hitTestState = this.upState;
		}
		
		private function getButtonGraphics (color:uint, text:String):Sprite {
			var sprite:Sprite = new Sprite();
			sprite.graphics.lineStyle(2, 0x000000);
			sprite.graphics.beginFill(color);
			sprite.graphics.drawRoundRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT, 15);
			sprite.graphics.endFill();

			var buttonTextField:TextField = new TextField();
			buttonTextField.x = 0;
			buttonTextField.y = 1;
			buttonTextField.width = BUTTON_WIDTH;
			buttonTextField.textColor = 0xFFFFFF;
			buttonTextField.autoSize = TextFieldAutoSize.CENTER;
			buttonTextField.selectable = false;
			buttonTextField.text = text;

			buttonTextField.embedFonts = true;
			var format:TextFormat = new TextFormat();
			format.font = "sprite";
			format.size = 12;
			format.bold = true;
			buttonTextField.setTextFormat(format);

			sprite.addChild(buttonTextField);
			return sprite;
		}

	}

}