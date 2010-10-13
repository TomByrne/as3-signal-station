package org.tbyrne.display.constants
{
	public class Fit
	{
		/** Instruction to stretch the display so it doesn't clip but takes up as much space as possible */
		public static const INSIDE:String = "fitInside";
		/** Instruction to fit the display exactly in its bounds */
		public static const EXACT:String = "fitExact";
		/** Instruction to stretch the display so it fully takes up its bounds (may clip) */
		public static const STRETCH:String = "fitStretch";
	}
}