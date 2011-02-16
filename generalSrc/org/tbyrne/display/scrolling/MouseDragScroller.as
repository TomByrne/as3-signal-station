package org.tbyrne.display.scrolling
{
	import flash.utils.getTimer;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.core.EnterFrameHook;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.nativeTypes.IStage;

	public class MouseDragScroller
	{
		private static const VELOCITY_THESHOLD:Number = 0.1;
		
		
		/**
		 * handler(from:MouseDragScroller)
		 */
		public function get onVelocityScroll():IAct{
			return ((_onVelocityScroll) || (_onVelocityScroll = new Act()));
		}
		
		protected var _onVelocityScroll:Act;
		
		public function get scrollMetrics():IScrollMetrics{
			return _scrollMetrics;
		}
		public function set scrollMetrics(value:IScrollMetrics):void{
			if(_scrollMetrics!=value){
				if(_scrollMetrics){
					_scrollMetrics.scrollMetricsChanged.removeHandler(onMetricsChanged);
				}
				_scrollMetrics = value;
				if(_scrollMetrics){
					_scrollMetrics.scrollMetricsChanged.addHandler(onMetricsChanged);
				}
			}
		}
		
		public function get interactiveObject():IInteractiveObject{
			return _interactiveObject;
		}
		public function set interactiveObject(value:IInteractiveObject):void{
			if(_interactiveObject!=value){
				if(_interactiveObject){
					_interactiveObject.mousePressed.removeHandler(onMousePressed);
				}
				_interactiveObject = value;
				if(_interactiveObject){
					_interactiveObject.mousePressed.addHandler(onMousePressed);
				}
			}
		}
		
		public var velocityDecceleration:Number = 0.7;
		public var velocityAffectDuration:Number = 0.5;// seconds
		public var vertical:Boolean = true;
		public var dragThreshold:Number = 0;
		
		public var snappingInterval:Number;
		public var snappingInfluence:Number = 2500;
		public var snappingVelThreshold:Number = 5;
		
		private var _interactiveObject:IInteractiveObject;
		private var _scrollMetrics:IScrollMetrics;
		private var _pressedStage:IStage;
		
		private var _pressedScrollValue:Number;
		private var _pressedValue:Number;
		private var _dragging:Boolean;
		private var _dragVelocity:Number;
		private var _snapVelocity:Number;
		private var _ignoreChanges:Boolean;
		private var _lastTime:int;
		
		private var _velocityRecordings:Vector.<Number>;
		private var _velocityRecordingFrames:int;
		
		public function MouseDragScroller(vertical:Boolean=true){
			this.vertical = vertical;
		}
		
		protected function onMousePressed(from:IInteractiveObject, mouseActInfo:IMouseActInfo):void{
			cancelDrag();
			if(_scrollMetrics){
				_pressedStage = _interactiveObject.stage;
				_pressedStage.mouseReleased.addHandler(onMouseReleased);
				EnterFrameHook.getAct().addHandler(doDrag);
				
				_pressedValue = vertical?_pressedStage.mouseY:_pressedStage.mouseX;
				_pressedScrollValue = _scrollMetrics.scrollValue;
			}
		}
		protected function doDrag():void{
			var value:Number = vertical?_pressedStage.mouseY:_pressedStage.mouseX;
			var dif:Number = _pressedValue-value;
			if(!_dragging){
				if((dif<0?-dif:dif)>dragThreshold){
					_dragging = true;
					_velocityRecordingFrames = int(velocityAffectDuration*_pressedStage.frameRate+0.5);
					_velocityRecordings = new Vector.<Number>();
				}
			}
			if(_dragging){
				value = _pressedScrollValue+dif;
				if(value<_scrollMetrics.minimum)value = _scrollMetrics.minimum;
				if(value>_scrollMetrics.maximum)value = _scrollMetrics.maximum;
				
				var newDif:Number = (value - _scrollMetrics.scrollValue);
				_velocityRecordings.unshift(newDif);
				while(_velocityRecordings.length>_velocityRecordingFrames){
					_velocityRecordings.pop();
				}
				
				_ignoreChanges = true;
				_scrollMetrics.scrollValue = value;
				_ignoreChanges = false;
				
			}
		}
		protected function onMouseReleased(from:IInteractiveObject, mouseActInfo:IMouseActInfo):void{
			_pressedStage.mouseReleased.removeHandler(onMouseReleased);
			EnterFrameHook.getAct().removeHandler(doDrag);
			
			if(_dragging){
				_dragVelocity = 0;
				var total:int = 0;
				for(var i:int; i<_velocityRecordings.length; ++i){
					var recording:Number = _velocityRecordings[i];
					_dragVelocity += recording*(_velocityRecordings.length-i);
					total += (_velocityRecordings.length-i);;
				}
				_dragVelocity /= total;
				_snapVelocity = 0;
				
				_dragging = false;
				
				_lastTime = getTimer();
				EnterFrameHook.getAct().addHandler(doVelocity);
			}
		}
		protected function cancelDrag():void{
			if(_pressedStage)_pressedStage.mouseReleased.removeHandler(onMouseReleased);
			EnterFrameHook.getAct().removeHandler(doDrag);
			EnterFrameHook.getAct().removeHandler(doVelocity);
		}
		protected function doVelocity():void{
			var time:int = getTimer();
			var timeStep:Number = (time-_lastTime)/1000;
			_lastTime = time;
			
			var velocity:Number;
			var newScrollValue:Number = _scrollMetrics.scrollValue + _dragVelocity;
			if(!isNaN(snappingInterval) && _dragVelocity<snappingVelThreshold){
				if(newScrollValue<_scrollMetrics.minimum){
					newScrollValue = _scrollMetrics.minimum;
				}else if(newScrollValue>_scrollMetrics.maximum){
					newScrollValue =_scrollMetrics.maximum;
				}
				
				var nearest:Number = int(newScrollValue/snappingInterval+0.5)*snappingInterval;
				var dif:Number = nearest-newScrollValue;
				
				var difFract:Number = dif/(snappingInterval/2);
				_snapVelocity = difFract*snappingInfluence;
				
				var ratio:Number = _dragVelocity/snappingVelThreshold;
				if(ratio<0)ratio = -ratio;
				
				velocity = (_snapVelocity*(1-ratio)*timeStep)+_dragVelocity*ratio;
				newScrollValue = _scrollMetrics.scrollValue+velocity;
			}else{
				velocity = _dragVelocity;
			}
			
			if(newScrollValue<_scrollMetrics.minimum){
				newScrollValue = _scrollMetrics.minimum;
				_dragVelocity = 0;
			}else if(newScrollValue>_scrollMetrics.maximum){
				newScrollValue =_scrollMetrics.maximum;
				_dragVelocity = 0;
			}
			
			_ignoreChanges = true;
			_scrollMetrics.scrollValue = newScrollValue;
			_ignoreChanges = false;
			
			var deccel:Number = 1-(velocityDecceleration*timeStep);
			_dragVelocity *= deccel;
			
			if((velocity<0?-velocity:velocity)<VELOCITY_THESHOLD){
				EnterFrameHook.getAct().removeHandler(doVelocity);
			}
			
			if(_onVelocityScroll)_onVelocityScroll.perform(this);
		}
		
		protected function onMetricsChanged(from:IScrollMetrics):void{
			if(!_ignoreChanges){
				cancelDrag();
			}
		}
	}
}