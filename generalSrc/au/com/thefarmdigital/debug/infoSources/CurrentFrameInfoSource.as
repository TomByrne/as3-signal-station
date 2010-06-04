package au.com.thefarmdigital.debug.infoSources
{
	
	import flash.events.Event;
	
	import org.farmcode.core.DelayedCall;

	public class CurrentFrameInfoSource extends AbstractNumericInfoSource
	{
		
		public var resetOnDisable:Boolean = false;
		
		override public function set enabled(value:Boolean):void{
			super.enabled = value;
			if(super.enabled){
				_delayedCall.begin();
			}else{
				_delayedCall.clear();
				if(resetOnDisable)_frameCount = 0;
			}
		}
		
		private var _delayedCall:DelayedCall = new DelayedCall(onFrame,1,false,null,0);
		private var _frameCount:int = 0;
		
		public function CurrentFrameInfoSource(labelColour:Number=0xffffff, resetOnDisable:Boolean=false){
			super(labelColour);
			_delayedCall.begin();
		}
		protected function onFrame():void{
			_frameCount++;
			dispatchInfoChange();
		}
		override public function get numericOutput():Number{
			return _frameCount;
		}
	}
}