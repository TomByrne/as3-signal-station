package au.com.thefarmdigital.display.controls
{
	import au.com.thefarmdigital.display.views.List;
	import au.com.thefarmdigital.events.ListEvent;
	import au.com.thefarmdigital.tweening.LooseTween;
	import au.com.thefarmdigital.utils.DisplayUtils;
	import au.com.thefarmdigital.validation.ValidationEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.goasap.events.GoEvent;
	
	/**
	 * Dispatched when the user selects an item from the list OR when the selectedIndex or selectedIndices property are set.
	 */
	[Event(name="selectionChange", type="au.com.thefarmdigital.events.ListEvent")]
	/**
	 * Dispatched only when the user selects an item from the list.
	 */
	[Event(name="userSelectionChange", type="au.com.thefarmdigital.events.ListEvent")]
	/**
	 * Dispatched when the ComboBox opens for any reason.
	 */
	[Event(name="open", type="flash.events.Event")]
	/**
	 * Dispatched when the ComboBox closes for any reason.
	 */
	[Event(name="close", type="flash.events.Event")]
	public class ComboBox extends Control
	{
		public function get list():List{
			return _list;
		}
		public function set list(value:List):void{
			if(_list!=value){
				if(_list)listContainer.removeChild(_list);
				addChildTo(listContainer, value);
				if(_scrollBar)_scrollBar.scrollSubject = _list;
				_list = value;
				_list.addEventListener(ListEvent.SELECTION_CHANGE,onListSelect);
				_list.addEventListener(ListEvent.USER_SELECTION_CHANGE,onUserListSelect);
				_list.selectionValidator.unselectable = false;
				if(_dataProvider)_list.dataProvider = _dataProvider;
				applyListOpenAmount();
				invalidate();
			}
		}
		public function get label():Button{
			return _label;
		}
		public function set label(value:Button):void{
			if(_label!=value){
				if(_label){
					removeChild(_label);
					_label.removeEventListener(MouseEvent.CLICK,toggleList);
				}
				addChildTo(this, value);
				value.addEventListener(MouseEvent.CLICK,toggleList);
				_label = value;
				_label.autoToggleSelect = true;
				this.applySnapping();
				assessLabel();
				invalidate();
			}
		}
		public function get scrollBar():ScrollBar{
			return _scrollBar;
		}
		public function set scrollBar(value:ScrollBar):void{
			if(_scrollBar!=value){
				if(_scrollBar)listContainer.removeChild(_scrollBar);
				addChildTo(listContainer, value);
				if(_list)value.scrollSubject = _list;
				_scrollBar = value;
				this.applySnapping();
				invalidate();
			}
		}
		public function get button():InteractiveObject{
			return _button;
		}
		public function set button(value:InteractiveObject):void{
			if(_button!=value){
				if(_button){
					removeChild(_button);
					_button.removeEventListener(MouseEvent.CLICK,toggleList);
				}
				if (value)
				{
					addChildTo(this, value);
					value.addEventListener(MouseEvent.CLICK,toggleList);
					if(_button is CheckBox){
						(_button as CheckBox).autoToggleSelect = true;
					}
				}
				_button = value;
				this.applySnapping();
				invalidate();
			}
		}
		[Inspectable(name="Prompt")]
		public function get prompt():String{
			return _prompt;
		}
		public function set prompt(value:String):void{
			if(_prompt!=value){
				_prompt = value;
				assessLabel();
			}
		}
		[Inspectable(name="List Height", defaultValue="100")]
		public function get listHeight():Number{
			return _listHeight;
		}
		public function set listHeight(value:Number):void{
			if(value<=0)value = NaN; // for flash Inspectable's sake
			if(_listHeight!=value){
				_listHeight = value;
				invalidate();
			}
		}
		[Inspectable(name="Data Provider", type="Array")]
		public function get dataProvider():Array{
			return _dataProvider;
		}
		public function set dataProvider(value:Array):void{
			if(_dataProvider!=value){
				_dataProvider = value;
				if(_list)_list.dataProvider = value;
				invalidateMeasurements();
				invalidate();
			}
		}
		
		[Inspectable(name="Label Button Label Field", defaultValue="", type="String")]
		public function get labelButtonLabelField(): String
		{
			return this._labelButtonLabelField;
		}
		public function set labelButtonLabelField(value: String): void
		{
			this._labelButtonLabelField = value;
		}
		
		private function get listContainer():Sprite{
			if(!_listContainer){
				_listContainer = new Sprite();
				addChild(_listContainer);
			}
			return _listContainer;
		}
		
		override public function set pixelSnapping(value:Boolean):void{
			super.pixelSnapping = value;
			this.applySnapping();
		}
		
		[Inspectable(name="Selected Index", defaultValue=-1, type="Number")]
		public function get selectedIndex():Number{
			return _list?_list.selectedIndex:NaN;
		}
		public function set selectedIndex(value:Number):void{
			if(_list){
				_list.selectedIndex = value;
			}
		}
		public function get selectedItem():*{
			return this._list.selectedItem;
		}
		
		override public function getValidationValue(validityKey:String=null):*{
			return selectedItem;
		}
		override public function setValidationValue(value:*, validityKey:String=null):void{
			// ignore, can't be set
		}
		
		override public function get highlit():Boolean{
			return _highlit;
		}
		override public function set highlit(to:Boolean):void{
			if(_highlit != to){
				_label.highlit = _list.highlit = to;
				if(_button is Control){
					(_button as Control).highlit = to;
				}
				_highlit = to;
				invalidate();
			}
		}
		
		[Inspectable(name="Open Upwards", defaultValue=false, type="Boolean")]
		public function get openUpwards():Boolean{
			return _openUpwards;
		}
		public function set openUpwards(to:Boolean):void{
			if(_openUpwards != to){
				_openUpwards = to;
				invalidate();
			}
		}
		override public function clear():void
		{
			if (this.prompt != null)
			{
				this.selectedIndex = -1;
				this.label.labelField.text = this.prompt;	
			}
		}
				
		public var openEasing:Function;
		public var openDuration:Number;
		public var closeEasing:Function;
		public var closeDuration:Number;
		
		protected var _listContainer:Sprite;
		protected var _list:List;
		protected var _label:Button;
		private var _labelButtonLabelField: String;
		protected var _scrollBar:ScrollBar;
		protected var _button:InteractiveObject;
		
		protected var _openUpwards:Boolean = false;
		protected var _open:Boolean = false;
		protected var listOpenAmount:Number = 0;
		protected var _prompt:String;
		protected var _listHeight:Number;
		protected var _dataProvider:Array;
		
		public function ComboBox(){
			super();
			applyListOpenAmount();
		}
		
		override protected function measure():void
		{
			// TODO: measuredWidth and measuredHeight not working on Button, should switch this when they are
						
			var oldText: String = this.label.label;
			var mWidth: Number = this.label.width;
			var mHeight: Number = this.label.height;
			if (this.dataProvider)
			{
				for (var i: uint = 0; i < this.dataProvider.length; ++i)
				{
					var testItem: Object = this.dataProvider[i];
					this.label.label = this.getSelectedLabel(testItem);
					mWidth = Math.max(mWidth, this.label.measuredWidth);
				}
			}
			this.label.label = oldText;
			
			if (this.button != null)
			{
				mWidth += this.button.width;
				mHeight += this.button.height;
			}
			if (this.list)
			{
				mWidth = Math.max(mWidth, this.list.measuredWidth);
			}
			this._measuredWidth = mWidth;
			this._measuredHeight = mHeight;
		}
		
		private function applySnapping(): void
		{
			if (this.list)
			{
				this.list.pixelSnapping = this.pixelSnapping;
			}
			if (this.button && this.button is Control)
			{
				(this.button as Control).pixelSnapping = this.pixelSnapping;
			}
			if (this.label)
			{
				this.label.pixelSnapping = this.pixelSnapping;
			}
			if (this.scrollBar)
			{
				this.scrollBar.pixelSnapping = this.pixelSnapping;
			}
		}
		
		protected function toggleList(e:MouseEvent=null):void{
			if(_open)close();
			else open();
		}
		protected function close():void{
			if(_open){
				_open = false;
				var duration:Number = (closeDuration?closeDuration:openDuration);
				if(isNaN(duration)){
					listOpenAmount = 0;
					applyListOpenAmount();
				}else{
					var tween:LooseTween = new LooseTween({value:listOpenAmount},{value:0},(closeEasing!=null?closeEasing:openEasing),duration);
					tween.addEventListener(GoEvent.UPDATE,tweenChange);
					tween.start();
				}
				stage.removeEventListener(MouseEvent.MOUSE_DOWN,stageClick);
				invalidate();
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		protected function open():void{
			if(!_open){
				_open = true;
				highlit=false;
				if(isNaN(openDuration)){
					listOpenAmount = 1;
					applyListOpenAmount();
				}else{
					var tween:LooseTween = new LooseTween({value:listOpenAmount},{value:1},openEasing,openDuration);
					tween.addEventListener(GoEvent.UPDATE,tweenChange);
					tween.start();
				}
				stage.addEventListener(MouseEvent.MOUSE_DOWN,stageClick);
				invalidate();
				dispatchEvent(new Event(Event.OPEN));
			}
		}
		protected function stageClick(e:MouseEvent):void{
			if(e.target!=this && !DisplayUtils.isDescendant(this,e.target as DisplayObject)){
				close();
			}
		}
		protected function tweenChange(e:GoEvent):void{
			listOpenAmount = (e.target as LooseTween).position
			applyListOpenAmount();
		}
		override protected function draw():void{
			if(_label){
				_label.x = label.y = 0;
				if(_button){
					_button.y = 0;
					_label.width = width-_button.width;
					_button.x = _label.width;
					_label.height = _button.height;
					if(_button is CheckBox){
						(_button as CheckBox).selected = _open;
					}
				}else{
					_label.width = width;
					_label.height = height;
				}
				
				// Added				
				_label.highlit = _list.highlit = _highlit;
				if(_button is Control){
					(_button as Control).highlit = _highlit;
				}				
				
				_label.selected = _open;
				if(_list){
					_list.y = 0;
					_list.height = (!isNaN(_listHeight)?_listHeight:_list.measuredHeight);
					if(scrollBar){
						scrollBar.y = 0;
						if(_list.dataProvider != null && _list.displayedCells<_list.dataProvider.length){
							scrollBar.visible = true;
							scrollBar.x = width-scrollBar.width;
							scrollBar.height = list.height;
						}else{
							scrollBar.visible = false;
						}
					}
					_list.width = width-(scrollBar && scrollBar.visible?scrollBar.width:0);
					applyListOpenAmount();
				}
			}
		}
		protected function applyListOpenAmount(e:Event=null):void{
			if(_list){
				var listHeight:Number = Math.min(_list.height,_list.measuredHeight);
				listContainer.scrollRect = new Rectangle(0,listHeight*(1-listOpenAmount),width,listHeight*listOpenAmount);
				if(_openUpwards){
					listContainer.y = -listContainer.scrollRect.height;
				}else if (this.label){
					listContainer.y = this.label.height;
				}else if (this.button){
					listContainer.y = this.button.height;
				}else{
					listContainer.y = 0;
				}
			}
		}
		protected function assessLabel():void{
			if(_label){
				var displayLabel: String = null;
				if (this.list && this.list.selectedItem != null)
				{
					var selItem: * = this.list.selectedItem;
					displayLabel = this.getSelectedLabel(selItem);
				}
				else
				{
					displayLabel = _prompt;
				}
				_label.label = displayLabel;			
			}
		}
		
		private function getSelectedLabel(selItem: Object): String
		{
			var selLabel: String = "";
			if (selItem != null)
			{
				if (this.labelButtonLabelField != "" && this.labelButtonLabelField != null)
				{
					selLabel = selItem[this.labelButtonLabelField];
				}
				else
				{
					selLabel = this.list.getLabel(selItem);
				}
			}
			return selLabel;
		}
		
		protected function onListSelect(e:Event=null):void{
			close();
			assessLabel();
			this.dispatchEvent(new ListEvent(_list.selectedItem,_list.selectedIndex,_list.selectedItems,_list.selectedIndices,ListEvent.SELECTION_CHANGE));
			dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_VALUE_CHANGED));
		}
		protected function onUserListSelect(e:Event=null):void{
			close();
			assessLabel();
			this.dispatchEvent(new ListEvent(_list.selectedItem,_list.selectedIndex,_list.selectedItems,_list.selectedIndices,ListEvent.USER_SELECTION_CHANGE));
		}
	}
}