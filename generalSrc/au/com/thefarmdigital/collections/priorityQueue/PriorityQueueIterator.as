package au.com.thefarmdigital.collections.priorityQueue
{
	import org.farmcode.collections.IIterator;

	public class PriorityQueueIterator implements IIterator
	{
		public function get x():int{
			return cursor;
		}
		
		private var queue: PriorityQueue;
		private var cursor: int;
		
		public function PriorityQueueIterator(queue: PriorityQueue)
		{
			this.queue = queue;
			this.cursor = -1;
		}

		public function next():*
		{
			this.cursor++;
			return this.current();
		}
		
		public function current():*
		{
			return this.queue.get(this.cursor);
		}
		
		public function reset():void
		{
			this.cursor = -1;
		}
		public function release():void{
		}
	}
}