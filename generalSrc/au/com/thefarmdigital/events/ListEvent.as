package au.com.thefarmdigital.events
{
	import flash.events.Event;
	
	public class ListEvent extends ControlEvent
	{
		public static const SELECTION_CHANGE:String = "selectionChange";
		public static const USER_SELECTION_CHANGE:String = "userSelectionChange";
		public static const ITEM_CLICK:String = "itemClick";
		
		public var selectedItem:Object;
		public var selectedIndex:int;
		public var selectedItems:Array;
		public var selectedIndices:Array;
		public var targetItem: *;
		
		public function ListEvent(selectedItem:Object, selectedIndex:int, selectedItems:Array, selectedIndices:Array, type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
			this.selectedItem = selectedItem;
			this.selectedIndex = selectedIndex;
			this.selectedItems = selectedItems;
			this.selectedIndices = selectedIndices;
		}
		override public function clone():Event{
			var clone: ListEvent = new ListEvent(selectedItem, selectedIndex, selectedItems, selectedIndices, type, bubbles, cancelable);
			clone.targetItem = this.targetItem;
			return clone;
		}
	}
}