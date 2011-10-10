package org.tbyrne.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.display2D.IRectangleTrait;
	import org.tbyrne.core.EnterFrameHook;
	
	public class DisplayObjectBounds extends AbstractTrait implements IRectangleTrait
	{
		
		/**
		 * @inheritDoc
		 */
		public function get rectangleChanged():IAct{
			return (_rectangleChanged || (_rectangleChanged = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get size2dChanged():IAct{
			return (_size2dChanged || (_size2dChanged = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get position2dChanged():IAct{
			return (_position2dChanged || (_position2dChanged = new Act()));
		}
		
		protected var _position2dChanged:Act;
		protected var _size2dChanged:Act;
		protected var _rectangleChanged:Act;
		
		
		
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
				if(_position2dChanged)_position2dChanged.perform(this);
			}
			if(_width!=width || _height!=height){
				_width = width;
				_height = height;
				change = true;
				if(_size2dChanged)_size2dChanged.perform(this);
			}
			if(change && _rectangleChanged)_rectangleChanged.perform(this);
		}
	}
}