package org.farmcode.sodalityPlatformEngine.control.focusController
{
	import flash.geom.Point;

	public class FocusOffsetPoint implements IFocusOffsetItem
	{
		
		[Property(toString="true",clonable="true")]
		public function get focusX():Number{
			return _focusX;
		}
		public function set focusX(value:Number):void{
			//if(_focusX != value){
				_focusX = value;
			//}
		}
		
		[Property(toString="true",clonable="true")]
		public function get focusY():Number{
			return _focusY;
		}
		public function set focusY(value:Number):void{
			//if(_focusY != value){
				_focusY = value;
			//}
		}
		
		[Property(toString="true",clonable="true")]
		public function get focusRatio():Number{
			return _focusRatio;
		}
		public function set focusRatio(value:Number):void{
			//if(_focusRatio != value){
				_focusRatio = value<0?0:value>1?1:value;
			//}
		}
		
		[Property(toString="true",clonable="true")]
		public function get relative():Boolean{
			return _relative;
		}
		public function set relative(value:Boolean):void{
			//if(_relative != value){
				_relative = value;
			//}
		}
		
		private var _focusX:Number;
		private var _focusY:Number;
		private var _focusRatio:Number = 1;
		private var _relative:Boolean;
		
		public function FocusOffsetPoint(focusX:Number=NaN, focusY:Number=NaN, focusRatio:Number=1, relative:Boolean=false){
			this.focusX = focusX;
			this.focusRatio = focusRatio;
			this.relative = relative;
		}
		
	}
}