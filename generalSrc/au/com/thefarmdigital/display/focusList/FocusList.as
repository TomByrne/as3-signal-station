package au.com.thefarmdigital.display.focusList
{
	import au.com.thefarmdigital.display.View;
	import au.com.thefarmdigital.tweening.LooseTween;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import org.goasap.events.GoEvent;
	
	/**
 	 * A simple implementation of a list of items where there is some effect placed on the currently
 	 * focussed item. On changing the currently focussed item, all items transition in to their new
 	 * positions. A set of properties are also applied to each item during this transition based on
 	 * how far each item is from the focussed item.<br>
 	 * <br>
 	 * The list assumes a constant width for all items (without consideration of focus properties).<br>
 	 * <br>
 	 * The implementation currently renders all items in the dataProvider even if they aren't in view
 	 * and only functions in the no wrap mode.<br>
 	 * <br>
 	 * An example usage:
 	 * <code>
 	 * 		var focusList: FocusList = new FocusList();<br>
 	 * 		<br>
 	 * 		// Properties for the focussed item<br>
	 *		var selectedProps: Dictionary = new Dictionary();<br>
	 *		selectedProps["scaleX"] = 1;<br>
	 *		selectedProps["scaleY"] = 1;<br>
	 *		this.focusList.setFocusProperties(0, selectedProps);<br>
	 * <br>
	 * 		// Properties for all items 1 position and greater away<br>
	 * 		var unselectedProps: Dictionary = new Dictionary();<br>
	 * 		unselectedProps["scaleX"] = 0.25;<br>
	 *		unselectedProps["scaleY"] = 0.25;<br>
	 * 		focusList.setFocusProperties(1, unselectedProps);<br>
	 * <br>
	 *		focusList.addEventListener(FocusListEvent.FOCUS_FINISHED, this.handleFocusTweenFinishedEvent);<br>
	 *		focusList.setSpacing(10);<br>
	 *		focusList.setItemPrototype(MyFocusListItem);<br>
	 * 	<br>
	 * 		focusList.setDataProvider(["a", 2, "c"]);<br>
	 * </code>
	 */
	public class FocusList extends View
	{
		private static const DEFAULT_TRANSITION_TIME: Number = 0.5;
		
		public var easingFunction:Function;
		
		private var dataProvider: Array;
		private var spacing: Number;
		private var focusItemIndex: int;
		private var displayItems: Array;
		private var focusValid: Boolean;
		private var itemsValid: Boolean;
		private var itemContainer: DisplayObjectContainer;
		private var containerTween:LooseTween;
		private var itemPrototype: Class;
		private var transitionTime: Number;
		private var allowWrap: Boolean;
		
		/**
		 * The properties for the main focussed item. The index indicates
		 * How far from the focus the properties are for. Properties are held
		 * in dictionary objects
		 */
		private var focusProperties: Array;
		
		public function FocusList()
		{
			super();
			
			this.spacing = 0;
			
			this.allowWrap = true;
			
			this.transitionTime = FocusList.DEFAULT_TRANSITION_TIME;
			
			this.focusValid = true;
			this.itemsValid = true;
			
			this.focusItemIndex = 0;
			
			this.focusProperties = new Array();
			
			this.displayItems = new Array();
			
			this.itemContainer = new Sprite();
			this.addChild(this.itemContainer);
			
			this.focusProperties = new Array();
		}
		
		/**
		 * // TODO: Currently has no effect, always wrap = false
		 */
		public function setAllowWrap(allowWrap: Boolean): void
		{
			this.allowWrap = allowWrap;
			this.invalidateItems();
		}
		
		public function getFocusedData(): *
		{
			var data: * = this.dataProvider[this.focusItemIndex];
			return data;
		}
		
		public function setTransitionTime(transitionTime: Number): void
		{
			this.transitionTime = transitionTime;
		}
		
		public function setItemPrototype(itemPrototype: Class): void
		{
			this.itemPrototype = itemPrototype;
		}
		
		public function setFocusProperties(distance: uint, properties: Dictionary): void
		{
			this.focusProperties[distance] = properties;
		}
		
		public function setSpacing(spacing: uint): void
		{
			if (spacing != this.spacing)
			{
				this.spacing = spacing;
				this.invalidateFocus();
			}
		}
		
		/**
		 * Set the source of the data for the list
		 */
		public function setDataProvider(dataProvider: Array): void
		{
			this.dataProvider = dataProvider;
			
			this.focusItemIndex = 0;
			
			this.invalidateItems();
			this.invalidateFocus();
		}
		
		public function getDataProvider(): Array
		{
			return this.dataProvider;
		}
		
		override protected function draw(): void
		{
			//this.scrollRect = new Rectangle(0, -Math.cthis.height / 2, this.width, this.height);
			
			if (!this.itemsValid)
			{
				this.drawItems();
				this.itemsValid = true;
			}
			if (!this.focusValid)
			{
				this.drawFocus();
				this.focusValid = true;
			}
		}
		
		/**
		 * Removes all the current items and redraws them
		 */
		private function drawItems(): void
		{
			this.itemContainer.x = Math.round(this._width / 2);
			
			// Remove current items
			while (this.displayItems.length > 0)
			{
				var item: FocusListItem = this.displayItems.pop() as FocusListItem;
				this.removeDisplayItem(item);
			}
			
			if (this.dataProvider != null && this.dataProvider.length > 0)
			{				
				// Add items on left
				var added: Array = new Array();
				
				for (var j: uint = 0; j <= this.focusItemIndex; ++j)
				{
					var lNewItem: FocusListItem = this.createNextItem(false, j);
					this.displayItems[j] = lNewItem;
					added.push(lNewItem);
				}
				
				// Add items on right
				for (var i: int = this.focusItemIndex + 1; i < this.dataProvider.length; ++i)
				{
					var rNewItem: FocusListItem = this.createNextItem(true, i);
					this.displayItems[i] = rNewItem;
					added.push(rNewItem);
				}
			}
		}
		
		/**
		 * Changes the position of the current items and adds or removes items as required
		 */
		private function drawFocus(): void
		{
			if (this.dataProvider != null && this.dataProvider.length > 0)
			{				
				// Tween for the focussed item
				var focusDisplayItem: FocusListItem = this.displayItems[this.focusItemIndex] as FocusListItem;
				var focusItemWidth: Number = focusDisplayItem.getMaxWidth() / 2;
				
				// Focus Display items
				for (var k: uint = 0; k < this.displayItems.length; ++k)
				{
					var item: FocusListItem = this.displayItems[k] as FocusListItem;
					var immediate: Boolean = false; //item.isNew(); //false; // TODO: (added.indexOf(item) >= 0);
					
					var diff: uint = Math.abs(this.displayItems.indexOf(item) - this.focusItemIndex);
					item.setDistanceFromFocus(diff, immediate);
					
					var propDiff: Number = Math.min(diff, this.focusProperties.length - 1);
					var targetProps: Dictionary = this.focusProperties[propDiff] as Dictionary;
					
					var destXScale: Number = 1;
					if (targetProps["scaleX"] != null)
					{
						destXScale = targetProps["scaleX"];
					}
					//var destX: Number = k * item.getMaxWidth() * destXScale;
					var itemPosDiff: Number = k - this.focusItemIndex;
					var destX: Number = item.x;
					if (k != this.focusItemIndex)
					{
						var itemPosDir: int = itemPosDiff / Math.abs(itemPosDiff);
						var minorItemWidth: Number = item.getMaxWidth() * destXScale;
						var minorItemsWidth: Number = itemPosDiff * (minorItemWidth + this.spacing);
						destX = focusDisplayItem.x + minorItemsWidth + (itemPosDir * focusItemWidth) - (itemPosDir * minorItemWidth / 2);
					}
					item.moveToX(destX);
					
					if (item != focusDisplayItem && 
						this.itemContainer.getChildIndex(item) > this.itemContainer.getChildIndex(focusDisplayItem))
					{
						this.itemContainer.swapChildren(focusDisplayItem, item);
					}
				}
				
				// Tween item container's x
				var targetX: int = Math.round((this._width / 2) - focusDisplayItem.x);
				if (this.containerTween != null)
				{
					this.containerTween.stop();
				}
				containerTween = new LooseTween(itemContainer, {x:targetX}, easingFunction, this.transitionTime);
				containerTween.addEventListener(GoEvent.COMPLETE, handleItemContainerTweenFinishEvent);
				containerTween.start();
			}
		}
		
		private function handleItemContainerTweenFinishEvent(event:GoEvent): void
		{
			var focusEvent: FocusListEvent = new FocusListEvent(FocusListEvent.FOCUS_FINISHED);
			this.dispatchEvent(focusEvent);
		}
		
		/**
		 * Creates a new item that represents the given data
		 */
		private function createNextItem(right: Boolean, itemIndex: int): FocusListItem
		{
			var item: FocusListItem = null;
			
			if (this.itemPrototype == null)
			{
				throw new Error("No Item Renderer specified");
			}
			else
			{
				item = this.getItemRenderer();
				this.itemContainer.addChild(item);
				item.easingFunction = easingFunction;

				if (itemIndex >= 0 && itemIndex < this.dataProvider.length)
				{
					var data: * = this.dataProvider[itemIndex];
					
					for (var i: uint = 0; i < this.focusProperties.length; ++i)
					{
						var properties: Dictionary = this.focusProperties[i] as Dictionary;
						item.setFocusProperties(i, properties);
					}
					item.setTransitionTime(this.transitionTime);
					item.setData(data);
					item.addEventListener(MouseEvent.CLICK, this.handleItemClickEvent);
				}
			}
						
			return item;
		}
		
		protected function handleItemClickEvent(event: MouseEvent): void
		{
			var item: FocusListItem = event.target as FocusListItem;
			this.setFocalData(item.getData());
		}
		
		protected function getItemRenderer(): FocusListItem
		{
			var item: FocusListItem = null;
			var itemRenderer: * = new this.itemPrototype();
			if (itemRenderer is FocusListItem)
			{
				item = itemRenderer as FocusListItem;
			}
			else
			{
				throw new Error("Item Renderer must be of type FocusListItem");
			}
			return item;
		}
		
		private function removeDisplayItem(item: FocusListItem, force: Boolean = false): void
		{
			var itemIndex: int = this.displayItems.indexOf(item);
			if (itemIndex >= 0)
			{
				this.displayItems.splice(itemIndex, 1);
				if (itemIndex < this.focusItemIndex)
				{
					this.focusItemIndex--;
				}
			}
			
			if (force)
			{
				item.removeEventListener(FocusListItemEvent.DISPOSED, this.handleItemDisposedEvent);
				if (this.itemContainer.contains(item))
				{
					this.itemContainer.removeChild(item);
				}
				item.dispose(true);
				
			}
			else
			{
				item.addEventListener(FocusListItemEvent.DISPOSED, this.handleItemDisposedEvent);
				item.dispose();
			}
		}
		
		private function handleItemDisposedEvent(event: FocusListItemEvent): void
		{
			var targetItem: FocusListItem = event.target as FocusListItem;
			this.removeDisplayItem(targetItem, true);
		}
		
		/**
		 * Offsets the current focal point of the list
		 */
		public function offsetFocalIndex(amount: int): void
		{
			if (amount != 0)
			{
				this.setFocalIndex(this.focusItemIndex + amount);
			}
		}
		
		public function setFocalData(data: *): void
		{
			var dataIndex: int = this.dataProvider.indexOf(data);
			if (dataIndex >= 0)
			{
				this.setFocalIndex(dataIndex);
			}
		}
		
		public function getFocusedRenderer(): FocusListItem
		{
			// TODO: For some reason display items array not matching data indexes
			var data: * = this.getFocusedData();
			var targetRenderer: FocusListItem = null;
			for (var i: uint = 0; i < this.displayItems.length && targetRenderer == null; ++i)
			{
				var testItem: FocusListItem = this.displayItems[i] as FocusListItem;
				if (testItem.getData() == data)
				{
					targetRenderer = testItem;
				}
			}
			return targetRenderer;
		}
		
		public function setFocalIndex(index: int): void
		{
			if (index != this.focusItemIndex && index >= 0 && index < this.dataProvider.length)
			{
				this.focusItemIndex = index;
				this.dispatchChangeEvent();
				this.invalidateFocus();
			}
		}
		
		private function invalidateItems(): void
		{
			this.itemsValid = false;
			this.invalidate();
		}
		
		private function invalidateFocus(): void
		{
			this.focusValid = false;
			this.invalidate();
		}
		
		private function dispatchChangeEvent(): void
		{
			var event: Event = new Event(Event.CHANGE);
			this.dispatchEvent(event);
		}
	}
}