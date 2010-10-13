package org.farmcode.display.layout.grid
{
	import org.farmcode.display.scrolling.ScrollMetrics;

	public class GridAxis
	{
		public var coordRef:String;
		public var indexRef:String;
		
		public var foreMargin:Number = 0;
		public var aftMargin:Number = 0;
		public var gap:Number = 0;
		
		/**
		 * cellSizes are externally specified sizes for the cells (in this axis).
		 */
		public var cellSizes:Array;
		public var cellSizesCount:int;
		public var hasCellSizes:Boolean = false;
		
		public var equaliseCells:Boolean;
		
		public var scrollByLine:Boolean;
		
		public var maxCount:int = -1;
		public var hasMaxCount:Boolean = false;
		public var maxCellSizes:Array;
		
		public var scrollMetrics:ScrollMetrics = new ScrollMetrics();
		public var pixScrollMetrics:ScrollMetrics = new ScrollMetrics();
		
		public function GridAxis(coordRef:String=null, indexRef:String=null){
			this.coordRef = coordRef;
			this.indexRef = indexRef;
		}
	}
}