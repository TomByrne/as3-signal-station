package org.farmcode.display.transition
{
	import org.farmcode.display.assets.IBitmapAsset;
	import org.farmcode.display.assets.IDisplayAsset;

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
		
		public function beginTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void{
		}
		
		public function doTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number, currentTime:Number):void{
		}
		
		public function endTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void{
		}
		
	}
}