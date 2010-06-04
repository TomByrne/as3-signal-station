package org.farmcode.display
{
	import au.com.thefarmdigital.tweening.LooseTween;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.farmcode.actLibrary.display.popup.IModalDisablerView;
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.behaviour.ViewBehaviour;
	import org.goasap.events.GoEvent;
	import org.farmcode.flags.ValidationFlag;
	
	public class DisablerView extends ViewBehaviour implements IModalDisablerView
	{
		/** The default setting for transition time */
		private static var DEFAULT_TRANSITION_TIME:Number = 0.3;
		
		
		/** The colour of the disabler element */
		public function get fillColour():Number{
			return _fillColour;
		}
		public function set fillColour(to:Number):void{
			if(_fillColour!=to){
				_fillColour = to;
				_drawingFlag.invalidate();
				invalidate();
			}
		}
		/** The alpha of the disabler element. 0 by default */
		public function get fillAlpha():Number{
			return _fillAlpha;
		}
		public function set fillAlpha(to:Number):void{
			if(_fillAlpha!=to){
				_fillAlpha = to;
				_drawingFlag.invalidate();
				invalidate();
			}
		}
		
		/** The amount of time (in seconds) for the disabler to use when displaying */
		public var transitionTime:Number;
		/** The easing used to fade the disabler in/out */
		public var easingFunction:Function;
		
		private var _fillColour:Number = 0xffffff;
		private var _fillAlpha:Number = 0;
		private var _tween:LooseTween;
		private var _box:Sprite = new Sprite();
		private var _visible:Boolean;
		
		private var _drawingFlag:ValidationFlag = new ValidationFlag(drawBox,false);
		private var _positioningFlag:ValidationFlag = new ValidationFlag(positionBox,false);
		
		
		
		public function DisablerView(fillColor:Number=NaN, fillAlpha:Number=NaN){
			super(new Sprite());
			
			this.transitionTime = DisablerView.DEFAULT_TRANSITION_TIME;
			this.fillColour = fillColor;
			this.fillAlpha = fillAlpha;
			
			_box.alpha = 0;
			_box.visible = false;
			_box.buttonMode = true;
			_box.useHandCursor = false;
		}
		
		/**
		 * Creates a disabler element which is transparent by default. The element
		 * will have no effect until the show() method is called.
		 */
		override protected function bindToAsset():void{
			super.bindToAsset();
			containerAsset.addChild(_box);
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			containerAsset.removeChild(_box);
		}
		override protected function draw() : void{
			super.draw();
			_drawingFlag.validate();
			_positioningFlag.validate();
		}
		
		override protected function doShowOutro():Number{
			super.doShowOutro();
			return this.setVisible(false);
		}
		override protected function doShowIntro():void{
			super.doShowIntro();
			this.setVisible(true);
		}
		
		
		/**
		 * Change the visibility of the disabler including a transition if the disabler 
		 * has a visual representation
		 */
		private function setVisible(visible: Boolean): Number{
			if (visible != _visible){
				_visible = visible;
				if(_tween){
					_tween.stop();
					_tween.removeEventListener(GoEvent.COMPLETE,onMotionFinish);
					_tween = null;
				}
				var targetAlpha: Number = visible?1:0;
				var alphaDiff: Boolean = (targetAlpha != _box.alpha);
				if (alphaDiff){
					if (_fillAlpha){
						_tween = new LooseTween(_box,{alpha:targetAlpha},easingFunction,transitionTime);
						if(!visible){
							_tween.addEventListener(GoEvent.COMPLETE,onMotionFinish);
						}
						_tween.start();
						_box.visible = true;
						return transitionTime;
					}else{
						_box.alpha = targetAlpha;
						_box.visible = visible;
					}
				}
			}
			return 0;
		}
		/**
		 * Handles the finishing of a transition in or out for the disabler
		 * 
		 * @param e		Details of the tween event
		 */
		private function onMotionFinish(e:GoEvent):void{
			_box.visible = false;
		}
		
		override protected function onAddedToStage(e:Event):void{
			super.onAddedToStage(e);
			asset.stage.addEventListener(Event.RESIZE, onStageResize);
		}
		override protected function onRemovedFromStage(e:Event):void{
			super.onRemovedFromStage(e);
			asset.stage.removeEventListener(Event.RESIZE, onStageResize);
		}
		protected function onStageResize(e:Event):void{
			_positioningFlag.validate(true);
		}
		
		
		/**
		 * Builds the physical area for the disabler
		 */
		private function drawBox():void{
			_box.graphics.clear()
			_box.graphics.beginFill(_fillColour,_fillAlpha);
			_box.graphics.drawRect(0,0,10,10);
		}
		/**
		 * Positions the disabler to the stage
		 */
		private function positionBox():void{
			if(asset.stage){
				_box.width = asset.stage.stageWidth;
				_box.height = asset.stage.stageHeight;
				var point:Point = asset.globalToLocal(new Point(0,0));
				_box.x = point.x;
				_box.y = point.y;
			}
		}
		public function surfaceDisabler():void{
			asset.parent.setChildIndex(asset,asset.parent.numChildren-1);
		}
		public function addDisabler(parent:DisplayObjectContainer):void{
			parent.addChild(asset);
		}
		public function removeDisabler():Number{
			var ret:Number = showOutro();
			var delay:DelayedCall = new DelayedCall(finishRemoveDisabler,ret,true);
			delay.begin();
			return ret;
		}
		protected function finishRemoveDisabler():void{
			asset.parent.removeChild(asset);
		}
	}
}