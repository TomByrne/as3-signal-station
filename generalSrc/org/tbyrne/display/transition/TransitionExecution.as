package org.tbyrne.display.transition
{
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.nativeTypes.IBitmap;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeAssets.NativeAsset;
	import org.tbyrne.display.assets.utils.isDescendant;
	
	/**
	 * The TransitionExecution class takes two DisplayObjects and transitions between them.
	 */
	public class TransitionExecution
	{
		private static const MAX_WIDTH: uint = 2880;
		private static const MAX_HEIGHT: uint = 2880;
		
		
		/**
		 * handler(from:TransitionExecution)
		 */
		public function get transitionBegin():IAct{
			if(!_transitionBegin)_transitionBegin = new Act();
			return _transitionBegin;
		}
		
		/**
		 * handler(from:TransitionExecution)
		 */
		public function get transitionChange():IAct{
			if(!_transitionChange)_transitionChange = new Act();
			return _transitionChange;
		}
		
		/**
		 * handler(from:TransitionExecution)
		 */
		public function get transitionEnd():IAct{
			if(!_transitionEnd)_transitionEnd = new Act();
			return _transitionEnd;
		}
		
		
		/**
		 * The easing function should be any of the easing functions normally used for tweening.
		 * It will control the pace at which the transitions will be applied.
		 */
		public function set easing(value:Function):void{
			if(_easing!=value){
				_easing = value;
			}
		}
		public function get easing():Function{
			return _easing;
		}
		/**
		 * The existing DisplayObject that the transition will transition from.
		 */
		public function set startDisplay(value:IDisplayObject):void{
			_startDisplay = value;
		}
		public function get startDisplay():IDisplayObject{
			return _startDisplay;
		}
		/**
		 * The new DisplayObject that the transition will transition to.
		 */
		public function set finishDisplay(value:IDisplayObject):void{
			_finishDisplay = value;
		}
		public function get finishDisplay():IDisplayObject{
			return _finishDisplay;
		}
		/**
		 * Whether.
		 */
		public function set smoothing(value:Boolean):void{
			if(_smoothing!=value){
				_smoothing = value;
			}
		}
		public function get smoothing():Boolean{
			return _smoothing;
		}
		public function get time():Number{
			return _time;
		}
		public function get duration():Number{
			return _duration;
		}
		
		private var _time:Number = 0;
		private var _duration:Number;
		private var _smoothing:Boolean = true;
		private var _transitions:Array;
		private var _timedTransitions:Array;
		private var _easing:Function;
		private var _startDisplay:IDisplayObject;
		private var _finishDisplay:IDisplayObject;
		private var _renderArea:IBitmap;
		
		// these are caches for transition itself
		private var parent:IDisplayObjectContainer;
		private var startTime:Number;
		private var bounds:Rectangle;
		
		protected var _transitionEnd:Act;
		protected var _transitionChange:Act;
		protected var _transitionBegin:Act;
		
		public function TransitionExecution(transitions:Array){
			_transitions = transitions;
		}
		public function execute():void{
			//onEnd(true);
			var depth:Number;
			if(_finishDisplay.parent){
				parent = _finishDisplay.parent;
				depth = parent.getAssetIndex(_finishDisplay)+1;
			}else{
				parent = _startDisplay.parent;
				depth = parent.getAssetIndex(_startDisplay)+1;
			}
			
			if(parent && parent.stage){
				var topLeft:Point = parent.globalToLocal(new Point(0,0));
				var bottomRight:Point = parent.globalToLocal(new Point(parent.stage.stageWidth, parent.stage.stageHeight));
				
				hiddenAdd(_startDisplay, parent, depth-1); // this hides the start display. Do this before getting bounds in case they draw themselves on adding.
				hiddenAdd(_finishDisplay, parent, depth-1);
				
				var startBounds:Rectangle = getBounds(_startDisplay,parent);
				startTime = getTimer();
				parent.enterFrame.addHandler(doFrame);
				bounds = startBounds.union(getBounds(_finishDisplay,parent));
				bounds.x = int(Math.max(bounds.x,topLeft.x));
				bounds.y = int(Math.max(bounds.y,topLeft.y));
				bounds.width = Math.ceil(Math.min(MAX_WIDTH,bounds.width,bottomRight.x));
				bounds.height = Math.ceil(Math.min(MAX_HEIGHT,bounds.height,bottomRight.y));
				var bitmapData:BitmapData = new BitmapData(Math.max(bounds.width,1),Math.max(bounds.height,1),true,0);
				//_renderArea = new Bitmap(bitmapData,PixelSnapping.NEVER,smoothing);
				_renderArea = _startDisplay.factory.createBitmap();
				_renderArea.bitmapPixelSnapping = PixelSnapping.NEVER;
				_renderArea.smoothing = smoothing;
				_renderArea.setPosition(bounds.x,bounds.y);
				parent.addAssetAt(_renderArea,depth);
				var timingGroup:TimingGroup;
				_timedTransitions = [];
				for each(var trans:ITransition in _transitions){
					trans.beginTransition(_startDisplay,_finishDisplay,_renderArea,_duration);
					if(!timingGroup || trans.timing==TransitionTiming.CONSECUTIVE){
						var timeBefore:Number = 0;
						if(timingGroup)timeBefore = timingGroup.timeBefore+timingGroup.duration;
						timingGroup = new TimingGroup();
						timingGroup.timeBefore = timeBefore;
						_timedTransitions.push(timingGroup);
					}
					timingGroup.transitions.push(trans);
					timingGroup.duration = Math.max(timingGroup.duration,trans.duration);
				}
				_duration = timingGroup?timingGroup.timeBefore+timingGroup.duration:0;
				
				var matrix:Matrix = _startDisplay.transform.matrix.clone();
				matrix.tx = startBounds.x-_renderArea.x;
				matrix.ty = startBounds.y-_renderArea.y;
				bitmapData.draw(_startDisplay.bitmapDrawable,matrix,_startDisplay.transform.colorTransform,_startDisplay.blendMode);
				
				if(_transitionBegin)_transitionBegin.perform(this);
			}
		}
		protected function getBounds(subject:IDisplayObject, parent:IDisplayObject):Rectangle{
			if(!subject.parent){
				parent = subject;
			}
			var ret:Rectangle;
			if(!subject.width || !subject.height){
				var point:Point = parent.globalToLocal(subject.localToGlobal(new Point()));
				ret = new Rectangle(point.x,point.y,0,0);
			}else{
				ret = subject.getBounds(parent);
				if(ret.x>=6710886)ret.x = 0;
				if(ret.y>=6710886)ret.y = 0;
			}
			if(!subject.parent){
				ret.x += subject.x;
				ret.y += subject.y;
			}
			return ret;
		}
		private function hiddenAdd(child:IDisplayObject, parent:IDisplayObjectContainer, depth:int):void{
			child.visible = false;
			if(parent!=child.parent){
				if(child.parent){
					if(isDescendant(child.parent,parent))return;
					var point:Point = parent.globalToLocal(child.localToGlobal(new Point()));
					child.parent.removeAsset(child);
					child.setPosition(point.x,point.y);
				}
				parent.addAssetAt(child,depth);
			}
		}
		private function doFrame(e:Event, from:NativeAsset):void{
			_renderArea.bitmapData.lock()
			if(parent.stage==parent){
				_renderArea.visible = false;
			}
			_time = getTimer()-startTime;
			var easedTime:Number = (easing!=null)?easing(_time,0,_duration,_duration):_time;
			var currentGroup:TimingGroup = _timedTransitions[0];
			if(currentGroup){
				// first clear the render area
				_renderArea.bitmapData.fillRect(new Rectangle(0,0,_renderArea.bitmapData.width,_renderArea.bitmapData.height),0);
				for each(var trans:ITransition in currentGroup.transitions){
					trans.doTransition(_startDisplay,_finishDisplay,_renderArea,currentGroup.duration,Math.min(easedTime-currentGroup.timeBefore,currentGroup.duration));
				}
			}
			_renderArea.bitmapData.unlock()
			if(parent.stage==parent){
				_renderArea.visible = true;
			}
			if(_transitionChange)_transitionChange.perform(this);
			if(_time>=_duration){
				for each(trans in _transitions){
					trans.endTransition(_startDisplay,_finishDisplay,_renderArea,_duration);
				}
				_finishDisplay.visible = true;
				onEnd(true);
				if(_transitionEnd)_transitionEnd.perform(this);
			}else if(easedTime>currentGroup.timeBefore+currentGroup.duration){
				_timedTransitions.splice(0,1);
				currentGroup = _timedTransitions[0];
				for each(trans in currentGroup.transitions){
					trans.doTransition(_startDisplay,_finishDisplay,_renderArea,currentGroup.duration,Math.min(easedTime-currentGroup.timeBefore,currentGroup.duration));
				}
				_renderArea.bitmapData.fillRect(new Rectangle(0,0,1000,1000),0xffff0000);
			}
		}
		internal function endEarly():IBitmap{
			onEnd(false);
			if(_transitionEnd)_transitionEnd.perform(this);
			return _renderArea;
		}
		private function onEnd(removeRender:Boolean):void{
			if(parent){
				parent.enterFrame.removeHandler(doFrame);
				parent = null;
			}
			if(removeRender && _renderArea){
				_renderArea.parent.removeAsset(_renderArea);
				_renderArea.bitmapData.dispose();
				_renderArea = null;
			}
			if(_finishDisplay!=_startDisplay){
				_startDisplay.parent.removeAsset(_startDisplay);
			}
			_time = 0;
			startTime = NaN;
			bounds = null;
		}
	}
}
class TimingGroup{
	public var timeBefore:Number = 0;
	public var duration:Number = 0;
	public var transitions:Array = [];
}