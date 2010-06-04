package au.com.thefarmdigital.debug.infoSources
{
	import flash.system.System;

	public class MaxMemoryInfoSource extends CurrentMemoryInfoSource
	{
		private var maxMemory:Number = 0;
		
		public function MaxMemoryInfoSource(textUnit:Number=NaN, rounding:Number=0.01, labelColour:Number=0xffffff){
			super(textUnit, rounding, labelColour);
		}
		override public function get numericOutput() : Number{
			maxMemory = Math.max(maxMemory,System.totalMemory);
			return maxMemory;
		}
	}
}