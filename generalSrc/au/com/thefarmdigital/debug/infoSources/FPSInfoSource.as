package au.com.thefarmdigital.debug.infoSources
{
	import flash.utils.getTimer;

	public class FPSInfoSource extends CurrentFrameInfoSource
	{
		override public function set enabled(value:Boolean):void{
			super.enabled = value;
			if(!super.enabled && resetOnDisable){
				frameRecords = [];
			}
		}
		override public function get numericOutput():Number{
			if(rateInvalid){
				var time:int = getTimer();
				while(time-(frameRecords[frameRecords.length-1])>1000){
					frameRecords.pop();
				}
				_framerate = frameRecords.length;			
			}
			return _framerate;
		}
		
		private var frameRecords:Array = [];
		private var rateInvalid:Boolean;
		private var _framerate:Number;
		
		public function FPSInfoSource(labelColour:Number=0xffffff, resetOnDisable:Boolean=false){
			super(labelColour, resetOnDisable);
		}
		override protected function onFrame():void{
			frameRecords.unshift(getTimer());
			rateInvalid = true;
			dispatchInfoChange();
		}
	}
}