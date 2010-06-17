package org.farmcode.actLibrary.display.visualSockets.mappers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.farmcode.actLibrary.display.visualSockets.plugs.IPlugDisplay;

	[Event(name="complete", type="flash.events.Event")]
	public class DisplayCreationResult extends EventDispatcher
	{
		private var _complete: Boolean;
		private var _result: IPlugDisplay;
		private var _data:*;
		
		public function DisplayCreationResult()
		{
			this._complete = false;
		}
		
		[Property(toString="true", clonable="true")]
		public function get result(): IPlugDisplay
		{
			return this._result;
		}
		public function set result(value: IPlugDisplay): void
		{
			this._result = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get complete(): Boolean
		{
			return this._complete;
		}
		public function set complete(value: Boolean): void
		{
			if (value != this.complete)
			{
				this._complete = value;
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		[Property(toString="true", clonable="true")]
		public function get data(): *
		{
			return this._data;
		}
		public function set data(value: *): void
		{
			_data = value;
		}
	}
}