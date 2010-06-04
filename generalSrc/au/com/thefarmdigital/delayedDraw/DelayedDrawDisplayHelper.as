package au.com.thefarmdigital.delayedDraw
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class DelayedDrawDisplayHelper extends EventDispatcher
	{
		private var _target: IDrawable;
		
		private var _initialised: Boolean;
		private var _initialising: Boolean;
		
		public function DelayedDrawDisplayHelper(target: IDrawable)
		{
			this._target = target;
		}
		
		public function start(): void
		{
			if(this.targetDisplay.stage){
				onAdded();
			}else{
				this.targetDisplay.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			}
			invalidate();
		}
		
		protected function get targetDisplay(): DisplayObject
		{
			return this.target.drawDisplay;
		}
		
		public function get target(): IDrawable
		{
			return this._target;
		}
		
		public function get initialised(): Boolean
		{
			return this._initialised;
		}
		
		private function onAdded(e:Event=null):void{
			if(e)this.targetDisplay.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			validate();
			this.targetDisplay.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			this.targetDisplay.addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}
		
		private function onRemoved(e:Event):void{
			this.targetDisplay.addEventListener(Event.ADDED_TO_STAGE,onAdded);
			this.targetDisplay.removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			DelayedDrawer.removeDrawable(this.target);
		}
		
		public function ensureInitialised(): void
		{
			if (!this._initialised && !this._initialising)
			{
				this._initialising = true;
				this.dispatchEvent(new Event(Event.INIT));
				this._initialising = false;
				this._initialised = true;
			}
		}
		
		public function invalidate(): void
		{
			DelayedDrawer.changeValidity(this.target, false);
		}
		
		public function validate(forceDraw: Boolean = false): void
		{
			if(forceDraw)invalidate();
			DelayedDrawer.doDraw(this.target);
		}
	}
}