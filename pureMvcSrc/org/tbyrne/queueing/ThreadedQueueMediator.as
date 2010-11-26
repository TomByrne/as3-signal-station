package org.tbyrne.queueing
{
	import flash.utils.Dictionary;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.tbyrne.core.AbstractMediator;
	
	public class ThreadedQueueMediator extends AbstractMediator
	{
		private static const NAME:String = "ThreadedQueueMediator_";
		
		
		protected var _queue:ThreadedQueue;
		
		
		public function ThreadedQueueMediator(threadId:String, intendedThreadSpeed:Number=0.5, maxPerFrame:int = 512)
		{
			_queue = new ThreadedQueue(threadId,intendedThreadSpeed,maxPerFrame);
			super(NAME+threadId, _queue);
		}
		override protected function getActHandlerMapping():Dictionary {
			var ret:Dictionary = new Dictionary();
			ret["threadBegin"] = ThreadedQueueNotifications.QUEUE_STARTED;
			ret["threadEnd"] = ThreadedQueueNotifications.QUEUE_FINISHED;
			return ret;
		}
		
		override public function listNotificationInterests():Array {
			return [ThreadedQueueNotifications.SET_INTENDED_THREAD_SPEED,
				ThreadedQueueNotifications.ADD_QUEUE_ITEMS,
				ThreadedQueueNotifications.REMOVE_QUEUE_ITEMS];
		}
		
		override public function handleNotification(note:INotification):void {
			var items:QueueItemGroup;
			var queueItem:IQueueItem;
			switch (note.getName()) {
				case ThreadedQueueNotifications.SET_INTENDED_THREAD_SPEED:
					var threadSpeed:ThreadSpeed = note.getBody() as ThreadSpeed;
					if(threadSpeed.threadId==_queue.id){
						_queue.intendedThreadSpeed = threadSpeed.intendedThreadSpeed;
					}
					break;
				case ThreadedQueueNotifications.ADD_QUEUE_ITEMS:
					items = note.getBody() as QueueItemGroup;
					if(items.threadId==_queue.id){
						for each(queueItem in items.queueItems){
							_queue.addQueueItem(queueItem);
						}
					}
					break;
				case ThreadedQueueNotifications.REMOVE_QUEUE_ITEMS:
					items = note.getBody() as QueueItemGroup;
					if(items.threadId==_queue.id){
						for each(queueItem in items.queueItems){
							_queue.removeQueueItem(queueItem);
						}
					}
					break;
			}
		}
	}
}