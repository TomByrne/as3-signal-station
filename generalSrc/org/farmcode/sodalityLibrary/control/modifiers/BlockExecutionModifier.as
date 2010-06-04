package org.farmcode.sodalityLibrary.control.modifiers
{
	import org.farmcode.sodalityLibrary.control.members.ProxyPropertyMember;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class BlockExecutionModifier extends EventDispatcher implements IValueModifier
	{
		public var property:ProxyPropertyMember;
		public var invert:Boolean;
		
		public function BlockExecutionModifier(property:ProxyPropertyMember,invert:Boolean=false){
			this.property = property;
			this.invert = invert;
		}

		public function input(value:*, oldValue:*):*{
			if(property){
				var cont:Boolean = (property.value);
				if((!cont && !invert) || (cont && invert)){
					dispatchEvent(new Event(Event.CANCEL));
				}
			}
			return value;
		}
	}
}