package org.tbyrne.display.layout.core
{
	public class MarginLayoutInfo implements ILayoutInfo
	{
		
		public function get marginTop():Number{
			return _marginTop;
		}
		public function set marginTop(value:Number):void{
			_marginTop = value;
		}
		
		public function get marginLeft():Number{
			return _marginLeft;
		}
		public function set marginLeft(value:Number):void{
			_marginLeft = value;
		}
		
		public function get marginRight():Number{
			return _marginRight;
		}
		public function set marginRight(value:Number):void{
			_marginRight = value;
		}
		
		public function get marginBottom():Number{
			return _marginBottom;
		}
		public function set marginBottom(value:Number):void{
			_marginBottom = value;
		}
		
		private var _marginBottom:Number;
		private var _marginRight:Number;
		private var _marginLeft:Number;
		private var _marginTop:Number;
		
	}
}