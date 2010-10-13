package org.tbyrne.math.units
{
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class MemoryUnitConverter extends UnitConverter
	{
		/** A single bit */
		public static const BITS:Number = 1;
		
		/** Number of bits in a byte */
		public static const BYTES:Number = 8;
		
		/** Number of bits in a byte */
		public static const KILOBITS:Number = 128*BYTES;
		
		/** Number of bits in a kilobyte */
		public static const KILOBYTES:Number = 1024*BYTES;
		
		/** Number of bits in a megabyte */
		public static const MEGABYTES:Number = 1024*KILOBYTES;
		
		/** Number of bits in a gigabyte */
		public static const GIGABYTES:Number = 1024*MEGABYTES;
		
		/** Number of bits in a terabyte */
		public static const TERABYTES:Number = 1024*GIGABYTES;
		
		public static const STANDARD_UNITS:Array = [TERABYTES,GIGABYTES,MEGABYTES,KILOBYTES,BYTES];
		
		// Some units commented out for ease of use.
		/*public static const PETABYTES:Number = 1024*TERABYTES;
		public static const EXABYTES:Number = 1024*PETABYTES;
		public static const ZETTABYTES:Number = 1024*EXABYTES;
		public static const YOTTABYTES:Number = 1024*ZETTABYTES;*/
		
		/**
		 * Breaks down a number of bytes into terabytes, gigabytes, megabytes
		 * & bytes.
		 */
		public static function standardMemoryBreakdown(from:Number):Array
		{
			return UnitConverter.breakdown(from,BYTES,STANDARD_UNITS);
		}
		
		
		
		public function MemoryUnitConverter(from:INumberProvider, fromType:Number, toType:Number, roundResult:Boolean=false)
		{
			super(from, fromType, toType, roundResult);
		}
	}
}