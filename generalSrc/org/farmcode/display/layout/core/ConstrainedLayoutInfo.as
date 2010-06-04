package org.farmcode.display.layout.core
{
	public class ConstrainedLayoutInfo implements IConstrainedLayoutInfo
	{
		public function get minWidth():Number{
			return _minWidth;
		}
		public function set minWidth(value:Number):void{
			_minWidth = value;
		}
		
		public function get minHeight():Number{
			return _minHeight;
		}
		public function set minHeight(value:Number):void{
			_minHeight = value;
		}
		
		public function get maxWidth():Number{
			return _maxWidth;
		}
		public function set maxWidth(value:Number):void{
			_maxWidth = value;
		}
		
		public function get maxHeight():Number{
			return _maxHeight;
		}
		public function set maxHeight(value:Number):void{
			_maxHeight = value;
		}
		
		private var _maxHeight:Number;
		private var _maxWidth:Number;
		private var _minHeight:Number;
		private var _minWidth:Number;
		
		public function ConstrainedLayoutInfo()
		{
		}
	}
}