package org.farmcode.display.behaviour.controls
{
	import au.com.thefarmdigital.display.scrolling.IScrollable;
	import au.com.thefarmdigital.structs.ScrollMetrics;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.behaviour.LayoutViewBehaviour;
	
	public class ScrollBar extends LayoutViewBehaviour
	{
		// amount of second between clicking the foreButton/aftButton and the scrolling beginning
		// i.e. it moves once due to the click, but then waits before scrolling further.
		private static const SCROLL_DELAY:Number = 0.4;
		private static const SCROLL_DURATION:Number = 0.05;
		
		public function set scrollSubject(to:IScrollable):void{
			if(_scrollSubject != to){
				if(_scrollSubject){
					_scrollSubject.mouseWheel.removeHandler(onMouseWheel);
					_scrollSubject.scrollMetricsChanged.removeHandler(getSubjectMetrics);
				}
				_scrollSubject = to;
				if (_scrollSubject) {
					_scrollSubject.scrollMetricsChanged.addHandler(getSubjectMetrics);
					if(_scrollSubject.addScrollWheelListener(_direction)){
						_scrollSubject.mouseWheel.addHandler(onMouseWheel);
					}
					scrollMetrics = _scrollSubject.getScrollMetrics(_direction);
				}
			}
		}
		public function get scrollSubject():IScrollable{
			return _scrollSubject;
		}
		public function set scrollMetrics(value:ScrollMetrics):void{
			if((_scrollMetrics == null && value != null) ||
				(_scrollMetrics != null && value == null) ||
				!_scrollMetrics.equals(value)
			)
			{
				if(value){
					_scrollMetrics.maximum = value.maximum;
					_scrollMetrics.minimum = value.minimum;
					_scrollMetrics.pageSize = value.pageSize;
					_scrollMetrics.value = value.value;
				}else{
					_scrollMetrics.value = NaN;
				}
				invalidate();
			}
		}
		public function get scrollMetrics():ScrollMetrics{
			return _scrollMetrics;
		}
		public function set scrollLines(to:Number):void{
			_scrollLines = to;
		}
		public function get scrollLines():Number{
			return _scrollLines;
		}
		public function set direction(to:String):void{
			if(_direction != to){
				_direction = to;
				if(_scrollSubject)_scrollMetrics = _scrollSubject.getScrollMetrics(_direction);
				invalidate();
			}
		}
		public function get direction():String{
			return _direction;
		}
		
		[Inspectable(defaultValue=true, type="Boolean")]
		/**
		 * sizeThumbToContent determines whether to alter the scroll thumb/handle height 
		 * proportionately to the scroll content size
		 */
		public function set sizeThumbToContent(to:Boolean):void{
			if(_sizeThumbToContent != to){
				_sizeThumbToContent = to;
				invalidate();
			}
		}
		public function get sizeThumbToContent():Boolean{
			return _sizeThumbToContent;
		}
		/**
		 * rotateForHorizontal determines whether the inner buttons will be rotated
		 * when the direction is changed to horizontal.
		 */
		public function set rotateForHorizontal(to:Boolean):void{
			if(_rotateForHorizontal != to){
				_rotateForHorizontal = to;
				invalidate();
			}
		}
		public function get rotateForHorizontal():Boolean{
			return _rotateForHorizontal;
		}
		public function set useHandCursor(to:Boolean):void{
			if(_useHandCursor != to){
				_useHandCursor = to;
				if(asset){
					checkIsBound();
					_track.useHandCursor = to;
					_scrollThumb.useHandCursor = to;
					if(_foreButton)_foreButton.useHandCursor = to;
					if(_aftButton)_aftButton.useHandCursor = to;
				}
			}
		}
		public function get useHandCursor():Boolean{
			return _useHandCursor;
		}
		
		[Inspectable(defaultValue=true, type="Boolean")]
		public function set hideWhenUnusable(to:Boolean):void{
			if(_hideWhenUnusable != to){
				this._hideWhenUnusable = to;
				invalidate();
			}
		}
		public function get hideWhenUnusable():Boolean{
			return _hideWhenUnusable;
		}
		public function get isUsable():Boolean{
			validate();
			return _isUsable;
		}
		
		
		/**
		 * handler(from:ScrollBar, scrollMetrics:ScrollMetrics)
		 */
		public function get scroll():IAct{
			if(!_scroll)_scroll = new Act();
			return _scroll;
		}
		
		protected var _scroll:Act;
		
		private var _hideWhenUnusable:Boolean = true;
		private var _isUsable:Boolean = true;
		private var _sizeThumbToContent:Boolean = true;
		private var _scrollMetrics:ScrollMetrics = new ScrollMetrics(0,0,0);
		private var _scrollSubject:IScrollable;
		private var _dragOffset:Number;
		private var _scrollLines:Number = 1;
		private var _scrollIncrement:Number;
		private var _scrollInterval:Number;
		private var _useHandCursor:Boolean = false;
		private var _direction:String = Direction.VERTICAL;
		private var _rotateForHorizontal:Boolean = true;
		private var _scrollTimer:Timer;
		
		private var _track:Sprite;
		private var _scrollThumb:Sprite;
		private var _foreButton:Sprite;
		private var _aftButton:Sprite;
		
		public function ScrollBar(asset:DisplayObject=null){
			super(asset);
			_scrollMetrics = new ScrollMetrics(0,1,1);
			_scrollMetrics.value = 0;
			_displayMeasurements = new Rectangle();
		}
		
		override protected function bindToAsset(): void{
			asset.addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
			
			_track = containerAsset.getChildByName("track") as Sprite;
			_track.useHandCursor = _useHandCursor;
			_track.addEventListener(MouseEvent.CLICK,scrollToMouse);
			
			_scrollThumb = containerAsset.getChildByName("scrollThumb") as Sprite;
			_scrollThumb.useHandCursor = _useHandCursor;
			_scrollThumb.addEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
			
			_foreButton = containerAsset.getChildByName("foreButton") as Sprite;
			if(_foreButton){
				_foreButton.useHandCursor = _useHandCursor;
				_foreButton.addEventListener(MouseEvent.MOUSE_DOWN,beginScroll);
			}
			
			_aftButton = containerAsset.getChildByName("aftButton") as Sprite;
			if(_aftButton){
				_aftButton.useHandCursor = _useHandCursor;
				_aftButton.addEventListener(MouseEvent.MOUSE_DOWN,beginScroll);
			}
		}
		override protected function unbindFromAsset(): void{
			asset.removeEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
			
			_track.removeEventListener(MouseEvent.CLICK,scrollToMouse);
			_track = null;
			
			_scrollThumb.removeEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
			_scrollThumb = null;
			
			if(_foreButton){
				_foreButton.removeEventListener(MouseEvent.MOUSE_DOWN,beginScroll);
				_foreButton = null;
			}
			
			if(_aftButton){
				_aftButton.removeEventListener(MouseEvent.MOUSE_DOWN,beginScroll);
				_aftButton = null;
			}
		}
		override protected function measure(): void{
			this.validate();
		}
		
		public function setToMinimum(): void {
			if (this._scrollMetrics != null) {
				this._scrollMetrics.value = this._scrollMetrics.minimum;
				this.commitScrollMetrics(true);
			}
		}
		override protected function draw():void{
			asset.x = displayPosition.x;
			asset.y = displayPosition.y;
			var scope:Number = (_scrollMetrics.maximum-_scrollMetrics.pageSize-_scrollMetrics.minimum);
			var rawRatio:Number;
			var ratio:Number;
			_isUsable = (_scrollMetrics.pageSize<_scrollMetrics.maximum-_scrollMetrics.minimum);
			if(!_isUsable){
				rawRatio = ratio = 0;
				// Only change the visibility if the user has asked us to manage the visibility
				if(this.hideWhenUnusable){
					asset.visible = false
				}
			}else{
				rawRatio = (_scrollMetrics.value-_scrollMetrics.minimum)/scope;
				ratio = (scope?Math.min(Math.max(rawRatio,0),1):0);
				// Only change the visibility if the user has asked us to manage the visibility
				if (this.hideWhenUnusable)
				{
					asset.visible = true;
				}
			}
			if(_direction==Direction.VERTICAL){
				var trackHeight:Number = displayPosition.height;
				if (_foreButton) {
					trackHeight -= _foreButton.height;
				}
				if (_aftButton) {
					trackHeight -= _aftButton.height;
				}
				if(_track){
					_track.height = trackHeight
					if (_foreButton){
						_track.y = _foreButton.height;
					}else{
						_track.y = 0;
					}
				}
				if (_aftButton) {
					_aftButton.y = _track.y+_track.height;
				}
				if(_scrollThumb && _track){
					if (_sizeThumbToContent) {
						var sizeFraction:Number = (_scrollMetrics.maximum>_scrollMetrics.minimum?_scrollMetrics.pageSize/(_scrollMetrics.maximum-_scrollMetrics.minimum):1);
						_scrollThumb.height = Math.min(_track.height*sizeFraction,_track.height);
					}else{
						_scrollThumb.scaleY = 1;
					}
					var thumbY: Number = (trackHeight-_scrollThumb.height)*ratio;
					if (_foreButton) {
						thumbY += _foreButton.height;
					}
					_scrollThumb.y = thumbY;
				}
				_displayMeasurements.width = Math.max(_scrollThumb.width,_track.width);
				_displayMeasurements.height = 0;
				if (_foreButton) {
					_displayMeasurements.width = Math.max(_foreButton.width, _displayMeasurements.width);
					_displayMeasurements.height += _foreButton.height
				}
				if (_aftButton) {
					_displayMeasurements.width = Math.max(_displayMeasurements.width, _aftButton.width);
					_displayMeasurements.height += _aftButton.height
				}
			}else{
				var trackWidth:Number = displayPosition.width;;
				if (_foreButton) {
					trackWidth -= _foreButton.width;
				}
				if (_aftButton) {
					trackWidth -= _aftButton.width;
					_aftButton.x = trackWidth;
					if (_foreButton) {
						_aftButton.x += _foreButton.width;
					}
				}
				if(_track){
					_track.width = trackWidth;
					if (_foreButton) {
						_track.x = _foreButton.width;
					}else{
						_track.x = 0;
					}
				}
				if(_scrollThumb && _track){
					if (sizeThumbToContent){
						var thumbWidth: Number = Math.min(_track.width*(_scrollMetrics.pageSize/(_scrollMetrics.maximum-_scrollMetrics.minimum)),_track.width);
						_scrollThumb.width = thumbWidth;
					}else{
						_scrollThumb.scaleX = 1;
					}
					_scrollThumb.x = (trackWidth-_scrollThumb.width)*ratio;
					if (_foreButton){
						_scrollThumb.x += _foreButton.width;
					}
				}
				_displayMeasurements.height = Math.max(_scrollThumb.height,_track.height);
				_displayMeasurements.width = 0;
				if (_foreButton) {
					_displayMeasurements.height = Math.max(_foreButton.height, _displayMeasurements.height);
					_displayMeasurements.width += _foreButton.width;
				}
				if (_aftButton) {
					_displayMeasurements.height = Math.max(_displayMeasurements.height, _aftButton.height);
					_displayMeasurements.width += _aftButton.width;
				}
			}
			// Not working properly when call setToMinimum; ratios are =, not sure how supposed to function
			if(ratio!=rawRatio){
				_scrollMetrics.value = (ratio*scope)+_scrollMetrics.minimum;
				this.commitScrollMetrics();
			}
		}
		protected function scrollToMouse(e:Event=null):void{
			var offset:Number;
			var ratio:Number;
			if(_direction==Direction.VERTICAL){
				offset = (!isNaN(_dragOffset)?_dragOffset:(_scrollThumb?_scrollThumb.height/2:0));
				ratio = Math.max(Math.min((asset.mouseY-offset-_track.y)/(_track.height-_scrollThumb.height),1),0);
			}else{
				offset = (!isNaN(_dragOffset)?_dragOffset:(_scrollThumb?_scrollThumb.width/2:0));
				ratio = Math.max(Math.min((asset.mouseX-offset-_track.x)/(_track.width-_scrollThumb.width),1),0);
			}
			_scrollMetrics.value = Math.round((ratio*(_scrollMetrics.maximum-_scrollMetrics.pageSize-_scrollMetrics.minimum))+_scrollMetrics.minimum);
			this.commitScrollMetrics(true);
		}
		
		protected function beginDrag(e:Event):void{
			if(_scrollThumb){
				if(_direction==Direction.VERTICAL){
					_dragOffset = asset.mouseY-_scrollThumb.y;
				}else{
					_dragOffset = asset.mouseX-_scrollThumb.x;
				}
			}else{
				_dragOffset = NaN;
			}
			scrollToMouse();
			asset.stage.addEventListener(MouseEvent.MOUSE_MOVE,scrollToMouse);
			asset.stage.addEventListener(MouseEvent.MOUSE_UP,endDrag);
		}
		protected function endDrag(e:Event):void{
			scrollToMouse();
			asset.stage.removeEventListener(MouseEvent.MOUSE_MOVE,scrollToMouse);
			asset.stage.removeEventListener(MouseEvent.MOUSE_UP,endDrag);
			_dragOffset = NaN;
		}
		
		protected function beginScroll(e:MouseEvent):void{
			_scrollIncrement = (e.target==_foreButton?-scrollLines:(e.target==_aftButton?scrollLines:NaN));
			if(!isNaN(_scrollIncrement)){
				if(_scrollSubject){
					var subjMultiplier:Number = _scrollSubject.getScrollMultiplier(_direction);
					if(!isNaN(subjMultiplier))_scrollIncrement *= subjMultiplier;
				}
				doScroll();
				_scrollTimer = new Timer(SCROLL_DELAY*1000,1);
				_scrollTimer.addEventListener(TimerEvent.TIMER_COMPLETE,beginFrameScroll);
				_scrollTimer.start();
				
				asset.stage.addEventListener(MouseEvent.MOUSE_UP,endScroll);
			}
		}
		protected function beginFrameScroll(e:Event):void{
			_scrollTimer = new Timer(SCROLL_DURATION*1000);
			_scrollTimer.addEventListener(TimerEvent.TIMER,doScroll);
			_scrollTimer.start();
		}
		protected function doScroll(e:Event=null):void{
			_scrollMetrics.value = Math.min(Math.max(_scrollMetrics.value+_scrollIncrement,_scrollMetrics.minimum),_scrollMetrics.maximum-_scrollMetrics.pageSize);
			this.commitScrollMetrics(true);
		}
		
		private function commitScrollMetrics(validateNow: Boolean = false): void
		{
			if(_scrollSubject)
			{
				_scrollSubject.setScrollMetrics(_direction,_scrollMetrics);
			}
			if(_scroll)_scroll.perform(this,_scrollMetrics);
			if (validateNow)
			{
				this.validate(true);
			}
		}
		
		protected function endScroll(e:Event):void{
			if(_scrollTimer){
				_scrollTimer.stop();
				_scrollTimer = null;
			}
			asset.stage.removeEventListener(MouseEvent.MOUSE_UP,endScroll);
		}
		protected function onMouseWheel(from:IScrollable, delta:int):void{
			if(_scrollMetrics.pageSize>_scrollMetrics.maximum-_scrollMetrics.minimum){
				_scrollMetrics.value = 0;
			}else{
				var dist:Number = delta;
				if(_scrollSubject){
					var subjMultiplier:Number = _scrollSubject.getScrollMultiplier(_direction);
					if(!isNaN(subjMultiplier))dist *= subjMultiplier;
				}
				_scrollMetrics.value = Math.min(Math.max(_scrollMetrics.value-dist*scrollLines,_scrollMetrics.minimum),_scrollMetrics.maximum-_scrollMetrics.pageSize);
			}
			this.commitScrollMetrics(true);
		}
		protected function getSubjectMetrics(from:IScrollable, direction:String, metrics:ScrollMetrics):void{
			if(direction==_direction){
				scrollMetrics = _scrollSubject.getScrollMetrics(_direction);
			}
		}
	}
}