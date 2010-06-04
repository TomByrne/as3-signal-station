package au.com.thefarmdigital.debug.infoSources
{
	import flash.utils.getTimer;
	
	import org.farmcode.math.UnitConversion;

	public class TimeSinceInfoSource extends CurrentFrameInfoSource
	{
		public var sinceTime:int;
		
		public function TimeSinceInfoSource(labelColour:Number=0xffffff, sinceTime:int=0){
			super(labelColour);
			this.sinceTime = sinceTime;
			_naturalUnit = UnitConversion.TIME_MILLISECONDS;
		}
		override public function get numericOutput() : Number{
			return Math.max(getTimer()-sinceTime,0);
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