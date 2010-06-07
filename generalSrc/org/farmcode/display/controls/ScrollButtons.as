package org.farmcode.display.controls
{
	import au.com.thefarmdigital.display.scrolling.IScrollable;
	import au.com.thefarmdigital.structs.ScrollMetrics;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.core.LayoutView;
	
	public class ScrollButtons extends LayoutView
	{
		private static const DEF_INITIAL_HOLD_DELAY:Number = 300;
		private static const DEF_HOLD_DELAY_ACCEL:Number = 0.9;
		private static const DEF_MIN_HOLD_DELAY:Number = 100;
		
		
		public function get scrollDirection():String{
			return _scrollDirection;
		}
		public function set scrollDirection(value:String):void{
			if(_scrollDirection!=value){
				_scrollDirection = value;
				validateScroll();
			}
		}
		
		public function get scrollable():IScrollable{
			return _scrollable;
		}
		public function set scrollable(value:IScrollable):void{
			if(_scrollable!=value){
				_scrollable = value;
				_scrollable.scrollMetricsChanged.addHandler(onScrollMetricsChanged);
				validateScroll();
			}
		}
		
		private var _scrollable:IScrollable;
		private var _scrollDirection:String;
		private var _foreButton:Button;
		private var _aftButton:Button;
		
		private var _direction:Number;
		private var _holdStart:Number;
		private var _lastHoldTime:Number;
		private var _holdTimer:Timer;
		
		private var _scrollMetrics:ScrollMetrics = new ScrollMetrics();
		
		public function ScrollButtons(asset:IDisplayAsset=null){
			_foreButton = new Button();
			_foreButton.mouseDownAct.addHandler(onForeDown);
			_foreButton.mouseUpAct.addHandler(onButtonUp);
			
			_aftButton = new Button();
			_aftButton.mouseDownAct.addHandler(onAftDown);
			_aftButton.mouseUpAct.addHandler(onButtonUp);
			
			super(asset);
			scrollDirection = Direction.VERTICAL;
			
			_holdTimer = new Timer(DEF_INITIAL_HOLD_DELAY,1);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_foreButton.asset = _containerAsset.takeAssetByName("foreButton",IDisplayAsset);
			_aftButton.asset = _containerAsset.takeAssetByName("aftButton",IDisplayAsset);
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			_containerAsset.returnAsset(_foreButton.asset);
			_containerAsset.returnAsset(_aftButton.asset);
			_foreButton.asset = null;
			_aftButton.asset = null;
		}
		override protected function measure() : void{
			super.measure();
		}
		override protected function draw() : void{
			positionAsset();
			var foreMeas:Rectangle = _foreButton.displayMeasurements;
			var aftMeas:Rectangle = _aftButton.displayMeasurements;
			if(_scrollDirection==Direction.HORIZONTAL){
				_foreButton.setDisplayPosition(0,0,foreMeas.width,displayPosition.height);
				_aftButton.setDisplayPosition(displayPosition.width-aftMeas.width,0,aftMeas.width,displayPosition.height);
			}else{
				_foreButton.setDisplayPosition(0,0,displayPosition.width,foreMeas.height);
				_aftButton.setDisplayPosition(0,displayPosition.height-aftMeas.height,displayPosition.width,aftMeas.height);
			}
		}
		protected function onForeDown(from:Button) : void{
			_direction = -1;
			_holdStart = _lastHoldTime = getTimer();
			var multi:Number = _scrollable.getScrollMultiplier(_scrollDirection);
			_holdTimer.delay = DEF_INITIAL_HOLD_DELAY/multi;
			_holdTimer.addEventListener(TimerEvent.TIMER, onTick);
			_holdTimer.start();
		}
		protected function onAftDown(from:Button) : void{
			_direction = 1;
			_holdStart = _lastHoldTime = getTimer();
			var multi:Number = _scrollable.getScrollMultiplier(_scrollDirection);
			_holdTimer.delay = DEF_INITIAL_HOLD_DELAY/multi;
			_holdTimer.addEventListener(TimerEvent.TIMER, onTick);
			_holdTimer.start();
		}
		protected function onTick(e:Event) : void{
			var newTime:Number = getTimer();
			var scrollMulti:Number = (newTime-_lastHoldTime)/_holdTimer.delay;
			_lastHoldTime = newTime;
			scroll(_direction*scrollMulti);
			var multi:Number = _scrollable.getScrollMultiplier(_scrollDirection);
			var newDelay:Number = _holdTimer.delay*DEF_HOLD_DELAY_ACCEL;
			if(newDelay>DEF_MIN_HOLD_DELAY/multi){
				_holdTimer.delay = newDelay;
			}else{
				_holdTimer.delay = DEF_MIN_HOLD_DELAY/multi;
			}
			_holdTimer.reset();
			_holdTimer.start();
		}
		protected function onButtonUp(from:Button) : void{
			if(getTimer()-_holdStart<DEF_INITIAL_HOLD_DELAY){
				var multi:Number = _scrollable.getScrollMultiplier(_scrollDirection);
				scroll(_direction*multi);
			}
			_holdTimer.stop();
			_holdTimer.reset();
		}
		protected function scroll(offset:Number):void{
			if(!_scrollMetrics){
				_scrollMetrics = new ScrollMetrics();
			}
			var metrics:ScrollMetrics = _scrollable.getScrollMetrics(_scrollDirection);
			_scrollMetrics.maximum = metrics.maximum;
			_scrollMetrics.minimum = metrics.minimum;
			_scrollMetrics.pageSize = metrics.pageSize;
			_scrollMetrics.value = metrics.value+offset;
			if(_scrollMetrics.value<0)_scrollMetrics.value = 0;
			else if(_scrollMetrics.value>_scrollMetrics.maximum-_scrollMetrics.pageSize)_scrollMetrics.value = _scrollMetrics.maximum-_scrollMetrics.pageSize;
			_scrollable.setScrollMetrics(_scrollDirection,_scrollMetrics);
			validateScroll(_scrollMetrics);
		}
		protected function onScrollMetricsChanged(from:IScrollable, direction:String, metrics:ScrollMetrics):void{
			validateScroll();
		}
		protected function validateScroll(metrics:ScrollMetrics=null):void{
			if(_scrollable){
				if(!metrics)metrics = _scrollable.getScrollMetrics(_scrollDirection);
				_foreButton.active = metrics.value>0;
				_aftButton.active = metrics.value<(metrics.maximum-metrics.pageSize);
			}else{
				_foreButton.active = false;
				_aftButton.active = false;
			}
		}
	}
}