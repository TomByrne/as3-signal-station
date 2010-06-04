package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.display.controls.Control;
	import au.com.thefarmdigital.display.controls.StateControl;
	import au.com.thefarmdigital.display.controls.VisualState;
	import au.com.thefarmdigital.display.scrolling.IScrollable;
	import au.com.thefarmdigital.structs.ScrollMetrics;
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.constants.Direction;

	public class Container extends StateControl implements IScrollable
	{
		internal static const BASE_STATE:String = "baseState";
		
		public function get topPadding():Number{
			return _topPadding;
		}
		public function set topPadding(value:Number):void{
			if(_topPadding!=value){
				_topPadding = value;
				invalidate();
				invalidateScrollMetrics(Direction.VERTICAL);
			}
		}
		public function get leftPadding():Number{
			return _leftPadding;
		}
		public function set leftPadding(value:Number):void{
			if(_leftPadding!=value){
				_leftPadding = value;
				invalidate();
				invalidateScrollMetrics(Direction.HORIZONTAL)
			}
		}
		public function get bottomPadding():Number{
			return _bottomPadding;
		}
		public function set bottomPadding(value:Number):void{
			if(_bottomPadding!=value){
				_bottomPadding = value;
				invalidate();
				invalidateScrollMetrics(Direction.VERTICAL)
			}
		}
		public function get rightPadding():Number{
			return _rightPadding;
		}
		public function set rightPadding(value:Number):void{
			if(_rightPadding!=value){
				_rightPadding = value;
				invalidate();
				invalidateScrollMetrics(Direction.HORIZONTAL)
			}
		}
		public function get backing():DisplayObject{
			return _backing;
		}
		public function set backing(to:DisplayObject):void{
			if(_backing!=to){
				removeState(BASE_STATE);
				_backing = to;
				addState(new VisualState(BASE_STATE,to));
				showStateList([BASE_STATE]);
				invalidate();
			}
		}
		public function get maskContents():Boolean{
			return _maskContents;
		}
		public function set maskContents(value:Boolean):void{
			if(_maskContents!=value){
				_maskContents = value;
				invalidate();
			}
		}
		override public function set width(value:Number):void{
			if(super.width!=value){
				super.width = value;
				invalidateScrollMetrics(Direction.HORIZONTAL)
			}
		}
		override public function set height(value:Number):void{
			if(super.height!=value){
				super.height = value;
				invalidateScrollMetrics(Direction.VERTICAL)
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
		
		protected var _maskContents:Boolean = true;
		protected var _topPadding:Number = 0;
		protected var _leftPadding:Number = 0;
		protected var _bottomPadding:Number = 0;
		protected var _rightPadding:Number = 0;
		protected var _containerPos:Point = new Point();
		
		protected var container:DisplayObjectContainer;
		protected var _backing:DisplayObject;
		
		override protected function commitHeirarchy():void{
			container = new Sprite();
			container.name = "container";
			super.commitHeirarchy();
			removeCompiledClips();
			super.addChild(container);
		}
		protected function removeCompiledClips():void{
			var i:int=0;
			while(i<super.numChildren){
				var child:DisplayObject = getChildAt(i);
				if(child is Control && child!=backing){
					addChildTo(container,child);
				}else{
					i++;
				}
			}
		}
		override protected function measure():void{
			_measuredHeight = container.height+topPadding+bottomPadding;
			_measuredWidth = container.width+leftPadding+rightPadding;
		}
		override protected function draw():void{
			super.draw();
			if(_maskContents){
				container.x = _leftPadding;
				container.y = _topPadding;
				container.scrollRect = new Rectangle(-_containerPos.x,-_containerPos.y,width-_leftPadding-_rightPadding,height-_topPadding-_bottomPadding);
			}else{
				container.x = _leftPadding+_containerPos.x;
				container.y = _topPadding+_containerPos.y;
				container.scrollRect = null;
			}
			if(_backing){
				_backing.x = 0;
				_backing.y = 0;
				_backing.width = width;
				_backing.height = height;
			}
		}
		
		protected function invalidateBothScrollMetrics(): void
		{
			invalidateScrollMetrics(Direction.HORIZONTAL);
			invalidateScrollMetrics(Direction.VERTICAL);
		}
		protected function invalidateScrollMetrics(direction:String): void
		{
			if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this,direction,getScrollMetrics(direction));
		}
		
		// IScrollable implementation
		public function addScrollWheelListener(direction:String):Boolean{
			return true;
		}
		public function getScrollMetrics(direction:String):ScrollMetrics{
			var ret:ScrollMetrics;
			var bounds: Rectangle = DisplayUtils.getBoundsFromChildren(container);
			if(direction==Direction.VERTICAL){
				// Use this method in case there's a scrollRect; bounds wont be worked out correctly
				var displayHeight: Number = height-topPadding-bottomPadding;
				ret = new ScrollMetrics(0, Math.max(displayHeight, bounds.height), displayHeight);
				ret.value = -_containerPos.y;
			}else{
				var displayWidth: Number = width-leftPadding-rightPadding;
				ret = new ScrollMetrics(0, Math.max(displayWidth, bounds.width), displayWidth);
				ret.value = -_containerPos.x;
			}
			return ret;
		}
		public function setScrollMetrics(direction:String,metrics:ScrollMetrics):void{
			if(direction==Direction.VERTICAL){
				_containerPos.y = -metrics.value;
			}else{
				_containerPos.x = -metrics.value;
			}
			invalidate();
		}
		public function getScrollMultiplier(direction:String):Number{
			return 1;
		}
	}
}