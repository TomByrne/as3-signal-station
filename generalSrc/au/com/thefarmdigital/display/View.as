package au.com.thefarmdigital.display
{
	
	import au.com.thefarmdigital.delayedDraw.DelayedDrawSprite;
	import au.com.thefarmdigital.events.ControlEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Event(name="measurementsChange",type="au.com.thefarmdigital.events.ControlEvent")]
	/**
	 * The View class is the superclass to all display classes in the farm code library.
	 * It adds an invalidation delay (allowing visual changes to be collated and drawn all at once).
	 */
	public class View extends DelayedDrawSprite
	{
		override public function get width():Number{
			return _width;
		}
		override public function set width(value:Number):void{
			if(_width!=value){
				_width = value;
				invalidate();
			}
		}
		
		override public function get height():Number{
			return _height;
		}
		override public function set height(value:Number):void{
			if(_height!=value){
				_height = value;
				invalidate();
			}
		}
		
		public function get measuredHeight():Number{
			this.ensureMeasurements();
			return this._measuredHeight;
		}
		public function get measuredWidth():Number{
			this.ensureMeasurements();
			return this._measuredWidth;
		}
		
		protected function get childrenConstructed(): Boolean
		{
			return this._childrenConstructed;
		}
		
		[Property(clonable="true")]
		public function set position(value: Point): void {
			this.x = value.x;
			this.y = value.y;
		}
		public function get position(): Point {
			return new Point(this.x, this.y);
		}
		
		[Property(clonable="true")]
		public function set size(value: Point): void {
			this.width = value.x;
			this.height = value.y;
		}
		public function get size(): Point {
			return new Point(this.width, this.height);
		}
		
		/**
		 * @private
		 */
		protected var measurementsValid: Boolean = false;
		/**
		 * @private
		 */
		protected var _measuredWidth: Number = NaN;
		/**
		 * @private
		 */
		protected var _measuredHeight: Number = NaN;
		/**
		 * @private
		 */
		protected var _width:Number;
		/**
		 * @private
		 */
		protected var _height:Number;
		private var _childrenConstructed: Boolean;
		
		public function View(){
			super();
			
			this._childrenConstructed = true;
			this.updateSizeFromBounds();
		}
		
		/**
		 * Calculates the initial width and height of the view based on it's physical bounds. The 
		 * main purpose of this functionality is to cater for the situation where the View is 
		 * created in flash and as such will have an initial width and height matching the physical
		 * authoring of the object
		 */
		protected function updateSizeFromBounds(): void
		{
			var matrix: Matrix = transform.matrix;
			transform.matrix = new Matrix();
			var bounds:Rectangle = super.getBounds(parent?parent:this);
			x = matrix.tx;
			y = matrix.ty;
			width = bounds.width*matrix.a;
			height = bounds.height*matrix.d;
		}
		
		protected function invalidateMeasurements(): void
		{
			if(measurementsValid){
				if(hasEventListener(ControlEvent.MEASUREMENTS_CHANGE)){
					// avoid creating event object if no one is listening
					dispatchEvent(new ControlEvent(ControlEvent.MEASUREMENTS_CHANGE));
				}
				this.measurementsValid = false;
			}
		}
		
		// TODO: Adjusted getBounds implementation
		/*override public function getBounds(targetCoordinateSpace:DisplayObject): Rectangle
		{
			var bounds: Rectangle = new Rectangle();
			return bounds;
		}*/
		
		/**
		 * Calculates the measured width and measured height. This will only run if
		 * the measurements valid flag is set to false or the force argument is true
		 * 
		 * @param	forceCalculate	is whether to ignore the measurements valid flag
		 */
		protected function ensureMeasurements(forceCalculate: Boolean = false): void
		{
			if (!this.measurementsValid || forceCalculate)
			{
				this.measure();
				this.measurementsValid = true;
			}
		}
		
		protected function measure(): void
		{
		}
		
		// TODO: Optimisations for this; i.e. only recreate if new child is added/removed
		public function get children(): Array {
			var kids: Array = new Array();
			for (var i: uint = 0; i < this.numChildren; ++i)
			{
				var child: DisplayObject = this.getChildAt(i);
				kids.push(child);
			}
			return kids;
		}
		public function set children(value: Array): void {
			while (this.numChildren > 0)
			{
				this.removeChildAt(this.numChildren - 1);
			}
			if (value != null && value.length > 0)
			{
				for each (var child: DisplayObject in value)
				{
					this.addChild(child);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 * The dispatchEvent method has been optimised to avoid dispatching an event when nothing is 
		 * listening.
		 */
		override public function dispatchEvent(evt:Event):Boolean {
		 	if (hasEventListener(evt.type) || evt.bubbles) {
		  		return super.dispatchEvent(evt);
		  	}
		 	return true;
		}
	}
}