package org.farmcode.sodalityPlatformEngine.states
{
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="change", type="flash.events.Event")]
	internal class StatefulProperty extends EventDispatcher
	{
		private var activeAdvice: Array;
		private var _active: Boolean;
		private var _mutable: Boolean;
		public var id: String;
		
		public function StatefulProperty(id: String, mutable: Boolean = true, initalActive: Boolean = true)
		{
			this.activeAdvice = new Array();
			this.id = id;
			this._mutable = mutable;
			this._active = initalActive;
		}
		
		public function get mutable(): Boolean
		{
			return this._mutable;
		}
		
		public function set active(value: Boolean): void
		{
			if (this._mutable && value != this.active)
			{
				this._active = value;
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		public function get active(): Boolean
		{
			return this._active;
		}
		
		public function addActiveAdvice(advice: IAdvice): void
		{
			this.activeAdvice.push(advice);
		}
		
		public function hasActiveAdvice(advice: IAdvice): Boolean
		{
			return this.activeAdvice.indexOf(advice) >= 0;
		}
		
		public function removeActiveAdvice(advice: IAdvice): void
		{
			var aIndex: int = this.activeAdvice.indexOf(advice);
			if (aIndex >= 0)
			{
				this.activeAdvice.splice(aIndex, 1);
			}
		}
		
		override public function toString(): String
		{
			return "[StatefulProperty id:" + this.id + ", active:" + this.active + ", mutable:" + this.mutable + "]";
		}
	}
}