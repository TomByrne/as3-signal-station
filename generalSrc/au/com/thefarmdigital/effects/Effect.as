package au.com.thefarmdigital.effects
{
	import org.farmcode.display.assets.IBitmapAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.transition.ITransition;
	import org.farmcode.display.transition.TransitionTiming;

	public class Effect implements ITransition, IEffect
	{
		
		public function set amount(value:Number):void{
			_amount = value;
		}
		public function get amount():Number{
			return _amount;
		}
		public function set subject(value:IDisplayAsset):void{
			_subject = value;
		}
		public function get subject():IDisplayAsset{
			return _subject;
		}
		public function set timing(value:String):void{
			_timing = value;
		}
		public function get timing():String{
			return _timing;
		}
		public function set duration(value:Number):void{
			_duration = value;
		}
		public function get duration():Number{
			return _duration;
		}
		
		private var _duration:Number = 1000;
		private var _amount:Number = 0;
		private var _subject:IDisplayAsset;
		private var _timing:String = TransitionTiming.CONCURRENT;
		
		public function render():void{
			// override me
		}
		public function remove():void{
			// override me
		}
		
		// ITransition implementation
		public function beginTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void{
		}
		
		public function doTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number, currentTime:Number):void{
			if(subject != bitmap)subject = bitmap;
			amount = Math.min(currentTime,duration-currentTime)/(duration/2);
			render();
		}
		
		public function endTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void{
			subject = bitmap;
			remove();
		}
	}
}