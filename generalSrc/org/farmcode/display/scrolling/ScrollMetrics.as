package org.farmcode.display.scrolling
{
	import org.farmcode.hoborg.ReadableObjectDescriber;
	
	/**
	 * A set of scroll instructions
	 */
	public class ScrollMetrics
	{
		/** The minimum value in the scroll */
		[Property(toString="true")]
		public var minimum:Number;
		
		/** The maximum value in the scroll */
		[Property(toString="true")]
		public var maximum:Number;
		
		/** The size of a single page in the scroll */
		[Property(toString="true")]
		public var pageSize:Number;
		
		/** The current scroll value between minimum and maximum */
		[Property(toString="true")]
		public var value:Number;
		
		private var _value:Number;
		
		/**
		 * Creates a new scroll instruction.
		 * 
		 * @param	minimum		The minimum value of a scroll
		 * @param	maximum		The maximum value of a scroll
		 * @param	pageSize	The size of a page in the scroll area
		 */
		public function ScrollMetrics(minimum:Number=0, maximum:Number=NaN, 
			pageSize:Number=NaN)
		{
			this.minimum = minimum;
			this.maximum = maximum;
			this.pageSize = pageSize;
		}
		
		public function equals(scrollMetrics: ScrollMetrics): Boolean
		{
			var equal: Boolean = false;
			if (scrollMetrics != null)
			{
				equal = (scrollMetrics.value == this.value && scrollMetrics.pageSize == this.pageSize &&
							scrollMetrics.minimum == this.minimum && scrollMetrics.maximum == this.maximum);
			}
			return equal;
		}
		
		/**
		 * Retrieves a short description of the ScrollMetrics instruction
		 * 
		 * @return	A String describing the object
		 */
		public function toString():String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}