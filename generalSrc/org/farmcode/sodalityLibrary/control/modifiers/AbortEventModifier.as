package org.farmcode.sodalityLibrary.control.modifiers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;

	public class AbortEventModifier extends EventDispatcher implements IValueModifier
	{
		public var abortFilter:Function;
		
		public function AbortEventModifier(abortFilter:Function=null){
			this.abortFilter = abortFilter;
		}

		public function input(value:*, oldValue:*):*{
			if(abortFilter==null || abortFilter(value,oldValue)){
				var event:Event = (value as Event);
				event.stopImmediatePropagation();
				return null;
			}
			return value;
		}
		
	}
}