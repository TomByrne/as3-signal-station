package au.com.thefarmdigital.display
{
	public class RectangleDisplay extends View
	{
		private var _borderColour: uint;
		private var _borderAlpha: Number;
		private var _borderSize: Number;
		private var _colour: uint;
		private var _fillAlpha: Number;
		
		public function RectangleDisplay(x: Number = 0, y: Number = 0, width: Number = 0, 
			height: Number = 0, colour: uint = 0x000000, fillAlpha: Number = 1,
			borderSize: Number = 0, borderColour: uint = 0xffffff, borderAlpha: Number = 1)
		{
			super();
			
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.colour = colour;
			this.fillAlpha = fillAlpha;
			this.borderSize = borderSize;
			this.borderColour = borderColour;
			this.borderAlpha = borderAlpha;
		}
		
		public function set borderSize(value: Number): void
		{
			if (this.borderSize != value)
			{
				this._borderSize = value;
				this.invalidate();
			}
		}
		public function get borderSize(): Number
		{
			return this._borderSize;
		}
		
		public function set borderColour(value: uint): void
		{
			if (this.borderColour != value)
			{
				this._borderColour = value;
				this.invalidate();
			}
		}
		public function get borderColour(): uint
		{
			return this._borderColour;
		}
		
		public function set colour(value: uint): void
		{
			if (this.colour != value)
			{
				this._colour = value;
				this.invalidate();
			}
		}
		public function get colour(): uint
		{
			return this._colour;
		}
		
		public function set borderAlpha(value: Number): void
		{
			if (this.borderAlpha != value)
			{
				this._borderAlpha = value;
				this.invalidate();
			}
		}
		public function get borderAlpha(): Number
		{
			return this._borderAlpha;
		}
		
		public function set fillAlpha(value: Number): void
		{
			if (this.fillAlpha != value)
			{
				this._fillAlpha = value;
				this.invalidate();
			}
		}
		public function get fillAlpha(): Number
		{
			return this._fillAlpha;
		}
		
		override protected function draw(): void
		{
			this.graphics.clear();
			if (!isNaN(this.width) && !isNaN(this.height))
			{
				this.drawRect(0, 0, this.width, this.height, this.colour, this.fillAlpha);
				
				if (this.borderSize > 0)
				{
					this.drawRect(0, 0, this.width, this.borderSize, this.borderColour, 
						this.borderAlpha);
					this.drawRect(0, this.height - this.borderSize, this.width, this.borderSize, 
						this.borderColour, this.borderAlpha);
					this.drawRect(0, this.borderSize, this.borderSize, 
						this.height - (this.borderSize * 2), this.borderColour, this.borderAlpha);
					this.drawRect(this.width - this.borderSize, this.borderSize, this.borderSize, 
						this.height - (this.borderSize * 2), this.borderColour, this.borderAlpha);
				}
			}
		}
		
		protected function drawRect(x: Number, y: Number, width: Number, height: Number, 
			colour: Number, alpha: Number): void
		{
			this.graphics.beginFill(colour, alpha);
			this.graphics.drawRect(x, y, width, height);
			this.graphics.endFill();
		}
	}
}