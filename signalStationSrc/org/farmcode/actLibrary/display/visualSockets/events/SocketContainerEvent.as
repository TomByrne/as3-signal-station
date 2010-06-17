package org.farmcode.actLibrary.display.visualSockets.events
{
	import flash.events.Event;
	
	import org.farmcode.actLibrary.display.visualSockets.socketContainers.ISocketContainer;
	
	public class SocketContainerEvent extends Event
	{
		public static const SOCKET_CONTAINER_ADDED:String = "socketContainerAdded";
		public static const SOCKET_CONTAINER_REMOVED:String = "socketContainerRemoved";
		public static const SOCKETS_CHANGED:String = "socketsChanged";
		
		public var socketContainer:ISocketContainer;
		
		public function SocketContainerEvent(type:String, socketContainer:ISocketContainer, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.socketContainer = socketContainer;
		}
		override public function clone() : Event{
			return new SocketContainerEvent(type, socketContainer, bubbles, cancelable);
		}
	}
}