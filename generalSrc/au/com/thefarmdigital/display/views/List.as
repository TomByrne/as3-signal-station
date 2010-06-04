package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.display.controls.ISelectableControl;
	import au.com.thefarmdigital.display.scrolling.IScrollable;
	import au.com.thefarmdigital.events.ControlEvent;
	import au.com.thefarmdigital.events.ListEvent;
	import au.com.thefarmdigital.structs.ScrollMetrics;
	import au.com.thefarmdigital.structs.SelectionMap;
	import au.com.thefarmdigital.validation.ValidationEvent;
	import au.com.thefarmdigital.validation.object.SelectionMapValidator;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	
	import org.farmcode.display.constants.Direction;
	import org.farmcode.instanceFactory.IInstanceFactory;
	import org.farmcode.instanceFactory.MultiInstanceFactory;
	import org.farmcode.reflection.ReflectionUtils;
	
	/**
	 * Dispatched when the user selects an item from the list OR when the selectedIndex or selectedIndices property are set.
	 */
	[Event(name="selectionChange", type="au.com.thefarmdigital.events.ListEvent")]
	/**
	 * Dispatched only when the user selects an item from the list.
	 */
	[Event(name="userSelectionChange", type="au.com.thefarmdigital.events.ListEvent")]
	/**
	 * Dispatched when the user clicks an item from the list (a clicked item may not become selected).
	 * the data associated with the clicked item is in event.targetItem
	 */
	[Event(name="itemClick", type="au.com.thefarmdigital.events.ListEvent")]
	/**
	 * Dispatched when the data provider have been changed
	 */
	[Event(name="dataChange", type="au.com.thefarmdigital.events.ControlEvent")]
	public class List extends StackView implements IScrollable
	{
		protected static const DEFAULT_LABEL_FIELDS: Array = ["label", "text"];
		
		protected static const SELECTION_VALIDATION_KEY:String = "selectionValidationKey";
		
		/**
		 * Whether, when an item is selected, the scrollIndex should be adjusted
		 * to center the item (provided it's not too close one end of the list).
		 */
		[Inspectable(type="Boolean", name="Center Selection", defaultValue=false)]
		public function get centerSelection():Boolean{
			return _centerSelection;
		}
		public function set centerSelection(value:Boolean):void{
			if(_centerSelection!=value){
				_centerSelection = value;
				invalidate();
			}
		}
		/**
		 * This factory is used to generate item renderers for the list.
		 */
		public function get itemFactory():IInstanceFactory{
			return _itemFactory;
		}
		public function set itemFactory(value:IInstanceFactory):void{
			if(_itemFactory!=value){
				_itemFactory = value;
				var cast:MultiInstanceFactory = (_itemFactory as MultiInstanceFactory);
				if(cast){
					var defaults:Dictionary = new Dictionary();
					defaults["autoToggleSelect"] = true;
					cast.addPropertiesAt(defaults, 0);
				}
				clearRenderers();
				invalidateMeasurements();
				invalidate();
			}
		}
		/**
		 * This factory is used to generate each seperator.
		 */
		public function get separatorFactory():IInstanceFactory{
			return _separatorFactory;
		}
		public function set separatorFactory(value:IInstanceFactory):void{
			if(_separatorFactory!=value){
				_separatorFactory = value;
				clearRenderers();
				invalidateMeasurements();
				invalidate();
			}
		}
		/**
		 * Whether seperators should be shown before the first item and after the last item.
		 */
		public function get outerSeparators():Boolean{
			return _outerSeparators;
		}
		public function set outerSeparators(value:Boolean):void{
			if(_outerSeparators!=value){
				_outerSeparators = value;
				clearRenderers();
				invalidateMeasurements();
				invalidate();
			}
		}
		/**
		 * An array of objects used the populate the list.
		 */
		public function get dataProvider():Array{
			return _dataProvider;
		}
		public function set dataProvider(value:Array):void{
			if(_dataProvider!=value){
				_dataProvider = value;
				renderersInvalid = true;
				if(togglable){
					_selectionMap = new SelectionMap();
					assessSelection();
				}
				invalidateMeasurements();
				invalidate();
				this.dispatchEvent(new ControlEvent(ControlEvent.DATA_CHANGE));
				_scrollIndex = 0;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this,direction,getScrollMetrics(direction));
			}
		}
		/**
		 * @inheritDoc
		 */
		[Inspectable(type="Boolean", defaultValue="true", 
			name="Direction (vertical=true, horizontal=false)")]
		override public function get direction():String{
			return super.direction;
		}
		override public function set direction(value:String):void{
			if(super.direction!=value){
				super.direction = value;
				renderersInvalid = true;
			}
		}
		/**
		 * @inheritDoc
		 */
		override public function get width():Number{
			return super.width;
		}
		override public function set width(to:Number):void{
			if(super.width!=to){
				super.width = to;
				if(_direction==Direction.HORIZONTAL){
					renderersInvalid = true;
				}
			}
		}
		/**
		 * @inheritDoc
		 */
		override public function get height():Number{
			return super.height;
		}
		override public function set height(to:Number):void{
			if(super.height!=to){
				super.height = to;
				if(_direction==Direction.VERTICAL){
					renderersInvalid = true;
				}
			}
		}
		public function set selectionValidator(value:SelectionMapValidator):void{
			if(_selectionValidator!=value){
				if(_selectionValidator){
					_selectionValidator.subject = null;
				}
				_selectionValidator = value;
				if(_selectionValidator){
					_selectionValidator.subject = this;
					_selectionValidator.validationKey = SELECTION_VALIDATION_KEY;
				}
			}
		}
		public function get selectionValidator():SelectionMapValidator{
			return _selectionValidator;
		}
		/**
		 * The property name from which the label for each renderer should be taken
		 * from each data item.<br>
		 * For example, if each data item is something like <code>{name:"Australia",value:"AU"}</code>
		 * then the labelField should be set to "name".
		 * If no labelField (or labelFunction) is specified then both "label" and "text" will be attempted.
		 * 
		 * @see labelFunction
		 */
		public function get labelField(): String
		{
			var field: String = this._labelField;
			if (field == null && List.DEFAULT_LABEL_FIELDS.length > 0) {
				field = List.DEFAULT_LABEL_FIELDS[0];
			}
			return field;
		}
		public function set labelField(labelField: String): void
		{
			if (labelField != this._labelField)
			{
				this._labelField = labelField;
				this.assessSelection();
				this.invalidateMeasurements();
			}
		}
		/**
		 * A function which allows a custom label to be generated based on each
		 * data object for it's renderer.<br>
		 * For example, if each data item is something like <code>{venue:"Hopetoun",capacity:400}</code>.
		 * Then a labelFunction could be:<br>
		 * <code>
		 * function(data:Object):String{<br>
		 *       return data.venue+"(capacity "+data.capacity+")";<br>
		 * }</code>
		 * 
		 * @see labelField
		 */
		public function get labelFunction():Function{
			return _labelFunction;
		}
		public function set labelFunction(to:Function):void{
			if(_labelFunction != to){
				_labelFunction = to;
				assessSelection();
			}
		}
		/**
		 * Returns the label of the first selected item.
		 */
		public function get selectedLabel():String{
			var sel: * = this.selectedItem;
			if (sel){
				return this.getLabel(sel);
			}
			return null;
		}
		/**
		 * The togglable property specifies whether the items in the list are selectable (togglable).
		 * This property will be ignored if there is a validator set.
		 */
		[Inspectable(name="Togglable", type="Boolean", defaultValue=true)]
		public function get togglable():Boolean{
			return _togglable;
		}
		public function set togglable(value:Boolean):void{
			if(_togglable != value){
				_togglable = value;
				if(value){
					_selectionMap = new SelectionMap();
				}else{
					_selectionMap = null;
				}
				assessSelection();
			}
		}
		/**
		 * Returns the index of the first selected item.
		 */
		public function get selectedIndex():int{
			var sel:Array = selectedIndices;
			return sel.length?sel[0]:-1;
		}
		public function set selectedIndex(to:int):void{
			_lastSelected = to;
			if (to >= 0) {
				selectedIndices = [to];
			} else {
				selectedIndices = [];
			}
		}
		/**
		 * Returns the first selected data object.
		 */
		public function get selectedItem():*{
			var selIndex:int = selectedIndex;
			return (_dataProvider && selIndex!=-1?this._dataProvider[selIndex]:null);
		}
		public function get selectedItems():*{
			var items: Array = new Array();
			var selIndices: Array = selectedIndices;
			for (var i: uint = 0; i < selIndices.length; ++i){
				var index: int = selIndices[i];
				items.push(this._dataProvider[index]);
			}
			return items;
		}
		/**
		 * Returns an array of the selected indices.
		 */
		public function get selectedIndices():Array{
			return togglable?_selectionMap.getAllSelected():(_lastSelected!=-1?[_lastSelected]:[]);
		}
		public function set selectedIndices(value:Array):void{
			if (value.length > 0) {
				_lastSelected = value[0];
			} else {
				_lastSelected = -1;
			}
			if(togglable){
				_selectionMap.setAllSelected(value,true);
				assessSelection();
				if(_centerSelection){
					if(value.length)centerTo(value[0]);
					else centerTo(0);
				}
				dispatchEvent(new ListEvent(selectedItem,selectedIndex,selectedItems,selectedIndices, ListEvent.SELECTION_CHANGE));
			}
		}
		/**
		 * The amount of renderers currently in view.
		 */
		public function get displayedCells():Number{
			validate();
			return _itemRenderers.length;
		}
		/**
		 * The total amount of renderers required for the data provider.
		 */
		public function get totalCells():Number{
			return _dataProvider.length;
		}
		/**
		 * The amount of items currently selected (generally used for validation).
		 */
		override public function getValidationValue(validityKey:String=null):*{
			switch(validityKey){
				case SELECTION_VALIDATION_KEY:
					return _selectionMap;
				default:
					return selectedItem;
			}
		}
		override public function setValidationValue(value:*, validityKey:String=null):void{
			switch(validityKey){
				case SELECTION_VALIDATION_KEY:
					if(togglable){
						_selectionMap = value;
						invalidate();
					}
				default:
					// ignore, can't set selectedItem
			}
		}
		
		public function get scrollIndex():int{
			return _scrollIndex;
		}
		public function set scrollIndex(value:int):void{
			if(value<0)value = 0;
			else if(value>_dataProvider.length-1)value = _dataProvider.length-1
			if(_scrollIndex != value){
				_scrollIndex = value;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this,direction,getScrollMetrics(direction));
				renderersInvalid = true;
				invalidate();
			}
		}
		
		protected var _selectionValidator:SelectionMapValidator;
		protected var _centerSelection:Boolean = false;
		protected var _itemFactory:IInstanceFactory;
		//protected var _separatorPrototype:Class;
		protected var _separatorFactory:IInstanceFactory;
		protected var _dataProvider:Array;
		protected var _itemRenderers:Array = [];
		protected var _labelFunction:Function;
		protected var _scrollIndex:int = 0; // index of first item shown
		protected var _selectionMap:SelectionMap;
		protected var _outerSeparators:Boolean = false;
		protected var _firstSeparator:DisplayObject;
		protected var _otherSeparators:Array = [];
		protected var _togglable:Boolean = true;
		protected var _lastSelected:int = -1;
		protected var _labelField: String;
		
		/* _measurements is an array of points, parallel to data,
		x value is the measured distance from the start of the list to the start of the renderer
		y value is the measured distance from the start of the list to the end of the renderer
		*/
		protected var _measurements:Array;
		protected var _measuredListSize:Number;// either measuredWidth or measeuredHeight minus padding
		
		protected var renderersInvalid:Boolean = false;
		
		public function List(){
			super();
			_selectionMap = new SelectionMap();
			_selectionValidator = new SelectionMapValidator(this,SELECTION_VALIDATION_KEY,true);
			_selectionValidator.maximumSelected = 1;
		}
		override protected function removeCompiledClips():void{
			var button:ISelectableControl;
			for(var i:int=0; i<numChildren; ++i){
				var child:DisplayObject = getChildAt(i);
				if(child is ISelectableControl){
					if(!button){
						button = (child as ISelectableControl);
						removeChild(child);
						break;
					}
				}
			}
			if(button){
				var klass: Class = ReflectionUtils.getClass(button);
				var protoItem:ISelectableControl = (new klass() as ISelectableControl);
				if(protoItem && !_itemFactory){
					var factory:MultiInstanceFactory = new MultiInstanceFactory(klass);
					var origProps:Dictionary = new Dictionary();
					for(var j:String in button){
						var value:* = button[j];
						origProps[j] = value;
					}
					factory.addProperties(origProps);
					itemFactory = factory;
				}
			}
		}
		protected function clearRenderers():void{
			var length:int = _itemRenderers.length;
			for(var i:int=0; i<length; ++i){
				removeChild(_itemRenderers[i]);
			}
			_itemRenderers = [];
		}
		override protected function draw():void{
			if(renderersInvalid && _itemFactory){
				createRenderers();
			}
			fillRenderers();
			//dispatchEvent(new ControlEvent(ControlEvent.SCROLL)); // must this really be here
			super.draw();
			// Need to call this because the draw of StackView can resize elements
			//this.invalidateMeasurements();
		}
		
		override protected function measure(): void
		{
			_measurements = [];
			_measuredListSize = 0;
			if (this.dataProvider != null && this.dataProvider.length > 0 && this._itemFactory != null)
			{
				var v:Boolean = _direction == Direction.VERTICAL;
				var protoItem: ISelectableControl = getRenderer();
				protoItem.labelField.autoSize = TextFieldAutoSize.LEFT;
				this.addChild(protoItem.display);
				
				var protoSeparator:DisplayObject = getSeparator();
				var sepSize: Number = (protoSeparator?(v?protoSeparator.height:protoSeparator.width): 0);
				
				var dp: Array = this.dataProvider;
				
				var outer:Boolean = (this._outerSeparators && protoSeparator);
				
				_measuredListSize = outer?(sepSize + this.gap):0;
				
				var secondarySize: Number = (protoSeparator?(v?protoSeparator.width:protoSeparator.height): 0);
				
				if (dp != null)
				{
					for (var i: uint = 0; i < dp.length; ++i)
					{
						var data: * = dp[i];
						var renderer:ISelectableControl = _itemRenderers[i-_scrollIndex];
						if(!renderer){
							renderer = protoItem;
						}
						renderer.data = data;
						renderer.label = getLabel(data);
						
						var measurement:Point = new Point(_measuredListSize);
						var size:Number;
						if (allowAutoSize){
							size = (v?renderer.measuredHeight:renderer.measuredWidth);
						}
						if(isNaN(size)){
							size = (v?renderer.height:renderer.width);
						}
						_measuredListSize += size;
						measurement.y = _measuredListSize;
						_measurements[i] = measurement;
						
						secondarySize = Math.max(secondarySize, Math.max((v?renderer.measuredWidth:renderer.measuredHeight)));
						
						if (i < dp.length - 1)
						{
							_measuredListSize += gap;
							if (sepSize > 0)
							{
								_measuredListSize += sepSize + this.gap;
							}
						}
					}
				}
				
				this.removeChild(protoItem.display);
				
				_measuredListSize += (outer?(sepSize + this.gap):0);
				
				if (v)
				{
					this._measuredWidth = secondarySize;
					this._measuredHeight = _measuredListSize;
				}
				else
				{
					this._measuredWidth = _measuredListSize;
					this._measuredHeight = secondarySize;
				}
				this._measuredHeight += this._topPadding + this._bottomPadding;
				this._measuredWidth += this._leftPadding + this._rightPadding;
			}
			else
			{
				this._measuredWidth = 0;
				this._measuredHeight = 0;
			}
		}
		
		/**
		 * invalidateList will refill the renderers with data.
		 * It can be used to manually refresh the labels.
		 */
		public function invalidateList():void{
			renderersInvalid = true;
			invalidate();
		}
		protected function createRenderers():void{
			var protoSeparator:DisplayObject = getSeparator();
			var maxItems:int = getMaxRenderers(protoSeparator);
			
			
			if(_outerSeparators ){
				if(!_firstSeparator){
					addToStack(protoSeparator);
					_firstSeparator = protoSeparator;
					container.setChildIndex(_firstSeparator,0);
				}
			}else if(_firstSeparator){
				removeFromStack(_firstSeparator);
			}
			for(var i:int=_itemRenderers.length; i<maxItems; ++i){
				var renderer:ISelectableControl = getRenderer();
				addToStack(renderer.display);
				_itemRenderers.push(renderer);
				container.setChildIndex(renderer.display,i);
			}
			// Remove item renderers (for if size has been shrunk since last draw)
			while(_itemRenderers.length>maxItems){
				renderer = _itemRenderers[maxItems];
				renderer.removeEventListener(MouseEvent.CLICK, onRendererClick);
				removeFromStack(renderer.display);
				_itemRenderers.splice(maxItems,1);
			}
			if(protoSeparator){
				var max:Number = maxItems;
				if (!_outerSeparators) {
					max--;
				}
				else
				{
					max++;
				}
				max = Math.max(max, 0);
				for(i=_otherSeparators.length; i<max; ++i){
					var separator:DisplayObject = getSeparator();
					addToStack(separator);
					_otherSeparators.push(separator);
					container.setChildIndex(separator,(i*2)+(_outerSeparators?0:1));
				}
				while(_otherSeparators.length>max){
					removeFromStack(_otherSeparators[max]);
					_otherSeparators.splice(max,1);
				}
			}
			renderersInvalid = false;
		}
		protected function getMaxRenderers(protoSeparator:DisplayObject):int{
			ensureMeasurements();
			var ret:int = 0;
			var v:Boolean = _direction == Direction.VERTICAL;
			var maxSize:Number = (v?height-_topPadding-_bottomPadding:width-_leftPadding-_rightPadding);
			if(maxSize && _measurements.length){
				var offset:Number = _measurements[_scrollIndex].x;
				while((_scrollIndex+ret)<_measurements.length && _measurements[_scrollIndex+ret].y-offset<=maxSize){
					ret++;
				}
			}
			return ret+1;
		}
		protected function fillRenderers():void{
			var v:Boolean = _direction == Direction.VERTICAL;
			if(_firstSeparator){
				if(v){
					_firstSeparator.width = width-_leftPadding-_rightPadding;
					_firstSeparator.scaleY = 1;
				}else{
					_firstSeparator.height = height-_topPadding-_bottomPadding;
					_firstSeparator.scaleX = 1;
				}
			}
			var length:int = _itemRenderers.length;
			for(var i:int=0; i<length; ++i){
				var renderer:ISelectableControl = _itemRenderers[i];
				var separator:DisplayObject = _otherSeparators[i];
				if(_dataProvider){
					renderer.data = _dataProvider[_scrollIndex+i];
					renderer.selected = (togglable)?_selectionMap.isSelected(_scrollIndex+i):false;
				}else{
					renderer.data = null;
					renderer.selected = false;
				}
				if(renderer.data){
					renderer.visible = true;
					renderer.label = getLabel(renderer.data);
					if(separator != null) {
						if (i < (_dataProvider.length - 1) || _outerSeparators) {
							separator.visible = true;
						}else{
							separator.visible = false;
						}
					}
				}else{
					renderer.visible = false;
					renderer.label = "";
					if(separator)separator.visible = false;
				}
				if(v){
					renderer.width = width-_leftPadding-_rightPadding;
					if(separator){
						separator.width = renderer.width;
						separator.scaleY = 1;
					}
				}else{
					renderer.height = height-_topPadding-_bottomPadding;
					if(separator){
						separator.height = renderer.height;
						separator.scaleX = 1;
					}
				}
			}
		}
		public function getLabel(data:*):String{
			var label: String = "";
			if(data is String || data is Number)
			{
				label = data;
			}
			else if(data is Object)
			{
				if(this._labelFunction!=null)
				{
					label = this._labelFunction(data).toString();
				}
				else if (this._labelField != null)
				{
					label = data[this._labelField];
				}
				else
				{
					var found: Boolean = false;
					for (var i: uint = 0; i < List.DEFAULT_LABEL_FIELDS.length && !found; ++i)
					{
						var field: String = List.DEFAULT_LABEL_FIELDS[i];
						var nativeLabel: String = null;
						var hasField: Boolean = true;
						try{
							nativeLabel=data[field];
						}catch (e: ReferenceError){
							hasField = false;
						}
						if (hasField){
							label = nativeLabel;
							found = true;
						}
					}
				}
			}
			return label;
		}
		protected function getSeparator():DisplayObject{
			return _separatorFactory?_separatorFactory.createInstance():null;
		}
		protected function getRenderer(): ISelectableControl{
			var ret:ISelectableControl = (_itemFactory.createInstance() as ISelectableControl);
			if (ret != null){
				ret.addEventListener(MouseEvent.CLICK, onRendererClick, false, 0, true);
			}
			return ret;
		}
		
		protected function onRendererClick(e:MouseEvent):void{
			var renderer:ISelectableControl = (e.currentTarget as ISelectableControl);
			var index:int = findIndex(renderer)+_scrollIndex;
			_lastSelected = index;
			if(_centerSelection)centerTo(index);
			_selectionMap.setSelected(index,renderer.selected);
			assessSelection();
			
			var clickEvent: ListEvent = new ListEvent(selectedItem,selectedIndex,selectedItems,selectedIndices, ListEvent.ITEM_CLICK);
			clickEvent.targetItem = renderer.data;
			dispatchEvent(clickEvent);
			dispatchEvent(new ListEvent(selectedItem,selectedIndex,selectedItems,selectedIndices, ListEvent.SELECTION_CHANGE));
			dispatchEvent(new ListEvent(selectedItem,selectedIndex,selectedItems,selectedIndices, ListEvent.USER_SELECTION_CHANGE));
		}
		public function centerToSelection(): void {
			this.centerTo(this.selectedIndex);
		}
		protected function centerTo(index:Number):void{
			var displayed:Number = displayedCells;
			scrollIndex = Math.min(Math.max(index-Math.round(displayed/2),0),totalCells-displayed);
		}
		protected function findIndex(renderer: ISelectableControl):int{
			var length:int = _itemRenderers.length;
			for(var i:int=0; i<length; ++i){
				if(_itemRenderers[i]==renderer)return i;
			}
			return -1;
		}
		protected function assessSelection():void{
			if(togglable){
				dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_VALUE_CHANGED, SELECTION_VALIDATION_KEY));
			}
			
			var length:int = _itemRenderers.length;
			for(var i:int=0; i<length; ++i){
				var renderer: ISelectableControl = _itemRenderers[i];
				renderer.selected = togglable?_selectionMap.isSelected(_scrollIndex+i):false;
			}
		}
		
		// IScrollable implementation
		override public function addScrollWheelListener(direction:String):Boolean{
			return (direction==this.direction);
		}
		override public function getScrollMetrics(direction:String):ScrollMetrics{
			if(direction==this.direction){
				validate();
				var ret:ScrollMetrics = new ScrollMetrics(0,dataProvider?dataProvider.length:0,_itemRenderers.length);
				ret.value = _scrollIndex;
				return ret;
			}else{
				return super.getScrollMetrics(direction);
			}
		}
		override public function setScrollMetrics(direction:String,metrics:ScrollMetrics):void{
			if(direction==this.direction){
				_scrollIndex = metrics.value;
				renderersInvalid = true;
				invalidate();
			}else{
				return super.setScrollMetrics(direction,metrics);
			}
		}
		override protected function allowDrawMeasurement():Boolean{
			return false;
		}
	}
}