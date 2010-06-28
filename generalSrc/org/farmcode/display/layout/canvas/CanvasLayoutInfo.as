package org.farmcode.display.layout.canvas
{
	public class CanvasLayoutInfo implements ICanvasLayoutInfo
	{
		
		public function get top():Number{
			return _top;
		}
		public function set top(value:Number):void{
			_top = value;
		}
		public function get bottom():Number{
			return _bottom;
		}
		public function set bottom(value:Number):void{
			_bottom = value;
		}
		public function get middle():Number{
			return _middle;
		}
		public function set middle(value:Number):void{
			_middle = value;
		}
		public function get left():Number{
			return _left;
		}
		public function set left(value:Number):void{
			_left = value;
		}
		public function get right():Number{
			return _right;
		}
		public function set right(value:Number):void{
			_right = value;
		}
		public function get centre():Number{
			return _centre;
		}
		public function set centre(value:Number):void{
			_centre = value;
		}
		public function get width():Number{
			return _width;
		}
		public function set width(value:Number):void{
			_width = value;
		}
		public function get height():Number{
			return _height;
		}
		public function set height(value:Number):void{
			_height = value;
		}
		public function get percentWidth():Number{
			return _percentWidth;
		}
		public function set percentWidth(value:Number):void{
			_percentWidth = value;
		}
		public function get percentHeight():Number{
			return _percentHeight;
		}
		public function set percentHeight(value:Number):void{
			_percentHeight = value;
		}
		
		private var _top:Number;
		private var _bottom:Number;
		private var _middle:Number;
		private var _left:Number;
		private var _right:Number;
		private var _centre:Number;
		
		private var _width:Number;
		private var _height:Number;
		
		private var _percentWidth:Number;
		private var _percentHeight:Number;
		
		
		public function CanvasLayoutInfo(top:Number=NaN, left:Number=NaN, bottom:Number=NaN, right:Number=NaN){
			this.top = top;
			this.left = left;
			this.bottom = bottom;
			this.right = right;
		}
	}
}