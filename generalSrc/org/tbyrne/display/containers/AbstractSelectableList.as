package org.tbyrne.display.containers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.debug.logging.Log;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.grid.RendererGridLayout;
	import org.tbyrne.display.layout.list.ListLayoutInfo;
	import org.tbyrne.display.scrolling.IScrollMetrics;
	import org.tbyrne.instanceFactory.IInstanceFactory;
	
	use namespace DisplayNamespace;
	
	public class AbstractSelectableList extends AbstractList
	{
		public function get dataProvider():*{
			return _layout.dataProvider;
		}
		public function set dataProvider(value:*):void{
			attemptInit();
			if(_layout.dataProvider != value){
				_layout.dataProvider = value;
				if(_protoRenderer)checkDataSelection();
				checkAutoScroll();
			}
		}
		/**
		 * selectedData is mapped by the data's index in the dataProvider.
		 */
		public function get selectedData() : Dictionary{
			return _selectedData;
		}
		
		public function get selectedItem() : *{
			checkIsBound();
			if(_selectedIndices.length==1){
				return _selectedData[_selectedIndices[0]];
			}else{
				return null;
			}
		}
		public function get selectedIndex():int{
			return _selectedIndices.length?_selectedIndices[0]:-1;
		}
		public function set selectedIndex(value:int):void{
			if(value==-1)selectedIndices = [];
			else selectedIndices = [value];
		}
		
		public function set selectedIndices(value: Array):void{
			if(_selectedIndices!=value){
				if(!_protoRenderer){
					Log.log(Log.ERROR, "selectedIndices cannot be set without a renderer that implements ISelectableRenderer");
				}
				
				var valueCount:int;
				var safeIndices:Array = [];
				var index:int;
				//var selData:IBooleanConsumer;
				var change:Boolean;
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
				var data:*;
				while(i<_selectedIndices.length && deselectCount>0){
					index = _selectedIndices[index];
					if(safeIndices.indexOf(index)==-1){
						_selectedIndices.splice(i,1);
						data = _layout.getDataAt(index);
						setDataSelected(index, data, false);
						delete _selectedData[index];
						--_selectedCount;
						-- deselectCount;
						change = true;
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
					data = _layout.getDataAt(index);
					setDataSelected(index, data, true);
					_selectedData[index] = data;
					change = true;
					++_selectedCount;
					--valueCount;
				}
				checkAutoScroll();
				if(change){
					_selectionChangeAct.perform(this, _selectedIndices, _selectedData);
				}
			}
		}
		public function get selectedIndices() : Array{
			return _selectedIndices;
		}
		/**
		 * handler(listBox:AbstractSelectableList, selectedIndices:Array, selectedData:Dictionary)
		 */
		public function get selectionChangeAct() : IAct{
			return _selectionChangeAct;
		}
		
		protected var _maxSelected:int = 1;
		protected var _minSelected:int = 0;
		
		private var _selectedData:Dictionary = new Dictionary();
		private var _selectedIndices:Array = [];
		private var _selectedCount:int = 0;
		
		protected var _scrollByLine:Boolean;
		protected var _autoScrollToSelection:Boolean;
		protected var _protoRenderer:ISelectableRenderer; // used to which data is selected 
		
		private var _selectionChangeAct:Act = new Act();
		
		// remember, in some cases (CascadingMenuBar for example), selected renderers and selected data are different.
		//private var _selectedRenderers:Dictionary = new Dictionary(); 
		
		
		public function AbstractSelectableList(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			_layout.setRendererDataAct.addHandler(onRendererDataSet);
		}
		override protected function onAddRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			super.onAddRenderer(layout, renderer);
			var selRenderer:ISelectableRenderer = (renderer as ISelectableRenderer);
			if(selRenderer){
				selRenderer.selectedChanged.addHandler(onRendererSelect);
			}
		}
		protected function onRendererDataSet(layout:RendererGridLayout, renderer:ILayoutView, data:*, dataField:String) : void{
			// in case 'useDataForSelected' is false, here we refresh the selected state
			var selRenderer:ISelectableRenderer = (renderer as ISelectableRenderer);
			if(selRenderer){
				var dataIndex:int = getDataIndex(data);
				selRenderer.selected = (_selectedIndices.indexOf(dataIndex)!=-1);
			}
		}
		protected function getDataIndex(data:*) : int{
			var layoutInfo:ListLayoutInfo = _layout.getDataLayout(data) as ListLayoutInfo;
			return layoutInfo.listIndex;
		}
		override protected function onRemoveRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			super.onRemoveRenderer(layout, renderer);
			var selRenderer:ISelectableRenderer = (renderer as ISelectableRenderer);
			if(selRenderer){
				selRenderer.selectedChanged.removeHandler(onRendererSelect);
			}
		}
		/*protected function onDataSelectedChanged(from:IBooleanProvider) : void{
			var selected:Boolean = tryRendererSelect(getDataIndex(from), from, from.booleanValue);
			var consumer:IBooleanConsumer = (from as IBooleanConsumer);
			if(consumer){
				consumer.booleanValue = selected;
			}
		}*/
		protected function tryRendererSelect(dataIndex:int, data:*, selected:Boolean) : Boolean{
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
							var otherData:* = _selectedData[otherDataIndex];
							setDataSelected(otherDataIndex, otherData, false);
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
				if(_selectedCount>_minSelected){
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
		protected function setDataSelected(dataIndex:int, data:*, value:Boolean) : void{
			var renderer:ISelectableRenderer = _layout.getRenderer(dataIndex) as ISelectableRenderer;
			if(!renderer){
				renderer = _protoRenderer;
				renderer[_layout.dataField] = data;
			}
			renderer.selected = value;
		}
		/*
		In most renderers there is a relationship between the renderer's selection state
		and the data's booleanValue property. In some circumstances this is undesirable,
		e.g. so items can be closed and selected or open and unselected. This relationship
		is normally governed by the 'useDataForSelection' property (within the ToggleButton
		class).
		*/
		protected function onRendererSelect(renderer:ISelectableRenderer) : void{
			var data:* = renderer[_layout.dataField];
			var dataIndex:int = getDataIndex(data);
			renderer.selected = tryRendererSelect(dataIndex, data, renderer.selected);
		}
		override protected function updateFactory(factory:IInstanceFactory, dataField:String):void{
			super.updateFactory(factory, dataField);
			if(_protoRenderer && _layout.dataField){
				_protoRenderer[_layout.dataField] = null;
				_protoRenderer = null;
			}
			if(factory && dataField){
				_protoRenderer = factory.createInstance() as ISelectableRenderer;
				if(_protoRenderer)checkDataSelection();
			}
		}
		/**
		 * loops though data and, using the proto renderer, determines what is currently
		 * selected.
		 */
		protected function checkDataSelection():void{
			var dataCount:int = _layout.getDataCount();
			var change:Boolean = (_selectedCount>0);
			_selectedCount = 0;
			_selectedData = new Dictionary();
			_selectedIndices = [];
			for(var i:int=0; i<dataCount; i++){
				var data:* = _layout.getDataAt(i);
				_protoRenderer[_layout.dataField] = data;
				if(_protoRenderer.selected){
					_selectedData[i] = data;
					_selectedIndices[_selectedCount] = i;
					++_selectedCount;
					change = true;
				}
			}
			if(!validateSelectionCount() && change){
				_selectionChangeAct.perform(this, _selectedIndices, _selectedData);
			}
		}
		/**
		 * returns true if selection was changed
		 */
		public function validateSelectionCount():Boolean{
			attemptInit();
			var change:Boolean;
			var data:*;
			if(_selectedCount>_maxSelected){
				while(_selectedCount>_maxSelected && _selectedIndices.length>0){
					var dataIndex:int = _selectedIndices.shift();
					delete _selectedData[dataIndex];
					--_selectedCount;
					
					data = _selectedData[dataIndex];
					setDataSelected(dataIndex, data, false);
					change = true;
				}
			}else{
				var i:int=0;
				var len:int = _layout.getDataCount();
				while(_selectedCount<_minSelected && i<len){
					if(_selectedIndices.indexOf(i)==-1){
						_selectedIndices.push(i);
						data = _layout.getDataAt(i);
						_selectedData[i] = data;
						++_selectedCount;
						
						setDataSelected(i, data, true);
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
		/**
		 * checkAutoScroll scrolls the list to bring an item into view when it is selected.
		 */
		protected function checkAutoScroll():void{
			if(_autoScrollToSelection && _selectedIndices.length){
				_selectedIndices.sort();
				var metrics:IScrollMetrics = getScrollMetrics(_layout.flowDirection);
				var changed:Boolean;
				var isVert:Boolean = (_layout.flowDirection==Direction.VERTICAL);
				var i:int;
				var minValue:Number;
				var newValue:Number;
				var value:Number;
				if(_scrollByLine){
					var autoScrollPoint:Point = new Point();
					for each(i in _selectedIndices){
						_layout.getDataCoords(i,autoScrollPoint);
						if(isVert){
							value = autoScrollPoint.y;
						}else{
							value = autoScrollPoint.x;
						}
						if(value<metrics.scrollValue){
							metrics.scrollValue = value;
							changed = true;
							break;
						}else if(value>metrics.scrollValue+(metrics.pageSize-1)){
							newValue = value-(metrics.pageSize-1);
							if(!isNaN(minValue) && newValue>minValue){
								metrics.scrollValue = minValue;
							}else{
								metrics.scrollValue = newValue;
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
							metrics.scrollValue += value;
							changed = true;
							break;
						}else if(endValue>metrics.pageSize){
							newValue = metrics.scrollValue+endValue-metrics.pageSize;
							if(!isNaN(minValue) && newValue>minValue){
								metrics.scrollValue = minValue;
							}else{
								metrics.scrollValue = newValue;
							}
							changed = true;
							break;
						}else{
							minValue = value;
						}
					}
				}
			}
		}
	}
}