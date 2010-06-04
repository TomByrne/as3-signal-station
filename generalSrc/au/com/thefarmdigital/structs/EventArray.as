// When/if AS3 supports operator overrides this class will have to be changed 
// dramatically.
package au.com.thefarmdigital.structs
{
	import au.com.thefarmdigital.events.ArrayEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * This is dispatched when one of the values in the array is set/reset.
	 * 
	 * @eventType au.com.thefarmdigital.events.ArrayEvent.ARRAY_CHANGE
	 */
	[Event(name="arrayChange",type="au.com.thefarmdigital.events.ArrayEvent")]
	
	/**
	 * The EventArray class is an Array wrapper which dispatches events when it's 
	 * values change.
	 */
	public class EventArray implements IEventDispatcher
	{
		/** Manages event notifications for the array */
		private var dispatcher: IEventDispatcher;
		
		/** The number of elements within the array */
		public function get length():uint
		{
			return children.length;
		}
		
		/** The represented array */
		private var children: Array;
		
		/**
		 * Creates a new event array with the given children. 
		 * 
		 * @param	children	The children to place in the array. if null the 
		 * 						array begins empty
		 */
		public function EventArray(children:Array = null)
		{
			this.dispatcher = new EventDispatcher(this);
			if (children)
			{
				this.children = children.slice();
			}
			else
			{
				this.children = new Array();
			}
		}
		
		/**
		 * Retrieves the item at the given index
		 * 
		 * @param	index	The index of the item to retrieve
		 * 
		 * @return	The target item or null if there was no item found
		 */
		public function getItemAt(index:uint):*
		{
			return children[index];
		}
		
		/**
		 * Sets the item for the given index
		 * 
		 * @param	item	The item to place in the array
		 * @param	index	The index of the given item
		 */
		public function setItemAt(item:*, index:uint):void{
			children[index] = item;
			dispatchEvent(new ArrayEvent(ArrayEvent.ARRAY_CHANGE));
		}
		
		/**
		 * Adds an item to the end of the array
		 * 
		 * @param	item	The item to add at the end
		 */
		public function addItem(item:*):void{
			children.push(item);
			dispatchEvent(new ArrayEvent(ArrayEvent.ARRAY_CHANGE));
		}
		
		/**
		 * Adds an item at the given index and shifts the items after it
		 * 
		 * @param	item	The item to insert into the array
		 * @param	index	The index to insert the item at
		 */
		public function addItemAt(item:*, index:uint):void
		{
			children.splice(index,0,item);
			dispatchEvent(new ArrayEvent(ArrayEvent.ARRAY_CHANGE));
		}
		
		/**
		 * Checks whether the array contians the given item
		 * 
		 * @param	item	The item to check for
		 * 
		 * @return	true if the item was found, false if not
		 */
		public function contains(item:*):Boolean{
			return (children.indexOf(item)!=-1);
		}
		
		/**
		 * Find the index of the given item.
		 * 
		 * @param	item	The item to search for
		 * 
		 * @return	The index of the item or -1 if not found
		 */
		public function indexOf(item:*):int{
			return children.indexOf(item);
		}
		
		/**
		 * Remove all items in the current array
		 */
		public function removeAll():void{
			children = this.children.splice(0);
			dispatchEvent(new ArrayEvent(ArrayEvent.ARRAY_CHANGE));
		}
		
		/**
		 * Remove the item at the given index and shift all items behind forward
		 * 
		 * @param	item	The item to remove
		 */
		public function removeItemAt(index:uint):void{
			children.splice(index,1);
			dispatchEvent(new ArrayEvent(ArrayEvent.ARRAY_CHANGE));
		}
		
		/**
		 * Convert this collection to a native ActionScript array
		 * 
		 * @return	The native array representing this array's values
		 */
		public function toArray():Array
		{
			return children.slice();
		}
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:String, listener:Function, 
			useCapture:Boolean=false, priority:int=0, 
			useWeakReference:Boolean=false):void
		{
			this.dispatcher.addEventListener(type, listener, useCapture, priority, 
			useWeakReference);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type:String, listener:Function, 
			useCapture:Boolean=false):void
		{
			this.dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event: Event):Boolean
		{
			return this.dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type:String):Boolean
		{
			return this.dispatcher.hasEventListener(type);
		}
		
		/**
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean
		{
			return this.dispatcher.willTrigger(type);
		}
	}
}