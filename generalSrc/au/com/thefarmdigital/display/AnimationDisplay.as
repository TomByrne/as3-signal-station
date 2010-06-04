package au.com.thefarmdigital.display
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	[Event(type="flash.events.Event", name="change")]
	[Event(type="flash.events.Event", name="complete")]
	public class AnimationDisplay extends MovieClip
	{
		protected static const FORWARD: int = 1;
		protected static const REVERSE: int = -1;
		
		protected var _target: MovieClip;
		protected var _shown: Boolean;
		protected var _direction: int;
		protected var _running: Boolean;
		private var _invisibleOnHidden: Boolean;
		
		public function AnimationDisplay(target: MovieClip = null)
		{
			super();
			
			this._invisibleOnHidden = true;
			this._running = false;
			this._shown = false;
			
			this.target = target;
			this.shown = true;
		}
		
		public function set invisibleOnHidden(invisibleOnHidden: Boolean): void
		{
			if (invisibleOnHidden != this._invisibleOnHidden)
			{
				this._invisibleOnHidden = invisibleOnHidden;
				this.applyVisible();
			}
		}
		
		public function get direction(): int
		{
			return this._direction;
		}
		
		public function set target(target: MovieClip): void
		{
			if (this._target != null)
			{
				this.updateRunListeners(false);
			}
			
			if (target == null){
				this._target = this;
			}else{
				this._target = target;
			}
			this._target.stop();
			this.updateRunListeners();
		}
		public function get target(): MovieClip
		{
			return this._target;
		}
		
		public function set shown(shown: Boolean): void
		{
			if (shown != this._shown)
			{
				this._shown = shown;
				if (this._shown)
				{
					this._direction = AnimationDisplay.FORWARD;
				}
				else
				{
					this._direction = AnimationDisplay.REVERSE;
				}
				this.running = true;
			}
		}
		public function get shown(): Boolean
		{
			return this._shown;
		}
		
		protected function applyVisible(): void
		{
			if (!this._invisibleOnHidden || this._running)
			{
				setTargetProp("visible",true);
			}
			else
			{
				setTargetProp("visible",_shown);
			}
		}
		
		protected function set running(running: Boolean): void
		{
			if (running != this._running)
			{
				this._running = running;
				this.updateRunListeners();
				this.applyVisible();
			}
		}
		public function get animationRunning(): Boolean
		{
			return this._running;
		}
		
		protected function updateRunListeners(useRunning: Boolean = false): void
		{
			if (arguments.length == 0)
			{
				useRunning = this._running;
			}
			if (useRunning)
			{
				this.target.addEventListener(Event.ENTER_FRAME, this.handleFrameMoveEvent);
			}
			else
			{
				this.target.removeEventListener(Event.ENTER_FRAME, this.handleFrameMoveEvent);
			}
		}
		
		protected function handleFrameMoveEvent(event: Event): void
		{
			this.stepAnimation();
		}
		
		override public function get currentFrame():int
		{
			return this.getTargetProp("currentFrame");
		}
		
		override public function get totalFrames():int
		{
			return this.getTargetProp("totalFrames");
		}
		
		protected function getTargetProp(propName: String): *
		{
			var value: *;
			if (this.target == this)
			{
				value = super[propName];
			}
			else
			{
				value = this.target[propName];
			}
			return value;
		}
		protected function setTargetProp(propName: String, value:*):void{
			if (this.target == this){
				super[propName] = value;
			}else{
				this.target[propName] = value;
			}
		}
		
		protected function stepAnimation(): void
		{
			if ((this._direction == AnimationDisplay.FORWARD && this.currentFrame == this.totalFrames) ||
				(this._direction == AnimationDisplay.REVERSE && this.currentFrame == 1))
			{
				this.running = false;
				
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				this.target.gotoAndStop(this.target.currentFrame + this._direction);
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
	}
}