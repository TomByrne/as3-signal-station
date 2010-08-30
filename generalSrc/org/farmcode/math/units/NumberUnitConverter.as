package org.farmcode.math.units
{
	import org.farmcode.data.dataTypes.INumberProvider;
	
	public class NumberUnitConverter extends UnitConverter
	{
		/** Base for single digit numbers */
		public static const ONES:Number = 1;
		
		/** Base for tens */
		public static const TENS:Number = 10;
		
		/** Base for hundreds */
		public static const HUNDREDS:Number = 10*TENS;
		
		/** Base for thousands */
		public static const THOUSANDS:Number = 10*HUNDREDS;
		
		/** Base for millions */
		public static const MILLIONS:Number = 1000*THOUSANDS;
		
		/** Base for billions */
		public static const BILLIONS:Number = 1000*MILLIONS;
		
		/** Base for trillions */
		public static const TRILLIONS:Number = 1000*MILLIONS;
		
		/** Base for quadrillions */
		public static const QUADRILLIONS:Number = 1000*TRILLIONS;
		
		
		public function NumberUnitConverter(from:INumberProvider, fromType:Number, toType:Number, roundResult:Boolean=false)
		{
			super(from, fromType, toType, roundResult);
		}
	}
}