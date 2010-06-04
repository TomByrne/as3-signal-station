package au.com.thefarmdigital.debug.infoSources
{
	import flash.system.System;
	
	import org.farmcode.math.UnitConversion;

	public class CurrentMemoryInfoSource extends AbstractNumericInfoSource
	{
		
		public function CurrentMemoryInfoSource(textUnit:Number=NaN, rounding:int=2, labelColour:Number=0xffffff){
			super(labelColour);
			this.textUnit = isNaN(textUnit)?UnitConversion.MEMORY_MEGABYTES:textUnit;
			this.rounding = rounding;
			_naturalUnit = UnitConversion.MEMORY_BYTES;
		}
		override public function get numericOutput() : Number{
			return System.totalMemory;
		}
		override public function get textOutput() : String{
			var amountStr:String = super.textOutput;
			switch(textUnit){
				case UnitConversion.MEMORY_MEGABYTES:
					return amountStr+" Mb";
				case UnitConversion.MEMORY_KILOBYTES:
					return amountStr+" Kb";
				case UnitConversion.MEMORY_BYTES:
					return amountStr+" B";
				case UnitConversion.MEMORY_GIGABYTES:
					return amountStr+" Gb";
				case UnitConversion.MEMORY_TERABYTES:
					return amountStr+" Tb";
				default:
					return amountStr;
			}
		}
	}
}