package org.tbyrne.geom.rect
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.tbyrne.core.EnterFrameHook;
	
	public class DisplayObjectBounds extends AbstractRectangleData
	{
		
		
		public function get displayObject():DisplayObject{
			return _displayObject;
		}
		public function set displayObject(value:DisplayObject):void{
			if(_displayObject!=value){
				_displayObject = value;
				if(_displayObject){
					EnterFrameHook.getAct().addHandler(checkBounds);
				}else{
					EnterFrameHook.getAct().removeHandler(checkBounds);
				}
				checkBounds();
			}
		}
		
		public function get relativeTo():DisplayObject{
			return _relativeTo;
		}
		public function set relativeTo(value:DisplayObject):void{
			if(_relativeTo!=value){
				_relativeTo = value;
			}
		}
		
		private var _relativeTo:DisplayObject;
		
		private var _displayObject:DisplayObject;
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		
		public function DisplayObjectBounds(displayObject:DisplayObject=null, relativeTo:DisplayObject=null){
			super();
			this.displayObject = displayObject;
			this.relativeTo = relativeTo;
		}
		
		public function get x():Number{
			return _x;
		}
		public function get y():Number{
			return _y;
		}
		public function get width():Number{
			return _width;
		}
		public function get height():Number{
			return _height;
		}
		
		
		private function checkBounds():void{
			var x:Number;
			var y:Number;
			var width:Number;
			var height:Number;
			
			if(_displayObject){
				var bounds:Rectangle = _displayObject.getBounds(_relativeTo?_relativeTo:_displayObject.stage);
				x = bounds.x;
				y = bounds.y;
				width = bounds.width;
				height = bounds.height;
			}else{
				x = 0;
				y = 0;
				width = 0;
				height = 0;
			}
			var change:Boolean;
			if(_x!=x || _y!=y){
				_x = x;
				_y = y;
				change = true;
			}
			if(_width!=width || _height!=height){
				_width = width;
				_height = height;
				change = true;
			}
			if(change && _rectangleChanged)_rectangleChanged.perform(this);
		}
	}
}