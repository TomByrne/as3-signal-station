package au.com.thefarmdigital.display.controls
{
	import au.com.thefarmdigital.display.scrolling.IScrollable;
	import au.com.thefarmdigital.structs.ScrollMetrics;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.constants.Direction;
	
	public class ScrollBar extends Control
	{
		// amount of second between clicking the foreButton/aftButton and the scrolling beginning
		// i.e. it moves once due to the click, but then waits before scrolling further.
		private static const SCROLL_DELAY:Number = 0.4;
		private static const SCROLL_DURATION:Number = 0.05;
		
		public function set scrollSubject(to:IScrollable):void{
			if(_scrollSubject != to){
				if(_scrollSubject){
					_scrollSubject.scrollMetricsChanged.removeHandler(getSubjectMetrics);
					_scrollSubject.mouseWheel.removeHandler(onMouseWheel);
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
		public function set scrollMetrics(to:ScrollMetrics):void{
			if((_scrollMetrics == null && to != null) ||
				(_scrollMetrics != null && to == null) ||
				!_scrollMetrics.equals(to)
				)
			{
				_scrollMetrics = to;
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
		public function get track():InteractiveObject{
			return _track;
		}
		public function set track(to:InteractiveObject):void{
			if(_track!=to){
				if(_track)_track.removeEventListener(MouseEvent.CLICK,scrollToMouse);
				_track = to;
				if(to.parent && to.parent!=this)to.parent.removeChild(to);
				if(!to.parent)addChild(to);
				if(_track is Sprite){
					(_track as Sprite).useHandCursor = _useHandCursor;
				}
				_track.addEventListener(MouseEvent.CLICK,scrollToMouse);
				invalidate();
			}
		}
		public function get scrollThumb():InteractiveObject{
			return _scrollThumb;
		}
		public function set scrollThumb(to:InteractiveObject):void{
			if(_scrollThumb!=to){
				if(_scrollThumb)_scrollThumb.removeEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
				_scrollThumb = to;
				if(to.parent && to.parent!=this)to.parent.removeChild(to);
				if(!to.parent)addChild(to);
				if(_scrollThumb is Sprite){
					(_scrollThumb as Sprite).useHandCursor = _useHandCursor;
				}
				_scrollThumb.addEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
				invalidate();
			}
		}
		public function get foreButton():InteractiveObject{
			return _foreButton;
		}
		public function set foreButton(to:InteractiveObject):void{
			if(_foreButton!=to){
				if(_foreButton)_foreButton.removeEventListener(MouseEvent.MOUSE_DOWN,beginScroll);
				_foreButton = to;
				if(to.parent && to.parent!=this)to.parent.removeChild(to);
				if(!to.parent)addChild(to);
				if(_foreButton is Sprite){
					(_foreButton as Sprite).useHandCursor = _useHandCursor;
				}
				_foreButton.addEventListener(MouseEvent.MOUSE_DOWN,beginScroll);
				invalidate();
			}
		}
		public function get aftButton():InteractiveObject{
			return _aftButton;
		}
		public function set aftButton(to:InteractiveObject):void{
			if(_aftButton!=to){
				if(_aftButton)_aftButton.removeEventListener(MouseEvent.MOUSE_DOWN,beginScroll);
				_aftButton = to;
				if(to.parent && to.parent!=this)to.parent.removeChild(to);
				if(!to.parent)addChild(to);
				if(_aftButton is Sprite){
					(_aftButton as Sprite).useHandCursor = _useHandCursor;
				}
				_aftButton.addEventListener(MouseEvent.MOUSE_DOWN,beginScroll);
				invalidate();
			}
		}
		override public function set useHandCursor(to:Boolean):void{
			if(_useHandCursor != to){
				_useHandCursor = to;
				if(_track && _track is Sprite){
					(_track as Sprite).useHandCursor = to;
				}
				if(_scrollThumb && _scrollThumb is Sprite){
					(_scrollThumb as Sprite).useHandCursor = to;
				}
				if(_foreButton && _foreButton is Sprite){
					(_foreButton as Sprite).useHandCursor = to;
				}
				if(_aftButton && _aftButton is Sprite){
					(_aftButton as Sprite).useHandCursor = to;
				}
			}
		}
		override public function get useHandCursor():Boolean{
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
		
		
		/**
		 * handler(from:ScrollBar, scrollMetrics:ScrollMetrics)
		 */
		public function get scroll():IAct{
			if(!_scroll)_scroll = new Act();
			return _scroll;
		}
		
		protected var _scroll:Act;
		
		private var _hideWhenUnusable:Boolean = true;
		private var _sizeThumbToContent:Boolean = true;
		private var _scrollMetrics:ScrollMetrics;
		private var _scrollSubject:IScrollable;
		private var _dragOffset:Number;
		private var _scrollLines:Number = 1;
		private var _scrollIncrement:Number;
		private var _scrollInterval:Number;
		private var _useHandCursor:Boolean = false;
		private var _direction:String = Direction.VERTICAL;
		private var _rotateForHorizontal:Boolean = true;
		private var _scrollTimer:Timer;
		
		private var _track:InteractiveObject;
		private var _scrollThumb:InteractiveObject;
		private var _foreButton:InteractiveObject;
		private var _aftButton:InteractiveObject;
		
		public function ScrollBar(){
			_scrollMetrics = new ScrollMetrics(0,1,1);
			_scrollMetrics.value = 0;
			addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
		}
		
		override protected function measure(): void
		{
			this.validate();
		}
		
		public function setToMinimum(): void {
			if (this._scrollMetrics != null) {
				this._scrollMetrics.value = this._scrollMetrics.minimum;
				this.commitScrollMetrics(true);
			}
		}
		override protected function draw():void{
			var scope:Number = (_scrollMetrics.maximum-_scrollMetrics.pageSize-_scrollMetrics.minimum);
			var rawRatio:Number;
			var ratio:Number;
			if(_scrollMetrics.pageSize>=_scrollMetrics.maximum-_scrollMetrics.minimum){
				rawRatio = ratio = 0;
				// Only change the visibility if the user has asked us to manage the visibility
				if(this.hideWhenUnusable){
					this.visible = false
				}
			}else{
				rawRatio = (_scrollMetrics.value-_scrollMetrics.minimum)/scope;
				ratio = (scope?Math.min(Math.max(rawRatio,0),1):0);
				// Only change the visibility if the user has asked us to manage the visibility
				if (this.hideWhenUnusable)
				{
					this.visible = true;
				}
			}
			if(_direction==Direction.VERTICAL){
				var trackHeight:Number = height;
				if (foreButton) {
					trackHeight -= foreButton.height;
				}
				if (aftButton) {
					trackHeight -= aftButton.height;
				}
				if(_track){
					_track.height = trackHeight
					if (foreButton){
						_track.y = foreButton.height;
					}else{
						_track.y = 0;
					}
				}
				if (aftButton) {
					aftButton.y = _track.y+_track.height;
				}
				if(_scrollThumb && _track){
					if (_sizeThumbToContent) {
						var sizeFraction:Number = (_scrollMetrics.maximum>_scrollMetrics.minimum?_scrollMetrics.pageSize/(_scrollMetrics.maximum-_scrollMetrics.minimum):1);
						_scrollThumb.height = Math.min(_track.height*sizeFraction,_track.height);
					}else{
						_scrollThumb.scaleY = 1;
					}
					var thumbY: Number = (trackHeight-_scrollThumb.height)*ratio;
					if (foreButton) {
						thumbY += foreButton.height;
					}
					_scrollThumb.y = thumbY;
				}
				_measuredWidth = Math.max(_scrollThumb.width,_track.width);
				_measuredHeight = 0;
				if (foreButton) {
					_measuredWidth = Math.max(foreButton.width, _measuredWidth);
					_measuredHeight += foreButton.height
				}
				if (aftButton) {
					_measuredWidth = Math.max(_measuredWidth, aftButton.width);
					_measuredHeight += aftButton.height
				}
			}else{
				var trackWidth:Number = width;
				if (foreButton) {
					trackWidth -= foreButton.width;
				}
				if (aftButton) {
					trackWidth -= aftButton.width;
					aftButton.x = trackWidth;
					if (foreButton) {
						aftButton.x += foreButton.width;
					}
				}
				if(_track){
					_track.width = trackWidth;
					if (foreButton) {
						_track.x = foreButton.width;
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
					if (foreButton){
						_scrollThumb.x += foreButton.width;
					}
				}
				_measuredHeight = Math.max(_scrollThumb.height,_track.height);
				_measuredWidth = 0;
				if (foreButton) {
					_measuredHeight = Math.max(foreButton.height, _measuredHeight);
					_measuredWidth += foreButton.width;
				}
				if (aftButton) {
					_measuredHeight = Math.max(_measuredHeight, aftButton.height);
					_measuredWidth += aftButton.width;
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
				ratio = Math.max(Math.min((mouseY-offset-_track.y)/(_track.height-_scrollThumb.height),1),0);
			}else{
				offset = (!isNaN(_dragOffset)?_dragOffset:(_scrollThumb?_scrollThumb.width/2:0));
				ratio = Math.max(Math.min((mouseX-offset-_track.x)/(_track.width-_scrollThumb.width),1),0);
			}
			_scrollMetrics.value = Math.round((ratio*(_scrollMetrics.maximum-_scrollMetrics.pageSize-_scrollMetrics.minimum))+_scrollMetrics.minimum);
			this.commitScrollMetrics(true);
		}
		
		protected function beginDrag(e:Event):void{
			if(_scrollThumb){
				if(_direction==Direction.VERTICAL){
					_dragOffset = mouseY-_scrollThumb.y;
				}else{
					_dragOffset = mouseX-_scrollThumb.x;
				}
			}else{
				_dragOffset = NaN;
			}
			scrollToMouse();
			stage.addEventListener(MouseEvent.MOUSE_MOVE,scrollToMouse);
			stage.addEventListener(MouseEvent.MOUSE_UP,endDrag);
		}
		protected function endDrag(e:Event):void{
			scrollToMouse();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,scrollToMouse);
			stage.removeEventListener(MouseEvent.MOUSE_UP,endDrag);
			_dragOffset = NaN;
		}
		
		protected function beginScroll(e:MouseEvent):void{
			_scrollIncrement = (e.target==_foreButton?-scrollLines:(e.target==_aftButton?scrollLines:NaN));
			if(!isNaN(_scrollIncrement)){
				onScroll();
				_scrollTimer = new Timer(SCROLL_DELAY*1000,1);
				_scrollTimer.addEventListener(TimerEvent.TIMER_COMPLETE,beginFrameScroll);
				_scrollTimer.start();
				
				stage.addEventListener(MouseEvent.MOUSE_UP,endScroll);
			}
		}
		protected function beginFrameScroll(e:Event):void{
			_scrollTimer = new Timer(SCROLL_DURATION*1000);
			_scrollTimer.addEventListener(TimerEvent.TIMER,onScroll);
			_scrollTimer.start();
		}
		protected function onScroll(e:Event=null):void{
			_scrollMetrics.value = Math.min(Math.max(_scrollMetrics.value+_scrollIncrement,_scrollMetrics.minimum),_scrollMetrics.maximum-_scrollMetrics.pageSize);
			this.commitScrollMetrics(true);
		}
		
		private function commitScrollMetrics(validateNow: Boolean = false): void
		{
			if(_scrollSubject)
			{
				_scrollSubject.setScrollMetrics(_direction,_scrollMetrics);
			}
			if(_scroll){
				_scroll.perform(this,_scrollMetrics);
			}
			
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
			stage.removeEventListener(MouseEvent.MOUSE_UP,endScroll);
		}
		protected function onMouseWheel(from:IScrollable, delta:int):void{
			if(_scrollMetrics.pageSize>_scrollMetrics.maximum-_scrollMetrics.minimum){
				_scrollMetrics.value = 0;
			}else{
				_scrollMetrics.value = Math.min(Math.max(_scrollMetrics.value-delta*scrollLines,_scrollMetrics.minimum),_scrollMetrics.maximum-_scrollMetrics.pageSize);
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