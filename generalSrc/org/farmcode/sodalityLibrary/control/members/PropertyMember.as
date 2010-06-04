package org.farmcode.sodalityLibrary.control.members
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class PropertyMember extends EventDispatcher implements ISourceMember, IDestinationMember
	{
		public function get value():*{
			return _value;
		}
		public function set value(value:*):void{
			if(_value!=value){
				_value = value;
				dispatchChange();
			}
		}
		
		private var _value:*;
		
		public function PropertyMember(value:*=null){
			super();
			this.value = value;
		}
		
		
		public function dispatchChange():void{
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}