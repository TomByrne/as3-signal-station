package org.tbyrne.queueing
{
	public class QueueItemGroup
	{
		public var threadId:String;
		public var queueItems:Vector.<IQueueItem>;
		
		public function QueueItemGroup(threadId:String, queueItems:Vector.<IQueueItem>)
		{
			this.threadId = threadId;
			this.queueItems = queueItems;
		}
	}
}