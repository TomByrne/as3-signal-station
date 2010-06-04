package au.com.thefarmdigital.display
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.farmcode.core.DelayedCall;
	
	[Event(type="flash.events.Event", name="change")]
	public class MouseOverTracker extends EventDispatcher
	{
		protected var _target: DisplayObject;
		protected var _over: Boolean;
		protected var _interval: Number;
		protected var _useSecs: Boolean;
		protected var _enabled: Boolean;
		protected var checker: DelayedCall;
		protected var _useShape: Boolean;
		
		public function MouseOverTracker(target: DisplayObject = null, useSecs: Boolean = false, interval: Number = 1)
		{
			this._enabled = false;
			this._over = false;
			
			this.useShape = false;
			this.useSecs = useSecs;
			this.interval = interval;
			this.target = target;
			this.enabled = true;
		}
		
		public function set useShape(useShape: Boolean): void
		{
			if (this._useShape != useShape)
			{
				this._useShape = useShape;
			}
		}
		public function get useShape(): Boolean
		{
			return this._useShape;
		}
		
		public function get enabled(): Boolean
		{
			return this._enabled;
		}
		public function set enabled(enabled: Boolean): void
		{
			if (enabled != this._enabled)
			{
				this._enabled = enabled;
				this.updateChecker();
			}
		}
		
		protected function checkOver(fireEvent: Boolean = true): void
		{
			if (this.target && this.target.stage)
			{
				var newOver: Boolean = 
					this.target.hitTestPoint(this.target.stage.mouseX, this.target.stage.mouseY, this.useShape);
				if (newOver != this._over)
				{
					this._over = newOver;
					if (fireEvent)
					{
						this.dispatchEvent(new Event(Event.CHANGE));
					}
				}
			}
		}
		
		public function set target(target: DisplayObject): void
		{
			if (target != this._target)
			{
				this._target = target;
				this.checkOver(false);
			}
		}
		public function get target(): DisplayObject
		{
			return this._target;
		}
		
		protected function updateChecker(): void
		{
			if (this.checker != null)
			{
				this.checker.clear();
				this.checker = null;
			}
			if (this.enabled)
			{
				var callInterval: Number = this.interval;
				if (this.useSecs)
				{
					callInterval = this.interval / 1000;
				}
				this.checker = new DelayedCall(this.checkOver, callInterval, this.useSecs, null, 0);
				checker.begin();
			}
		}
		
		public function set interval(interval: Number): void
		{
			if (interval != this._interval)
			{
				this._interval = interval;
				this.updateChecker();
			}
		}
		public function get interval(): Number
		{
			return this._interval;
		}
		
		public function set useSecs(useSecs: Boolean): void
		{
			if (useSecs != this._useSecs)
			{
				this._useSecs = useSecs;
				this.updateChecker();
			}
		}
		public function get useSecs(): Boolean
		{
			return this._useSecs;
		}
		
		public function get isOver(): Boolean
		{
			return this._over;
		}
	}
}