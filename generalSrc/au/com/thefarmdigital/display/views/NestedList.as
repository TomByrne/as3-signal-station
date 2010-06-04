package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.display.controls.ISelectableControl;
	import au.com.thefarmdigital.events.ListEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.farmcode.display.constants.Direction;
	import org.farmcode.instanceFactory.IInstanceFactory;
	import org.farmcode.instanceFactory.MultiInstanceFactory;
	
	public class NestedList extends List
	{
		private static const INHERITED_LIST_PROPS: Array = ["itemFactory", 
			"labelField", "labelFunction","childrenField","listFactory","allowAutoSize"];
		
		protected var _childrenField: String;
		protected var _listFactory:IInstanceFactory;
		protected var secondaryListValid: Boolean;
		protected var secondaryList: List;
		protected var _focusItem: ISelectableControl;
		protected var _inheritDictionary:Dictionary = new Dictionary();
		protected var _lastOverItem:ISelectableControl;
		protected var _closeTimer:Timer;
		
		/**
		 * The amount of time after a user rolls out of the child list before it closes.
		 */
		public var closeListTime:Number = 0.25;
		
		public function NestedList(){
			super();
			
			this.secondaryListValid = true;
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStageEvent);
		}
		
		private function handleRemovedFromStageEvent(event: Event): void
		{
			this.destroyList();
			this.secondaryListValid = false;
		}
		/**
		 * This factory is used to create the child list instance. 
		 */
		public function set listFactory(value: IInstanceFactory): void
		{
			var cast:MultiInstanceFactory;
			if (value != this._listFactory){
				if(_listFactory){
					cast = (_listFactory as MultiInstanceFactory);
					if(cast){
						cast.removeProperties(_inheritDictionary);
					}
				}
				this._listFactory = value;
				if(_listFactory){
					cast = (_listFactory as MultiInstanceFactory);
					if(cast){
						cast.addPropertiesAt(_inheritDictionary, 0);
						var defaults:Dictionary = new Dictionary();
						defaults["direction"] = Direction.VERTICAL;
						cast.addPropertiesAt(defaults, 1);
					}
				}
				destroyList();
				secondaryListValid = false;
				this.invalidate();
			}
		}
		public function get listFactory(): IInstanceFactory
		{
			return this._listFactory;
		}
		
		public function set childrenField(childrenField: String): void
		{
			if (childrenField != this._childrenField)
			{
				this._childrenField = childrenField;
				this.invalidate();
			}
		}
		public function get childrenField(): String
		{
			return this._childrenField;
		}
		
		
		override protected function getRenderer():ISelectableControl
		{
			var renderer: ISelectableControl = super.getRenderer();
			renderer.addEventListener(MouseEvent.ROLL_OVER, this.handleRendererOverEvent);
			return renderer;
		}
		
		private function handleRendererOverEvent(event: MouseEvent): void
		{
			_lastOverItem = event.currentTarget as ISelectableControl;
			invalidateSecondaryList();
		}
		
		protected function set focusItem(focusItem: ISelectableControl): void
		{
			if (focusItem != this._focusItem)
			{
				if (this._focusItem != null)
				{
					this._focusItem.highlit = false;
				}
				this._focusItem = focusItem;
				if (this._focusItem != null){
					this._focusItem.highlit = true;
				}
			}
		}
		
		private function invalidateSecondaryList(): void
		{
			this.secondaryListValid = false;
			this.invalidate();
		}
		
		override protected function draw():void
		{
			super.draw();
			var targetItem: ISelectableControl = this.getLastOverItem();
			if (!this.secondaryListValid)
			{
				if(targetItem){
					var dataProvider:Array;
					var targetData: * = targetItem.data;
					if (targetData != null && this.childrenField){
						dataProvider = targetData[childrenField];
					}
					if(dataProvider && dataProvider.length){
						this.createList();
						this.secondaryList.dataProvider = dataProvider;
					}else{
						removeList();
					}
				}
				
				this.secondaryListValid = true;
			}
			
			if (secondaryList && secondaryList.parent)
			{
				if (this.direction == Direction.VERTICAL){
					this.secondaryList.x = width;
					this.secondaryList.y = container.y+targetItem.y;
				}else{
					this.secondaryList.x = container.x+targetItem.x;
					this.secondaryList.y = height;
				}
				this.secondaryList.width = this.secondaryList.measuredWidth;
				this.secondaryList.height = this.secondaryList.measuredHeight;
			}
		}
		protected function getLastOverItem(): ISelectableControl{
			for (var i: uint = 0; i < this._itemRenderers.length; ++i){
				var testItem: ISelectableControl = this._itemRenderers[i];
				if (testItem.mouseOver){
					_lastOverItem = testItem;
					break;
				}
			}
			return _lastOverItem;
		}
		
		
		private function bubbleEvent(event:Event): void{
			this.dispatchEvent(event);
		}
		
		private function handleFrameCheckListOutEvent(event: Event): void{
			var targetItem: ISelectableControl = this.getLastOverItem();
			
			var bounds:Rectangle = secondaryList.getBounds(this);
			if(targetItem){
				bounds = bounds.union(targetItem.display.getBounds(this));
			}
			var mouseOver: Boolean = (mouseX>bounds.left && mouseX<bounds.right && mouseY>bounds.top && mouseY<bounds.bottom);
			
			if(mouseOver){
				if(_closeTimer){
					_closeTimer.removeEventListener(TimerEvent.TIMER, onCloseTimer);
					_closeTimer = null;
				}
			}else if(!_closeTimer){
				_closeTimer = new Timer(closeListTime*1000,1);
				_closeTimer.addEventListener(TimerEvent.TIMER, onCloseTimer);
				_closeTimer.start();
			}
		}
		private function onCloseTimer(event: Event): void{
			_lastOverItem = null;
			removeList();
		}
		
		protected function createList(): void{
			if(!secondaryList){
				var inher:Array = NestedList.INHERITED_LIST_PROPS;
				for each(var prop:String in inher){
					_inheritDictionary[prop] = this[prop];
				}
				secondaryList = listFactory.createInstance();
				secondaryList.addEventListener(ListEvent.SELECTION_CHANGE,bubbleEvent);
				secondaryList.addEventListener(ListEvent.USER_SELECTION_CHANGE,bubbleEvent);
				secondaryList.addEventListener(ListEvent.ITEM_CLICK,bubbleEvent);
			}
			addList();
		}
		protected function addList(): void{
			if(secondaryList && !secondaryList.parent){
				addChild(this.secondaryList);
				addEventListener(Event.ENTER_FRAME, this.handleFrameCheckListOutEvent);
			}
		}
		private function destroyList(): void{
			if (secondaryList){
				removeList();
				this.secondaryList.removeEventListener(ListEvent.SELECTION_CHANGE,bubbleEvent);
				this.secondaryList.removeEventListener(ListEvent.USER_SELECTION_CHANGE,bubbleEvent);
				this.secondaryList.removeEventListener(ListEvent.ITEM_CLICK,bubbleEvent);
				this.secondaryList = null;
			}
		}
		private function removeList(): void{
			if (secondaryList && secondaryList.parent){
				this.removeEventListener(Event.ENTER_FRAME,	this.handleFrameCheckListOutEvent);
				this.removeChild(secondaryList);
			}
		}
	}
}