package org.tbyrne.actInfo
{
	
	public class MouseActInfo implements IMouseActInfo
	{
		public function get mouseTarget():*{
			return _mouseTarget;
		}
		public function set mouseTarget(value:*):void{
			_mouseTarget = value;
		}
		
		public function get altKey():Boolean{
			return _altKey;
		}
		public function set altKey(value:Boolean):void{
			_altKey = value;
		}
		
		public function get ctrlKey():Boolean{
			return _ctrlKey;
		}
		public function set ctrlKey(value:Boolean):void{
			_ctrlKey = value;
		}
		
		public function get shiftKey():Boolean{
			return _shiftKey;
		}
		public function set shiftKey(value:Boolean):void{
			_shiftKey = value;
		}
		
		public function get screenX():Number{
			return _screenX;
		}
		public function set screenX(value:Number):void{
			_screenX = value;
		}
		
		public function get screenY():Number{
			return _screenY;
		}
		public function set screenY(value:Number):void{
			_screenY = value;
		}
		
		private var _screenY:Number;
		private var _screenX:Number;
		private var _shiftKey:Boolean;
		private var _ctrlKey:Boolean;
		private var _altKey:Boolean;
		private var _mouseTarget:*;
		
		public function MouseActInfo(mouseTarget:*, altKey:Boolean, ctrlKey:Boolean, shiftKey:Boolean, screenX:Number, screenY:Number){
			this.mouseTarget = mouseTarget;
			this.altKey = altKey;
			this.ctrlKey = ctrlKey;
			this.shiftKey = shiftKey;
			this.screenX = screenX;
			this.screenY = screenY;
		}
	}
}