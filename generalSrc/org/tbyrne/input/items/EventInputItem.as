package org.tbyrne.input.items
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.debug.logging.Log;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.input.menu.IMenuInputItem;
	import org.tbyrne.input.shortcuts.IShortcutInputItem;

	public class EventInputItem extends AbstractInputItem implements ITriggerableAction, IShortcutInputItem, IMenuInputItem
	{
		
		public function get event():Event{
			return _event;
		}
		public function set event(value:Event):void{
			_event = value;
		}
		
		public function get eventDispatcher():IEventDispatcher{
			return _eventDispatcher;
		}
		public function set eventDispatcher(value:IEventDispatcher):void{
			_eventDispatcher = value;
		}
		
		private var _eventDispatcher:IEventDispatcher;
		private var _event:Event;
		
		public function EventInputItem(stringProvider:IStringProvider=null, event:Event=null, eventDispatcher:IEventDispatcher=null){
			super(stringProvider);
			this.event = event;
			this.eventDispatcher = eventDispatcher;
		}
		
		override public function triggerAction(scopeDisplay:IDisplayAsset):void{
			if(!_event){
				Log.log(Log.SUSPICIOUS_IMPLEMENTATION,"no Event associated with EventNavItem");
			}else if(!_eventDispatcher){
				Log.log(Log.SUSPICIOUS_IMPLEMENTATION,"no IEventDispatcher associated with EventNavItem");
			}else{
				_eventDispatcher.dispatchEvent(_event);
			}
		}
	}
}