package au.com.thefarmdigital.collections.priorityQueue
{
	import org.farmcode.collections.ICollection;
	import org.farmcode.collections.IIterator;
	
	public class PriorityQueue implements ICollection
	{
		protected var _ascending: Boolean;
		protected var bundles: Array;
		protected var orderValid: Boolean;
		
		public function PriorityQueue(numElements: int = 0)
		{
			this.orderValid = true;
			this.ascending = false;
			this.bundles = new Array(numElements);
		}
		
		public function getIterator(): IIterator
		{
			return new PriorityQueueIterator(this);
		}
		
		public function set ascending(ascending: Boolean): void
		{
			if (ascending != this.ascending)
			{
				this._ascending = ascending;
			}
		}
		public function get ascending(): Boolean
		{
			return this._ascending;
		}
		
		public function get length(): int
		{
			return this.bundles.length;
		}
		
		public function add(item: *, priority: Number): void
		{
			this.bundles.push(new ItemBundle(item, priority));
			this.invalidateOrder();
		}
		
		public function get(priorityIndex: int): *
		{
			this.ensureOrder();
			var bundle: ItemBundle = this.bundles[priorityIndex];
			var item: * = null;
			if (bundle)
			{
				item = bundle.item;
			}
			return item;
		}
		
		public function pop(): *
		{
			this.ensureOrder();
			var item: * = null;
			if (this.length > 0)
			{
				var bundle: ItemBundle = this.bundles.shift();
				item = bundle.item;
			}
			return item;
		}
		
		public function remove(item: *): Boolean
		{
			var present: Boolean;
			var index: int = this.indexOf(item);
			if (index >= 0)
			{
				this.bundles.splice(index, 1);
				present = true;
			}
			else
			{
				present = false;
			}
			return present;
		}
		
		public function contains(item: *): Boolean
		{
			return this.indexOf(item) >= 0;
		}
		
		protected function indexOf(item: *): int
		{
			var index: int = -1;
			for (var i: uint = 0; i < this.bundles.length && index < 0; ++i)
			{
				var testBundle: ItemBundle = this.bundles[i];
				if (testBundle.item == item)
				{
					index = i;
				}
			}
			return index;
		}
		
		public function toArray(): Array
		{
			this.ensureOrder();
			var arr: Array = new Array(this.length);
			for (var i: uint = 0; i < this.bundles.length; ++i)
			{
				var bundle: ItemBundle = this.bundles[i];
				arr[i] = bundle.item;
			}
			return arr;
		}
		
		protected function ensureOrder(): void
		{
			if (!this.orderValid)
			{
				if (this.ascending)
				{
					this.bundles.sortOn(ItemBundle.PRIORITY, Array.DESCENDING);	
				}
				else
				{
					this.bundles.sortOn(ItemBundle.PRIORITY);
				}
				this.orderValid = true;
			}
		}
		
		protected function invalidateOrder(): void
		{
			this.orderValid = false;
		}
	}
}

class ItemBundle
{
	public static const PRIORITY: String = "priority";
	
	public var item: *;
	public var priority: Number;
	
	public function ItemBundle(item: *, priority: Number)
	{
		this.item = item;
		this.priority = priority; 
	}
}