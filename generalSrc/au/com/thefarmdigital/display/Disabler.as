package au.com.thefarmdigital.display
{
	import au.com.thefarmdigital.tweening.LooseTween;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.goasap.events.GoEvent;

	/**
	 * The Disabler class can deactivate all mouse interaction with a swf (at a particular depth), 
	 * this is useful if a website has modal popup overlays (and isn't using the Flex framework).
	 */
	public class Disabler extends Sprite
	{
		/** The default setting for transition time */
		private static var DEFAULT_TRANSITION_TIME:Number = 1;
		
		/** The colour of the disabler element */
		public function get fillColor():Number{
			return _fillColor;
		}
		public function set fillColor(to:Number):void{
			if(_fillColor!=to){
				_fillColor = to;
				draw();
			}
		}
		/** The alpha of the disabler element. 0 by default */
		public function get fillAlpha():Number{
			return _fillAlpha;
		}
		public function set fillAlpha(to:Number):void{
			if(_fillAlpha!=to){
				_fillAlpha = to;
				draw();
			}
		}
		/** @inheritDoc */
		override public function get x():Number{
			return super.x;
		}
		/** @inheritDoc */
		override public function get y():Number{
			return super.y;
		}
		/** @inheritDoc */
		override public function get visible():Boolean{
			return super.visible;
		}
		/** @inheritDoc */
		override public function get alpha():Number{
			return super.alpha;
		}
		
		/** The amount of time (in seconds) for the disabler to use when displaying */
		public function set transitionTime(transitionTime: Number): void
		{
			this._transitionTime = transitionTime;
		}
		public function get transitionTime(): Number
		{
			return this._transitionTime;
		}
		
		public var easingFunction:Function;
		
		private var _fillColor:Number = 0xffffff;
		private var _fillAlpha:Number = 0;
		private var tween:LooseTween;
		private var _transitionTime: Number;
		
		/**
		 * Creates a disabler element which is transparent by default. The element
		 * will have no effect until the show() method is called.
		 */
		public function Disabler()
		{
			super();
			super.alpha = 0;
			super.visible = false;
			this.buttonMode = true;
			this.useHandCursor = false;
			this.transitionTime = Disabler.DEFAULT_TRANSITION_TIME;
			draw();
		}
		
		/**
		 * Show the disabler and start the blocking functionality. This will
		 * occus with a fade transition.
		 */
		public function show():void{
			this.setVisible(true);
		}
		
		/**
		 * Change the visibility of the disabler including a transition if the disabler 
		 * has a visual representation
		 */
		private function setVisible(visible: Boolean): void
		{
			if (visible != super.visible)
			{
				var targetAlpha: Number = 0;
				if (visible)
				{
					targetAlpha = 1;
					this.addEventListener(Event.ENTER_FRAME, this.handlePositionEnterFrameEvent);
				}
				else
				{
					this.removeEventListener(Event.ENTER_FRAME,this.handlePositionEnterFrameEvent);
				}
				
				var alphaDiff: Boolean = (targetAlpha != this.alpha);
				if (alphaDiff)
				{
					if (_fillAlpha)
					{
						super.visible = true;
						//tween = new MultiTween(super, ["alpha"], Regular.easeInOut, [super.alpha], [targetAlpha], this.transitionTime,true);
						//tween.addEventListener(MultiTweenEvent.MOTION_FINISH,onMotionFinish);
						tween = new LooseTween(super,{alpha:targetAlpha},easingFunction,transitionTime);
						tween.addEventListener(GoEvent.COMPLETE,onMotionFinish);
						tween.start();
					}else{
						super.alpha = targetAlpha;
					}
				}
				
				// Set visible if the instruction was to make visible or if transitioning to invisible
				super.visible = (targetAlpha == 1) || (targetAlpha != this.alpha);
			}
		}
		
		/**
		 * Hide the disabler visually and stop the blocking functionality. This will
		 * occus with a fade transition.
		 */
		public function hide():void{
			this.setVisible(false);
		}
		
		/**
		 * Handles the finishing of a transition in or out for the disabler
		 * 
		 * @param e		Details of the tween event
		 */
		private function onMotionFinish(e:GoEvent):void{
			if(!this.alpha){
				super.visible = false;
			}
		}
		/**
		 * Builds the physical area for the disabler
		 */
		private function draw():void{
			graphics.clear()
			graphics.beginFill(_fillColor,_fillAlpha);
			graphics.drawRect(0,0,10,10);
			updatePosition();
		}
		
		/**
		 * Handles the enter frame event for the disabler. Repositions the disabler
		 * to be aligned with the stage
		 * 
		 * @param	event	Details of the event
		 */
		private function handlePositionEnterFrameEvent(event: Event): void
		{
			this.updatePosition();
		}
		
		/**
		 * Positions the disabler to the stage
		 */
		private function updatePosition():void{
			if(stage){
				width = stage.stageWidth;
				height = stage.stageHeight;
				var point:Point = parent.globalToLocal(new Point(0,0));
				x = point.x;
				y = point.y;
			}
		}
	}
}