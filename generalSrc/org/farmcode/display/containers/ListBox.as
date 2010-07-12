package org.farmcode.display.containers
{
	import org.farmcode.display.scrolling.ScrollMetrics;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.grid.RendererGridLayout;
	import org.farmcode.display.layout.list.ListLayoutInfo;
	import org.farmcode.instanceFactory.IInstanceFactory;
	
	public class ListBox extends AbstractList
	{
		
		public function get dataProvider():*{
			return _layout.dataProvider;
		}
		public function set dataProvider(value:*):void{
			if(_layout.dataProvider != value){
				var dataCount:int = _layout.getDataCount();
				var i:int;
				var selectableData:IBooleanProvider;
				for(i=0; i<dataCount; i++){
					selectableData = (_layout.getDataAt(i) as IBooleanProvider);
					if(selectableData){
						selectableData.booleanValueChanged.removeHandler(onDataSelectedChanged);
					}
				}
				var change:Boolean = (_selectedCount>0);
				_selectedCount = 0;
				_selectedData = new Dictionary();
				_selectedIndices = [];
				_layout.dataProvider = value;
				dataCount = _layout.getDataCount();
				for(i=0; i<dataCount; i++){
					selectableData = (_layout.getDataAt(i) as IBooleanProvider);
					if(selectableData){
						selectableData.booleanValueChanged.addHandler(onDataSelectedChanged);
						if(selectableData.booleanValue){
							_selectedData[i] = selectableData;
							_selectedIndices[_selectedCount] = i;
							++_selectedCount;
							change = true;
						}
					}
				}
				if(!validateSelectionCount() && change){
					_selectionChangeAct.perform(this, _selectedIndices, _selectedData);
				}
				checkAutoScroll();
			}
		}
		
		public function get dataField():String{
			return _dataField;
		}
		public function set dataField(value:String):void{
			if(_dataField != value){
				_dataField = value;
				assessFactory();
			}
		}
		
		public function get maxSelected():int{
			return _maxSelected;
		}
		public function set maxSelected(value:int):void{
			if(_maxSelected!=value){
				_maxSelected = value;
				validateSelectionCount();
			}
		}
		
		public function get minSelected():int{
			return _minSelected;
		}
		public function set minSelected(value:int):void{
			if(_minSelected!=value){
				_minSelected = value;
				validateSelectionCount();
			}
		}
		
		public function get selectedItem() : *{
			checkIsBound();
			if(_selectedIndices.length==1){
				return _selectedData[_selectedIndices[0]];
			}else{
				return null;
			}
		}
		public function get selectedData() : Dictionary{
			return _selectedData;
		}
		
		public function get selectedIndex():int{
			return _selectedIndices.length?_selectedIndices[0]:-1;
		}
		public function set selectedIndex(value:int):void{
			selectedIndices = [value];
		}
		
		public function set selectedIndices(value: Array):void{
			if(_selectedIndices!=value){
				var valueCount:int;
				var safeIndices:Array = [];
				var index:int;
				var selData:IBooleanConsumer;
				if(value){
					// remove any duplication between old and new selection
					var i:int=0;
					while( i<value.length ){
						index = value[i];
						if(_selectedIndices.indexOf(index)!=-1){
							safeIndices.push(index);
							_selectedIndices.splice(i,1);
						}else{
							i++;
						}
					}
					valueCount = value.length;
				}else{
					valueCount = 0;
				}
				
				// deselect old items until _minSelected is satisfied
				var deselectCount:int = _selectedIndices.length-safeIndices.length;
				if(_minSelected>valueCount){
					deselectCount -= (_minSelected-valueCount);
				}
				i=0;
				while(i<_selectedIndices.length && deselectCount>0){
					index = _selectedIndices[index];
					if(safeIndices.indexOf(index)==-1){
						_selectedIndices.splice(i,1);
						selData = (_layout.getDataAt(index) as IBooleanConsumer);
						if(selData){
							selData.booleanValue = false;
						}
						delete _selectedData[index];
						--_selectedCount;
						-- deselectCount;
					}else{
						i++;
					}
				}
				
				// select new items until _maxSelected is satisfied
				if(_maxSelected<valueCount+_selectedCount){
					valueCount -= (_maxSelected-(valueCount+_selectedCount));
				}
				while(valueCount>0){
					index = value.shift();
					_selectedIndices.push(index);
					var data:* = _layout.getDataAt(index);
					_selectedData[index] = data;
					selData = (data as IBooleanConsumer);
					if(selData){
						selData.booleanValue = true;
					}
					++_selectedCount;
					--valueCount;
				}
				checkAutoScroll();
			}
		}
		public function get selectedIndices() : Array{
			return _selectedIndices;
		}
		/**
		 * handler(listBox:ListBox, selectedIndices:Array, selectedData:Dictionary)
		 */
		public function get selectionChangeAct() : IAct{
			return _selectionChangeAct;
		}
		
		public function get scrollByLine():Boolean{
			return _layout.horizontalScrollByLine && _layout.verticalScrollByLine;
		}
		public function set scrollByLine(value:Boolean):void{
			_layout.horizontalScrollByLine = value;
			_layout.verticalScrollByLine = value;
		}
		
		public function get autoScrollToSelection():Boolean{
			return _autoScrollToSelection;
		}
		public function set autoScrollToSelection(value:Boolean):void{
			if(_autoScrollToSelection!=value){
				_autoScrollToSelection = value;
				checkAutoScroll();
			}
		}
		
		private var _autoScrollToSelection:Boolean;
		private var _scrollByLine:Boolean;
		private var _maxSelected:int = 1;
		private var _minSelected:int = 0;
		
		private var _selectedData:Dictionary = new Dictionary();
		private var _selectedIndices:Array = [];
		private var _selectedCount:int = 0;
		
		private var _selectionChangeAct:Act = new Act(); 
		
		
		public function ListBox(asset:IDisplayAsset=null){
			super(asset);
			_layout.equaliseCellWidths = true;
		}
		override protected function onAddRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			super.onAddRenderer(layout, renderer);
			var selRenderer:ISelectableRenderer = (renderer as ISelectableRenderer);
			if(selRenderer){
				selRenderer.selectedChanged.addHandler(onRendererSelect);
			}
		}
		override protected function onRemoveRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			super.onRemoveRenderer(layout, renderer);
			var selRenderer:ISelectableRenderer = (renderer as ISelectableRenderer);
			if(selRenderer){
				selRenderer.selectedChanged.removeHandler(onRendererSelect);
			}
		}
		protected function onDataSelectedChanged(from:IBooleanProvider) : void{
			var selected:Boolean = tryDataSelect(getDataIndex(from), from, from.booleanValue);
			var consumer:IBooleanConsumer = (from as IBooleanConsumer);
			if(consumer){
				consumer.booleanValue = selected;
			}
		}
		protected function onRendererSelect(renderer:ISelectableRenderer) : void{
			var data:* = renderer[_layout.dataField];
			renderer.selected = tryDataSelect(getDataIndex(data), data, renderer.selected);
		}
		protected function tryDataSelect(dataIndex:int, data:*, selected:Boolean) : Boolean{
			var selIndex:int = _selectedIndices.indexOf(dataIndex);
			if((selIndex!=-1 && selected) ||
				(selIndex==-1 && !selected)){
				// this happens when renderers are scrolled and reselect themselves
				return selected;
			}
			var change:Boolean;
			if(selected){
				if(_maxSelected>0){
					change = true;
					_selectedData[dataIndex] = data;
					_selectedIndices.push(dataIndex);
					++_selectedCount;
					var i:int=0;
					while(_selectedCount>_maxSelected){
						var otherDataIndex:int = _selectedIndices[i];
						if(otherDataIndex!=dataIndex){
							_selectedIndices.splice(i,1);
							var otherData:IBooleanConsumer = _selectedData[otherDataIndex] as IBooleanConsumer;
							if(otherData){
								otherData.booleanValue = false;
							}
							delete _selectedData[otherDataIndex];
							--_selectedCount;
						}else{
							i++;
						}
					}
				}else{
					selected = false;
				}
			}else{
				if(_selectedCount>=_minSelected){
					change = true;
					_selectedIndices.splice(selIndex,1);
					delete _selectedData[dataIndex];
					--_selectedCount;
				}else{
					selected = true;
				}
			}
			if(change){
				_selectionChangeAct.perform(this,_selectedIndices,_selectedData);
				checkAutoScroll();
			}
			return selected;
		}
		protected function getDataIndex(data:*) : int{
			var layoutInfo:ListLayoutInfo = _layout.getDataLayout(data) as ListLayoutInfo;
			return layoutInfo.listIndex;
		}
		override protected function updateFactory(factory:IInstanceFactory, dataField:String):void{
			super.updateFactory(factory,dataField);
			validateSelectionCount();
		}
		/**
		 * returns true if selection was changed
		 */
		public function validateSelectionCount():Boolean{
			var change:Boolean;
			var selectableData:IBooleanConsumer
			if(_selectedCount>_maxSelected){
				while(_selectedCount>_maxSelected && _selectedIndices.length>0){
					var dataIndex:int = _selectedIndices.shift();
					delete _selectedData[dataIndex];
					--_selectedCount;
					
					selectableData = _selectedData[dataIndex] as IBooleanConsumer;
					if(selectableData){
						selectableData.booleanValue = false;
					}
					change = true;
				}
			}else{
				var i:int=0;
				var len:int = _layout.getDataCount();
				while(_selectedCount<_minSelected && i<len){
					if(_selectedIndices.indexOf(i)==-1){
						_selectedIndices.push(i);
						var data:* = _layout.getDataAt(i);
						_selectedData[i] = data;
						++_selectedCount;
						
						selectableData = (data as IBooleanConsumer);
						if(selectableData){
							selectableData.booleanValue = true;
						}
						change = true;
					}
					++i;
				}
			}
			if(change && _selectionChangeAct){
				_selectionChangeAct.perform(this, _selectedIndices, _selectedData);
				checkAutoScroll();
			}
			return change;
		}
		protected function checkAutoScroll():void{
			if(_autoScrollToSelection && _selectedIndices.length){
				_selectedIndices.sort();
				var metrics:ScrollMetrics = getScrollMetrics(_layout.flowDirection);
				var changed:Boolean;
				var isVert:Boolean = (_layout.flowDirection==Direction.VERTICAL);
				var i:int;
				var minValue:Number;
				var newValue:Number;
				var value:Number;
				if(scrollByLine){
					var autoScrollPoint:Point = new Point();
					for each(i in _selectedIndices){
						_layout.getDataCoords(i,autoScrollPoint);
						if(isVert){
							value = autoScrollPoint.y;
						}else{
							value = autoScrollPoint.x;
						}
						if(value<metrics.value){
							metrics.value = value;
							changed = true;
							break;
						}else if(value>metrics.value+(metrics.pageSize-1)){
							newValue = value-(metrics.pageSize-1);
							if(!isNaN(minValue) && newValue>minValue){
								metrics.value = minValue;
							}else{
								metrics.value = newValue;
							}
							changed = true;
							break;
						}else{
							minValue = value;
						}
					}
				}else{
					var autoScrollRect:Rectangle = new Rectangle();
					var endValue:Number;
					
					for each(i in _selectedIndices){
						_layout.getDataPosition(i,autoScrollRect);
						if(isVert){
							value = autoScrollRect.top;
							endValue = autoScrollRect.bottom;
						}else{
							value = autoScrollRect.left;
							endValue = autoScrollRect.right;
						}
						if(value<0){
							metrics.value += value;
							changed = true;
							break;
						}else if(endValue>metrics.pageSize){
							newValue = metrics.value+endValue-metrics.pageSize;
							if(!isNaN(minValue) && newValue>minValue){
								metrics.value = minValue;
							}else{
								metrics.value = newValue;
							}
							changed = true;
							break;
						}else{
							minValue = value;
						}
					}
				}
				if(changed){
					_layout.setScrollMetrics(_layout.flowDirection,metrics);
				}
			}
		}
	}
}