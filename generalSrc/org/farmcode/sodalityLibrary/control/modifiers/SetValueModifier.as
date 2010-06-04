package org.farmcode.sodalityLibrary.control.modifiers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class SetValueModifier extends EventDispatcher implements IValueModifier
	{
		protected var _newValue: *;
		
		public function SetValueModifier(newValue: * = null)
		{
			this.newValue = newValue;
		}
		
		public function set newValue(newValue: *): void
		{
			this._newValue = newValue;
		}
		public function get newValue(): *
		{
			return this._newValue;
		} 

		public function input(value:*, oldValue:*):*
		{
			return this.newValue;
		}
	}
}