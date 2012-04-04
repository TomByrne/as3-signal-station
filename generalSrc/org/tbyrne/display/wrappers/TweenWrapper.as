package org.tbyrne.display.wrappers
{
	import caurina.transitions.Equations;
	import caurina.transitions.Tweener;
	
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.display.layout.ProxyLayoutSubject;
	
	public class TweenWrapper extends ProxyLayoutSubject
	{
		public static const DEFAULT_TWEEN_EASING:Function = Equations.easeInOutCubic;
		public static const DEFAULT_TWEEN_DURATION:Number = 0.3;
		
		
		public var tweenEasing:* = DEFAULT_TWEEN_EASING;
		public var tweenDuration:Number = DEFAULT_TWEEN_DURATION;
		/**
		 * Amount that pos/size can be changed without invoking a tween 
		 */
		public var tweenThreshold:Number;
		/**
		 *Whether changes on the x axis (i.e. x or width) should invoke a tween 
		 */
		public var doTweenX:Boolean;
		/**
		 *Whether changes on the y axis (i.e. y or height) should invoke a tween 
		 */
		public var doTweenY:Boolean;
		
		
		protected var _tweening:Boolean;
		protected var _measInvalidWhileTweening:Boolean;
		
		
		public function TweenWrapper(target:ILayoutSubject=null, scopeView:IView=null, doTweenX:Boolean=true, doTweenY:Boolean=true, tweenThreshold:Number=NaN){
			super(target);
			if(scopeView)setScopeView(scopeView); // conditional ensures we aren't replacing the ILayoutSubject as scopeView
			this.doTweenX = doTweenX;
			this.doTweenY = doTweenY;
			this.tweenThreshold = tweenThreshold;
		}
		override public function setSize(width:Number, height:Number):void{
			Tweener.removeTweens(_size);
			var tweenX:Boolean = (tweenX && Math.abs(_size.x-width)>tweenThreshold);
			var tweenY:Boolean = (doTweenY && Math.abs(_size.y-height)>tweenThreshold);
			if(tweenX){
				_tweening = true;
				if(tweenY){
					super.setSize(_size.x,height);
					Tweener.addTween(_size,{x:width,transition:tweenEasing,time:tweenDuration,onUpdate:onSizeTweenUpdate,onComplete:onTweenFinished});
				}else{
					Tweener.addTween(_size,{x:width,y:height,transition:tweenEasing,time:tweenDuration,onUpdate:onSizeTweenUpdate,onComplete:onTweenFinished});
				}
			}else if(tweenY){
				_tweening = true;
				super.setSize(width,_size.y);
				Tweener.addTween(_size,{y:height,transition:tweenEasing,time:tweenDuration,onUpdate:onSizeTweenUpdate,onComplete:onTweenFinished});
			}else{
				super.setSize(width,height);
			}
		}
		protected function onSizeTweenUpdate():void{
			validateSize(true);
		}
		override public function setPosition(x:Number, y:Number):void{
			Tweener.removeTweens(_position);
			var tweenX:Boolean = (doTweenX && Math.abs(_position.x-x)>tweenThreshold);
			var tweenY:Boolean = (doTweenY && Math.abs(_position.y-y)>tweenThreshold);
			if(tweenX){
				_tweening = true;
				if(tweenY){
					super.setPosition(_position.x,y);
					Tweener.addTween(_position,{x:x,transition:tweenEasing,time:tweenDuration,onUpdate:onPosTweenUpdate,onComplete:onTweenFinished});
				}else{
					Tweener.addTween(_position,{x:x,y:y,transition:tweenEasing,time:tweenDuration,onUpdate:onPosTweenUpdate,onComplete:onTweenFinished});
				}
			}else if(tweenY){
				_tweening = true;
				super.setPosition(x,_position.y);
				Tweener.addTween(_position,{y:y,transition:tweenEasing,time:tweenDuration,onUpdate:onPosTweenUpdate,onComplete:onTweenFinished});
			}else{
				super.setPosition(x,y);
			}
		}
		protected function onPosTweenUpdate():void{
			validatePos(true);
		}
		protected function onTweenFinished():void{
			_tweening = false;
			if(_measInvalidWhileTweening){
				_measInvalidWhileTweening = false;
				invalidateMeasurements();
			}
		}
		override protected function onMeasurementsChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			if(_tweening){
				_measInvalidWhileTweening = true;
			}else{
				super.onMeasurementsChanged(from, oldWidth, oldHeight);
			}
		}
	}
}