package org.farmcode.debug.data.core
{
	import org.farmcode.data.core.NumberData;
	
	public class HexNumberData extends NumberData
	{
		public function HexNumberData(numericalValue:Number=NaN)
		{
			super(numericalValue);
		}
		override protected function numToString(number:Number):String{
			return number.toString(16);
		}
	}
}