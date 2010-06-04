package org.farmcode.sodalityLibrary.control.members
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class ProxyPropertyMember extends EventDispatcher implements ISourceMember, IDestinationMember
	{
		public var subject:Object;
		public var property:String;
		public var autoChangeDispatch: Boolean;
		
		public function ProxyPropertyMember(subject:Object, property:String, autoChangeDispatch: Boolean = false){
			this.subject = subject;
			this.property = property;
			this.autoChangeDispatch = autoChangeDispatch;
		}
		
		public function dispatchChange():void{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get value():*{
			return subject[property];
		}
		public function set value(value:*):void{
			var oldValue: * = this.subject[this.property];
			this.subject[this.property] = value;
			if (this.autoChangeDispatch && (oldValue != this.subject[this.property]))
			{
				this.dispatchChange();
			}
		}
		
	}
}