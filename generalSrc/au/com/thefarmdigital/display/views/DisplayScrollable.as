package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.display.scrolling.IScrollable;
	import au.com.thefarmdigital.structs.ScrollMetrics;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.constants.Direction;

	public class DisplayScrollable extends EventDispatcher implements IScrollable
	{
		public function get display():DisplayObject{
			return _display;
		}
		public function set display(value:DisplayObject):void{
			if(_display != value){
				_display = value;
				if(!_scrollablePosition || _assumedPosition){
					_assumedPosition = true;
					_scrollablePosition = new Point(_display.x,display.y);
				}
				if(isNaN(_mask.width) || _assumedWidth){
					_assumedWidth = true;
					_mask.width = _display.width;
				}
				if(isNaN(_mask.height) || _assumedWidth){
					_assumedWidth = true;
					_mask.height = _display.height;
				}
				assessMask();
				if(_scrollMetricsChanged){
					_scrollMetricsChanged.perform(this,Direction.HORIZONTAL,getScrollMetrics(Direction.HORIZONTAL));
					_scrollMetricsChanged.perform(this,Direction.VERTICAL,getScrollMetrics(Direction.VERTICAL));
				}
			}
		}
		public function get scrollablePosition():Point{
			return _scrollablePosition;
		}
		public function set scrollablePosition(value:Point):void{
			if(_scrollablePosition != value){
				_scrollablePosition = value;
				_assumedPosition = false;
				if(_scrollMetricsChanged){
					_scrollMetricsChanged.perform(this,Direction.HORIZONTAL,getScrollMetrics(Direction.HORIZONTAL));
					_scrollMetricsChanged.perform(this,Direction.VERTICAL,getScrollMetrics(Direction.VERTICAL));
				}
			}
		}
		public function get scrollableWidth():Number{
			return _mask.width;
		}
		public function set scrollableWidth(value:Number):void{
			if(_mask.width != value){
				_mask.width = value;
				assessMask();
				_assumedWidth = false;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this,Direction.HORIZONTAL,getScrollMetrics(Direction.HORIZONTAL));
			}
		}
		public function get scrollableHeight():Number{
			return _mask.height;
		}
		public function set scrollableHeight(value:Number):void{
			if(_mask.height != value){
				_mask.height = value;
				assessMask();
				_assumedHeight = false;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this,Direction.VERTICAL,getScrollMetrics(Direction.VERTICAL));
			}
		}
		public function get doMasking():Boolean{
			return _doMasking;
		}
		public function set doMasking(value:Boolean):void{
			if(_doMasking != value){
				_doMasking = value;
				assessMask();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get scrollMetricsChanged():IAct{
			if(!_scrollMetricsChanged)_scrollMetricsChanged = new Act();
			return _scrollMetricsChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mouseWheel():IAct{
			if(!_mouseWheel)_mouseWheel = new Act();
			return _mouseWheel;
		}
		
		protected var _mouseWheel:Act;
		protected var _scrollMetricsChanged:Act;
		
		private var _doMasking:Boolean = true;
		private var _assumedPosition:Boolean = false;
		private var _scrollablePosition:Point;
		private var _assumedHeight:Boolean = false;
		private var _assumedWidth:Boolean = false;
		private var _display:DisplayObject;
		private var _mask:Rectangle = new Rectangle();
		private var _displayBounds:Rectangle;
		
		public function DisplayScrollable(display:DisplayObject=null){
			this.display = display;
		}

		public function isScrollable(direction:String): Boolean{
			var scrollable: Boolean = false;
			
			refreshBounds();
			
			if (this._mask != null){
				if (direction == Direction.VERTICAL){
					scrollable = (_displayBounds.height > _mask.height);
				}else{
					scrollable = (_displayBounds.width > _mask.width);
				}
			}
			return scrollable;
		}
		
		public function addScrollWheelListener(direction: String):Boolean{
			return true;
		}
		
		public function getScrollMetrics(direction: String): ScrollMetrics{
			var min: Number = 0;
			var max: Number = 0;
			var value: Number = 0;
			var pageSize: Number = 0;
			
			refreshBounds();
			
			if (direction == Direction.VERTICAL){
				min = _displayBounds.y;
				max = _displayBounds.y+_displayBounds.height;
				value = _mask.y;
				pageSize = scrollableHeight;
			}else{
				min = _displayBounds.x;
				max = _displayBounds.x+_displayBounds.width;
				value = _mask.x;
				pageSize = scrollableWidth;
			}
			var metrics: ScrollMetrics = new ScrollMetrics(min, max, pageSize);
			metrics.value = value;
			return metrics;
		}
		public function refresh():void{
			if(_scrollMetricsChanged){
				_scrollMetricsChanged.perform(this,Direction.HORIZONTAL,getScrollMetrics(Direction.HORIZONTAL));
				_scrollMetricsChanged.perform(this,Direction.VERTICAL,getScrollMetrics(Direction.VERTICAL));
			}
		}
		public function setScrollMetrics(direction: String, metrics: ScrollMetrics):void{
			if(doMasking){
				if (direction == Direction.VERTICAL){
					_mask.y = metrics.value;
				}else{
					_mask.x = metrics.value;
				}
				assessMask();
			}else{
				if (direction == Direction.VERTICAL){
					_display.y = _scrollablePosition.y-metrics.value;
				}else{
					_display.x = _scrollablePosition.x-metrics.value;
				}
			}
		}
		public function getScrollMultiplier(direction:String):Number{
			return 1;
		}
		
		protected function assessMask():void{
			if(_doMasking){
				_display.scrollRect = _mask;
			}else{
				_display.scrollRect = null;
			}
		}
		protected function refreshBounds():void{
			_displayBounds = display.getBounds(display);
		}
	}
}