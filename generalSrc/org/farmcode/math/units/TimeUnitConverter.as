package org.farmcode.math.units
{
	import org.farmcode.data.dataTypes.INumberProvider;
	
	public class TimeUnitConverter extends UnitConverter
	{
		/** A single millisecond */
		public static const MILLISECONDS:Number = 1;
		
		/** Number of milliseconds in a second */
		public static const SECONDS:Number = 1000;
		
		/** Number of milliseconds in a minute */
		public static const MINUTES:Number = 60*SECONDS;
		
		/** Number of milliseconds in an hour */
		public static const HOURS:Number = 60*MINUTES;
		
		/** Number of milliseconds in a day */
		public static const DAYS:Number = 24*HOURS;
		
		/** Number of milliseconds in a week */
		public static const WEEKS:Number = 24*DAYS;
		
		/** Number of milliseconds in a fortnight */
		public static const FORTNIGHTS:Number = 2*WEEKS;
		
		/** Number of milliseconds in a 365 day year */
		public static const YEARS:Number = 365*DAYS;
		
		/** Number of milliseconds in an average month in a 365 day year */
		public static const MONTHS:Number = YEARS / 12;
		
		
		public function TimeUnitConverter(from:INumberProvider, fromType:Number, toType:Number, roundResult:Boolean=false)
		{
			super(from, fromType, toType, roundResult);
		}
	}
}