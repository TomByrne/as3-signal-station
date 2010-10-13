package org.tbyrne.debug.data.core
{
	import org.tbyrne.data.core.NumberData;
	
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