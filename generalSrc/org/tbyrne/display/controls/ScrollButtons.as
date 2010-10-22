package org.tbyrne.display.controls
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.core.LayoutView;
	import org.tbyrne.display.scrolling.IScrollMetrics;
	import org.tbyrne.display.scrolling.IScrollable;
	import org.tbyrne.display.scrolling.ScrollMetrics;
	
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
				if(_scrollable)setScrollMetrics(_scrollable.getScrollMetrics(_scrollDirection));
				validateScroll();
			}
		}
		
		public function get scrollable():IScrollable{
			return _scrollable;
		}
		public function set scrollable(value:IScrollable):void{
			if(_scrollable!=value){
				_scrollable = value;
				if(_scrollDirection)setScrollMetrics(_scrollable.getScrollMetrics(_scrollDirection));
				validateScroll();
			}
		}
		
		private var _scrollable:IScrollable;
		private var _scrollDirection:String = Direction.VERTICAL;
		private var _foreButton:Button;
		private var _aftButton:Button;
		
		private var _direction:Number;
		private var _holdStart:Number;
		private var _lastHoldTime:Number;
		private var _holdTimer:Timer;
		
		private var _scrollMetrics:IScrollMetrics;
		
		public function ScrollButtons(asset:IDisplayAsset=null){
			_foreButton = new Button();
			_foreButton.mousePressed.addHandler(onForeDown);
			_foreButton.mouseReleased.addHandler(onButtonUp);
			
			_aftButton = new Button();
			_aftButton.mousePressed.addHandler(onAftDown);
			_aftButton.mouseReleased.addHandler(onButtonUp);
			
			super(asset);
			scrollDirection = Direction.VERTICAL;
			
			_holdTimer = new Timer(DEF_INITIAL_HOLD_DELAY,1);
		}
		protected function setScrollMetrics(scrollMetrics:IScrollMetrics) : void{
			if(_scrollMetrics!=scrollMetrics){
				if(_scrollMetrics){
					_scrollMetrics.scrollMetricsChanged.removeHandler(onScrollMetricsChanged);
				}
				_scrollMetrics = scrollMetrics;
				if(_scrollMetrics){
					_scrollMetrics.scrollMetricsChanged.addHandler(onScrollMetricsChanged);
				}
			}
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
		override protected function commitSize():void{
			var foreMeas:Point = _foreButton.measurements;
			var aftMeas:Point = _aftButton.measurements;
			if(_scrollDirection==Direction.HORIZONTAL){
				_foreButton.setPosition(0,0);
				_foreButton.setSize(foreMeas.x,size.y);
				_aftButton.setPosition(position.x-aftMeas.x,0);
				_aftButton.setSize(aftMeas.x,position.y);
			}else{
				_foreButton.setPosition(0,0);
				_foreButton.setSize(size.x,foreMeas.y);
				_aftButton.setPosition(0,position.y-aftMeas.y);
				_aftButton.setSize(position.x,aftMeas.y);
			}
		}
		protected function onForeDown(from:Button) : void{
			_direction = -1;
			_holdStart = _lastHoldTime = getTimer();
			_holdTimer.delay = DEF_INITIAL_HOLD_DELAY;
			_holdTimer.addEventListener(TimerEvent.TIMER, onTick);
			_holdTimer.start();
		}
		protected function onAftDown(from:Button) : void{
			_direction = 1;
			_holdStart = _lastHoldTime = getTimer();
			_holdTimer.delay = DEF_INITIAL_HOLD_DELAY;
			_holdTimer.addEventListener(TimerEvent.TIMER, onTick);
			_holdTimer.start();
		}
		protected function onTick(e:Event) : void{
			var newTime:Number = getTimer();
			var scrollMulti:Number = (newTime-_lastHoldTime)/_holdTimer.delay;
			_lastHoldTime = newTime;
			scroll(_direction*scrollMulti);
			var newDelay:Number = _holdTimer.delay*DEF_HOLD_DELAY_ACCEL;
			if(newDelay>DEF_MIN_HOLD_DELAY){
				_holdTimer.delay = newDelay;
			}else{
				_holdTimer.delay = DEF_MIN_HOLD_DELAY;
			}
			_holdTimer.reset();
			_holdTimer.start();
		}
		protected function onButtonUp(from:Button) : void{
			if(getTimer()-_holdStart<DEF_INITIAL_HOLD_DELAY){
				scroll(_direction);
			}
			_holdTimer.stop();
			_holdTimer.reset();
		}
		protected function scroll(offset:Number):void{
			var newValue:Number = _scrollMetrics.scrollValue + offset;
			if(newValue<0)newValue = 0;
			else if(newValue>_scrollMetrics.maximum-_scrollMetrics.pageSize)newValue = _scrollMetrics.maximum-_scrollMetrics.pageSize;
			
			_scrollMetrics.scrollValue = newValue;
		}
		protected function onScrollMetricsChanged(from:IScrollMetrics):void{
			validateScroll();
		}
		protected function validateScroll(metrics:ScrollMetrics=null):void{
			if(_scrollMetrics){
				_foreButton.active = _scrollMetrics.scrollValue>0;
				_aftButton.active = _scrollMetrics.scrollValue<(_scrollMetrics.maximum-_scrollMetrics.pageSize);
			}else{
				_foreButton.active = false;
				_aftButton.active = false;
			}
		}
	}
}