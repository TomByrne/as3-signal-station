package org.tbyrne.acting.acts
{
	import flash.utils.Dictionary;

	public class HandlerRemovalTracker
	{
		public function get checkRemove():Boolean{
			return removeAll || removeHandlerCount;
		}
		
		
		
		public var removeAll:Boolean;
		public var removeHandlers:Dictionary;
		public var removeHandlerCount:int = 0;
		
		public function HandlerRemovalTracker()
		{
		}
		
		public function addRemove(handler:Function):void{
			if(!removeHandlers){
				removeHandlers = new Dictionary();
			}
			if(!removeHandlers[handler]){
				removeHandlers[handler] = true;
				removeHandlerCount++;
			}
		}
		public function deleteRemove(handler:Function):void{
			if(!removeHandlers)return;
			if(removeHandlers[handler]){
				delete removeHandlers[handler];
				removeHandlerCount--;
			}
		}
		public function clear():void{
			removeAll = false;
			removeHandlers = null;
			removeHandlerCount = 0;
		}
	}
}