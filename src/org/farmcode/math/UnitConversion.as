package org.farmcode.math
{
	/**
	 * A collection of constants and functions used for dealing with units of 
	 * measurement
	 */
	public class UnitConversion
	{
		///////////////////////////////////////////////////////////////////////////
		// MEMORY UNITS
		///////////////////////////////////////////////////////////////////////////
		/** A single bit */
		public static const MEMORY_BITS:Number = 1;
		
		/** Number of bits in a byte */
		public static const MEMORY_BYTES:Number = 8;
		
		/** Number of bits in a byte */
		public static const MEMORY_KILOBITS:Number = 128*MEMORY_BYTES;
		
		/** Number of bits in a kilobyte */
		public static const MEMORY_KILOBYTES:Number = 1024*MEMORY_BYTES;
		
		/** Number of bits in a megabyte */
		public static const MEMORY_MEGABYTES:Number = 1024*MEMORY_KILOBYTES;
		
		/** Number of bits in a gigabyte */
		public static const MEMORY_GIGABYTES:Number = 1024*MEMORY_MEGABYTES;
		
		/** Number of bits in a terabyte */
		public static const MEMORY_TERABYTES:Number = 1024*MEMORY_GIGABYTES;
		
		// Some units commented out for ease of use. Uncomment if required and 
		// commit to SVN
		/*public static const MEMORY_PETABYTES:Number = 1024*MEMORY_TERABYTES;
		public static const MEMORY_EXABYTES:Number = 1024*MEMORY_PETABYTES;
		public static const MEMORY_ZETTABYTES:Number = 1024*MEMORY_EXABYTES;
		public static const MEMORY_YOTTABYTES:Number = 1024*MEMORY_ZETTABYTES;*/
		
		///////////////////////////////////////////////////////////////////////////
		// TIME UNITS
		///////////////////////////////////////////////////////////////////////////
		/** A single millisecond */
		public static const TIME_MILLISECONDS:Number = 1;
		
		/** Number of milliseconds in a second */
		public static const TIME_SECONDS:Number = 1000;
		
		/** Number of milliseconds in a minute */
		public static const TIME_MINUTES:Number = 60*TIME_SECONDS;
		
		/** Number of milliseconds in an hour */
		public static const TIME_HOURS:Number = 60*TIME_MINUTES;
		
		/** Number of milliseconds in a day */
		public static const TIME_DAYS:Number = 24*TIME_HOURS;
		
		/** Number of milliseconds in a week */
		public static const TIME_WEEKS:Number = 24*TIME_DAYS;
		
		/** Number of milliseconds in a fortnight */
		public static const TIME_FORTNIGHTS:Number = 2*TIME_WEEKS;
		
		/** Number of milliseconds in a 365 day year */
		public static const TIME_YEARS:Number = 365*TIME_DAYS;
		
		/** Number of milliseconds in an average month in a 365 day year */
		public static const TIME_MONTHS:Number = TIME_YEARS / 12;
		
		///////////////////////////////////////////////////////////////////////////
		// Number bases
		///////////////////////////////////////////////////////////////////////////
		/** Base for single digit numbers */
		public static const NUMBER_ONES:Number = 1;
		
		/** Base for tens */
		public static const NUMBER_TENS:Number = 10;
		
		/** Base for hundreds */
		public static const NUMBER_HUNDREDS:Number = 10*NUMBER_TENS;
		
		/** Base for thousands */
		public static const NUMBER_THOUSANDS:Number = 10*NUMBER_HUNDREDS;
		
		/** Base for millions */
		public static const NUMBER_MILLIONS:Number = 1000*NUMBER_THOUSANDS;
		
		/** Base for billions */
		public static const NUMBER_BILLIONS:Number = 1000*NUMBER_MILLIONS;
		
		/** Base for trillions */
		public static const NUMBER_TRILLIONS:Number = 1000*NUMBER_MILLIONS;
		
		/** Base for quadrillions */
		public static const NUMBER_QUADRILLIONS:Number = 1000*NUMBER_TRILLIONS;
		
		///////////////////////////////////////////////////////////////////////////
		// DISTANCE UNITS
		///////////////////////////////////////////////////////////////////////////
		/** One Millimeter */
		public static const DISTANCE_MILLIMETER:Number = 1;
		
		/** Millimeters in a centimeter */
		public static const DISTANCE_CENTIMETER:Number = 10;
		
		/** Millimeters in a meter */
		public static const DISTANCE_METER:Number = 100*DISTANCE_CENTIMETER;
		
		/** Millimeters in a meter */
		public static const DISTANCE_KILOMETER:Number = 1000*DISTANCE_METER;
		
		/** Millimeters in an inch */
		public static const DISTANCE_INCH:Number = 25.4;
		
		/** Millimeters in a foot */
		public static const DISTANCE_FEET:Number = 12*DISTANCE_INCH;
		
		/** Millimeters in a yard */
		public static const DISTANCE_YARD:Number = 3*DISTANCE_FEET;
		
		/** Millimeters in a mile */
		public static const DISTANCE_MILE:Number = 1760*DISTANCE_YARD;
		
		
		/**
		 * Converts a number's base
		 * 
		 * @param	from		The number to convert
		 * @param	fromType	The base of number from. Use the NUMBER constants
		 * 						to represent this
		 * @param	toType		The base to convert to. Use the NUMBER constants
		 * 						to represent this
		 * 
		 * @return	The converted number
		 */
		public static function convert(from:Number, fromType:Number,
			toType:Number):Number
		{
			return (from*fromType)/toType;
		}
		
		/**
		 * Converts a number in to an array representing its different base values
		 * 
		 * @param	from		The number to convert
		 * @param	fromType	The base of the number from. Use the NUMBER 
		 * 						constants to represent this
		 * @param	toTypes		An array of bases to convert to
		 * 
		 * @return	An array of numbers. The index of each returned number will
		 * 			correspond to the indicies of the given toTypes array
		 */
		public static function breakdown(from:Number, fromType:Number,
			toTypes:Array):Array
		{
			var ret:Array = [];
			var remaining:Number = from;
			var length:int = toTypes.length;
			for(var i:int=0; i<length; ++i){
				var type:Number = toTypes[i];
				var amount:Number = Math.floor(convert(remaining,fromType,type));
				remaining -= convert(amount,type,fromType);
				ret[i] = amount;
			}
			return ret;
		}
	}
}