package org.farmcode.queueing
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IQueue
	{
		function addQueueItem(queueItem:IQueueItem, prioritise:Boolean=false):void;
		function removeQueueItem(queueItem:IQueueItem):void;
		
		function clearQueue():void;
		function destroy():void;
		
		/**
		 * handler(from:IQueue)
		 */
		function get queueBegin():IAct;
		/**
		 * handler(from:IQueue)
		 */
		function get queueEnd():IAct;
	}
}