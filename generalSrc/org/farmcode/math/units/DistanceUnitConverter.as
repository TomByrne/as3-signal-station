package org.farmcode.math.units
{
	import org.farmcode.data.dataTypes.INumberProvider;
	
	public class DistanceUnitConverter extends UnitConverter
	{
		/** One Millimeter */
		public static const MILLIMETER:Number = 1;
		
		/** Millimeters in a centimeter */
		public static const CENTIMETER:Number = 10;
		
		/** Millimeters in a meter */
		public static const METER:Number = 100*CENTIMETER;
		
		/** Millimeters in a meter */
		public static const KILOMETER:Number = 1000*METER;
		
		/** Millimeters in an inch */
		public static const INCH:Number = 25.4;
		
		/** Millimeters in a foot */
		public static const FEET:Number = 12*INCH;
		
		/** Millimeters in a yard */
		public static const YARD:Number = 3*FEET;
		
		/** Millimeters in a mile */
		public static const MILE:Number = 1760*YARD;
		
		
		public function DistanceUnitConverter(from:INumberProvider, fromType:Number, toType:Number, roundResult:Boolean=false)
		{
			super(from, fromType, toType, roundResult);
		}
	}
}