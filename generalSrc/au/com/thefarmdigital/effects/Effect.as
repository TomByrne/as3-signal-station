package au.com.thefarmdigital.effects
{
	import au.com.thefarmdigital.transitions.ITransition;
	import au.com.thefarmdigital.transitions.TransitionTiming;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	public class Effect implements ITransition, IEffect
	{
		
		public function set amount(value:Number):void{
			if(_amount!=value){
				_amount = value;
			}
		}
		public function get amount():Number{
			return _amount;
		}
		public function set subject(value:DisplayObject):void{
			if(_subject!=value){
				_subject = value;
			}
		}
		public function get subject():DisplayObject{
			return _subject;
		}
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
		
		private var _duration:Number = 1000;
		private var _amount:Number = 0;
		private var _subject:DisplayObject;
		private var _timing:String = TransitionTiming.CONCURRENT;
		
		public function render():void{
			// override me
		}
		public function remove():void{
			// override me
		}
		
		// ITransition implementation
		public function beginTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number):void{
		}
		
		public function doTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number, currentTime:Number):void{
			if(subject != bitmap)subject = bitmap;
			amount = Math.min(currentTime,duration-currentTime)/(duration/2);
			render();
		}
		
		public function endTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number):void{
			subject = bitmap;
			remove();
		}
	}
}