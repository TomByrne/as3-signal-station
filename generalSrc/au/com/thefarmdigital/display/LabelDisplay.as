package au.com.thefarmdigital.display
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class LabelDisplay extends View
	{
		protected var _bgColour: Number;
		private var _field: TextField;
		protected var _text: String;
		protected var _selectable: Boolean;
		
		public function LabelDisplay(x: Number = 0, y: Number = 0, width: Number = 0, 
			height: Number = 0, text: String = "", bgColour: Number = NaN)
		{
			super();
			
			this.selectable = false;
			
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.bgColour = bgColour;
			this.text = text;
		}
		
		override protected function initialise() : void
		{
			this._field = new TextField();
			this.field.multiline = true;
			this.field.wordWrap = true;
			this.addChild(this.field);
		}
		
		public function get field(): TextField
		{
			this.ensureInitialised();
			return this._field;
		}
		
		// TODO: Not working
		public function expandToChars(numChars: uint): void
		{
			this.ensureInitialised();
			
			var sizeText: String = "";
			for (var i: uint = 0; i < numChars; i++)
			{
				sizeText += "W";
			}
			
			var oldAuto: String = this.field.autoSize;
			var oldMultiline: Boolean = this.field.multiline;
			
			this.field.multiline = false;
			this.field.autoSize = TextFieldAutoSize.LEFT;
			this.field.text = sizeText;
			
			this.width = this.field.width;
			this.height = this.field.height;
			
			this.field.autoSize = oldAuto;
			this.field.multiline = oldMultiline;
			
			this.validate(true);
		}
		
		public function set selectable(selectable: Boolean): void
		{
			if (this._selectable != selectable)
			{
				this._selectable = selectable;
				this.invalidate();
			}
		}
		public function get selectable(): Boolean
		{
			return this._selectable;
		}
		
		public function set text(text: String): void
		{
			if (this._text != text)
			{
				this._text = text;
				this.invalidate();
			}
		}
		public function get text(): String
		{
			return this._text;
		}
		
		public function set bgColour(bgColour: Number): void
		{
			if (bgColour != this._bgColour)
			{
				this._bgColour = bgColour;
				this.invalidate();
			}
		}
		public function get bgColour(): Number
		{
			return this._bgColour;
		}
		
		override protected function draw():void
		{
			this.field.width = this.width;
			this.field.height = this.height;
			if (isNaN(this.bgColour))
			{
				this.field.background = false;
			}
			else
			{
				this.field.background = true;
				this.field.backgroundColor = this._bgColour;
			}
			this.field.text = this._text;
			this.field.selectable = this._selectable;
		}
	}
}