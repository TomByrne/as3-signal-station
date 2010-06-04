package au.com.thefarmdigital.debug.infoSources
{
	import flash.utils.getTimer;
	
	import org.farmcode.math.UnitConversion;

	public class TimePerFrameInfoSource extends CurrentFrameInfoSource
	{
		private var lastFrame:int;
		private var lastFrameDuration:int;
		
		public function TimePerFrameInfoSource(textUnit:Number=NaN, rounding:int=3, labelColour:Number=0xffffff, resetOnDisable:Boolean=false){
			super(labelColour, resetOnDisable);
			_naturalUnit = UnitConversion.TIME_MILLISECONDS;
		}
		
		override protected function onFrame():void{
			var time:int = getTimer();
			lastFrameDuration = time-lastFrame;
			lastFrame = time;
			dispatchInfoChange();
		}
		override public function get numericOutput():Number{
			return lastFrameDuration;
		}
		override public function get textOutput() : String{
			var amountStr:String = super.textOutput;
			switch(textUnit){
				case UnitConversion.TIME_MILLISECONDS:
					return amountStr+" MS";
				case UnitConversion.TIME_SECONDS:
					return amountStr+" S";
				default:
					return amountStr;
			}
		}
	}
}