package org.tbyrne.display.transition
{
	import org.tbyrne.display.assets.nativeTypes.IBitmap;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	public class Transition implements ITransition
	{
		public function set timing(value:String):void{
			if(_timing!=value){
				_timing = value;
			}
		}
		public function get timing():String{
			return _timing;
		}
		public function set duration(value:Number):void{
			if(_duration!=value){
				_duration = value;
			}
		}
		public function get duration():Number{
			return _duration;
		}
		
		private var _timing:String = TransitionTiming.CONCURRENT;
		private var _duration:Number = 1000;
		
		public function beginTransition(start:IDisplayObject, finish:IDisplayObject, bitmap:IBitmap, duration:Number):void{
		}
		
		public function doTransition(start:IDisplayObject, finish:IDisplayObject, bitmap:IBitmap, duration:Number, currentTime:Number):void{
		}
		
		public function endTransition(start:IDisplayObject, finish:IDisplayObject, bitmap:IBitmap, duration:Number):void{
		}
		
	}
}