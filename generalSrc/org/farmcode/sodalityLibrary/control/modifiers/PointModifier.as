package org.farmcode.sodalityLibrary.control.modifiers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;

	public class PointModifier extends EventDispatcher implements IValueModifier
	{
		public function get xModifier():INumberModifier{
			return _xModifier;
		}
		public function set xModifier(value:INumberModifier):void{
			if(value!=_xModifier){
				if(_xModifier){
					_xModifier.removeEventListener(Event.CHANGE, bubbleEvent);
				}
				_xModifier = value;
				if(_xModifier && !_xModifier.hasEventListener(Event.CHANGE)){
					_xModifier.addEventListener(Event.CHANGE, bubbleEvent);
				}
				
			}
		}
		public function get yModifier():INumberModifier{
			return _yModifier;
		}
		public function set yModifier(value:INumberModifier):void{
			if(value!=_yModifier){
				if(_yModifier){
					_yModifier.removeEventListener(Event.CHANGE, bubbleEvent);
				}
				_yModifier = value;
				if(_yModifier && !_yModifier.hasEventListener(Event.CHANGE)){
					_yModifier.addEventListener(Event.CHANGE, bubbleEvent);
				}
				
			}
		}
		
		private var _xModifier:INumberModifier;
		private var _yModifier:INumberModifier;
		
		public function PointModifier(xModifier:INumberModifier=null, yModifier:INumberModifier=null){
			this.xModifier = xModifier;
			this.yModifier = yModifier;
		}

		public function input(value:*, oldValue:*):*{
			var point:Point = value as Point;
			var oldPoint:Point = oldValue as Point;
			if(!point)point = new Point();
			if(xModifier)point.x = xModifier.inputNumber(point.x,oldPoint.x);
			if(yModifier)point.y = yModifier.inputNumber(point.y,oldPoint.y);
			return point;
		}
		protected function bubbleEvent(e:Event):void{
			dispatchEvent(e);
		}
	}
}