package org.tbyrne.display.containers.accordionGrid
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.tbyrne.collections.ICollection;
	import org.tbyrne.collections.IIterator;
	import org.tbyrne.collections.IIterator2D;
	import org.tbyrne.collections.linkedList.LinkedListConverter;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.containers.accordion.AbstractAccordionView;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.display.layout.accordion.AccordionLayout;
	import org.tbyrne.display.layout.grid.RendererGridLayout;
	import org.tbyrne.instanceFactory.IInstanceFactory;
	import org.tbyrne.instanceFactory.SimpleInstanceFactory;

	public class AccordionGridView extends AbstractAccordionView
	{
		private const CELL_RENDERER:String = "cellRenderer";
		
		public function get dataProvider():IAccordionGridDataProvider{
			return _dataProvider;
		}
		public function set dataProvider(value:IAccordionGridDataProvider):void{
			if(_dataProvider!=value){
				if(_gridDataCollection){
					_gridDataCollection.collectionChanged.removeHandler(onCollectionChanged);
				}
				_dataProvider = value;
				if(_dataProvider){
					_accordionDataCollection = (_dataProvider.accordionData as ICollection);
					if(!_accordionDataCollection){
						_accordionDataCollection = LinkedListConverter.fromNativeCollection(_dataProvider.accordionData);
					}
					if(_accordionDataCollection){
						_gridDataCollection = (_dataProvider.gridData as ICollection);
						if(!_gridDataCollection){
							_gridDataCollection = LinkedListConverter.fromNativeCollection(_dataProvider.gridData);
						}
						if(_gridDataCollection){
							_gridDataCollection.collectionChanged.addHandler(onCollectionChanged);
							mapData();
						}else{
							_dataToParentData = new Dictionary();
						}
					}else{
						_dataToParentData = new Dictionary();
					}
					
					_layout.dataProvider = _dataProvider.accordionData;
					_gridLayout.dataProvider = _dataProvider.gridData;
				}else{
					_dataToParentData = new Dictionary();
					_gridDataCollection = null;
					_layout.dataProvider = null;
					_gridLayout.dataProvider = null;
				}
			}
		}
		public function get marginTop():Number{
			return _gridLayout.marginTop;
		}
		public function set marginTop(value:Number):void{
			_gridLayout.marginTop = value;
			_accordionLayout.marginTop = value;
		}
		public function get marginLeft():Number{
			return _gridLayout.marginLeft;
		}
		public function set marginLeft(value:Number):void{
			_gridLayout.marginLeft = value;
			_accordionLayout.marginLeft = value;
		}
		public function get marginBottom():Number{
			return _gridLayout.marginBottom;
		}
		public function set marginBottom(value:Number):void{
			_gridLayout.marginBottom = value;
			_accordionLayout.marginBottom = value;
		}
		public function get marginRight():Number{
			return _gridLayout.marginRight;
		}
		public function set marginRight(value:Number):void{
			_gridLayout.marginRight = value;
			_accordionLayout.marginRight = value;
		}
		public function get gridFlowDirection():String{
			return _gridLayout.flowDirection;
		}
		public function set gridFlowDirection(value:String):void{
			_gridLayout.flowDirection = value;
		}
		public function get columnWidths():Array{
			return _gridLayout.columnWidths;
		}
		public function set columnWidths(value:Array):void{
			_gridLayout.columnWidths = value;
		}
		public function get rowHeights():Array{
			return _gridLayout.rowHeights;
		}
		public function set rowHeights(value:Array):void{
			_gridLayout.rowHeights = value;
		}
		public function get gridRendererFactory():IInstanceFactory{
			return _gridRendererFactory;
		}
		public function set gridRendererFactory(value:IInstanceFactory):void{
			if(_gridRendererFactory != value){
				_gridRendererFactory = value;
				assessGridFactory();
			}
		}
		
		public function get gridDataField():String{
			return _gridDataField;
		}
		public function set gridDataField(value:String):void{
			if(_gridDataField != value){
				_gridDataField = value;
				assessGridFactory();
			}
		}
		override public function set gap(value:Number):void{
			super.gap = value
			_gridLayout.horizontalGap = value;
			_gridLayout.verticalGap = value;
		}
		
		private var _gridDataCollection:ICollection;
		private var _accordionDataCollection:ICollection;
		private var _dataProvider:IAccordionGridDataProvider;
		private var _gridLayout:RendererGridLayout;
		private var _gridDataField:String;
		private var _gridRendererFactory:IInstanceFactory;
		private var _assumedGridRendererFactory:SimpleInstanceFactory;
		private var _assumedGridRendererAsset:IDisplayAsset;
		
		// mapped parentData > accordionGridRenderer
		private var _accordDataToRend:Dictionary = new Dictionary();
		// mapped accordionGridRenderer > parentData
		private var _rendToAccordData:Dictionary = new Dictionary();
		// mapped cellRenderer > cellData
		private var _gridRendToData:Dictionary = new Dictionary();
		// mapped cellData > parentData
		private var _dataToParentData:Dictionary = new Dictionary();
		// mapped cellRenderer > accordionGridRenderer
		private var _gridRendToAccordRend:Dictionary = new Dictionary();
		// mapped cellData > boolean
		private var _isHeader:Dictionary = new Dictionary();
		
		public function AccordionGridView(){
			super();
			createGridLayout();
			_gridLayout.measurementsChanged.addHandler(onGridMeasChange);
			//_gridLayout.scrollMetricsChanged.addHandler(onLayoutScroll);
			_gridLayout.setRendererDataAct.addHandler(onSetGridRendererData);
			_gridLayout.removeRendererAct.addHandler(onRemoveGridRenderer);
			_layout.setRendererDataAct.addHandler(onSetAccordionRendererData);
		}
		public function onCollectionChanged(from:ICollection, fromX:Number, toX:Number):void{
			mapData();
		}
		protected function onGridMeasChange(from:RendererGridLayout, oldWidth:Number, oldHeight:Number):void{
			var meas:Point = _gridLayout.measurements;
			_gridLayout.setSize(meas.x,meas.y);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_assumedGridRendererAsset = _containerAsset.takeAssetByName(CELL_RENDERER,IDisplayAsset,true);
			if(_assumedGridRendererAsset){
				_containerAsset.removeAsset(_assumedGridRendererAsset);
				assessGridFactory();
			}
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			if(_assumedGridRendererAsset){
				_containerAsset.addAsset(_assumedGridRendererAsset);
				_containerAsset.returnAsset(_assumedGridRendererAsset);
				_assumedGridRendererAsset = null;
				
				if(_assumedGridRendererFactory){
					_assumedGridRendererFactory.instanceProperties = null;
					_assumedGridRendererFactory = null;
					assessGridFactory();
				}
			}
		}
		protected function mapData():void{
			_dataToParentData = new Dictionary();
			_isHeader = new Dictionary();
			
			var index:int;
			var isVert:Boolean = (_accordionLayout.accordionDirection==Direction.VERTICAL);
			
			var accordIterator:IIterator = _accordionDataCollection.getIterator();
			var accordData:*;
			
			var gridIterator:IIterator = _gridDataCollection.getIterator();
			var gridIterator2D:IIterator2D = (gridIterator as IIterator2D);
			var gridData:*;
			
			var gridArrays:Array = [];
			var array:Array;
			var accordionIndices:Array = [];
			var accordionData:Array = [];
			
			while((accordData = accordIterator.next()) || gridData){
				while(gridData = gridIterator.next()){
					if(gridIterator2D && isVert){
						index = gridIterator2D.y;
					}else{
						index = gridIterator.x;
					}
					array = gridArrays[index];
					if(!array){
						gridArrays[index] = [gridData];
					}else{
						array.push(gridData);
					}
					if(gridData==accordData){
						accordionIndices.push(index);
						accordionData.push(accordData);
						break;
					}
				}
			}
			gridIterator.release();
			accordIterator.release();
			
			for(var x:int=0; x<accordionIndices.length; x++){
				var accIndex:int = accordionIndices[x];
				var nextAccIndex:int = (x<accordionIndices.length-1?accordionIndices[x+1]:gridArrays.length);
				accordData = accordionData[x];
				
				var i:int = accIndex;
				while(i<nextAccIndex){
					array = gridArrays[i];
					for each(var data:* in array){
						_dataToParentData[data] = accordData;
						_isHeader[data] = (i==accIndex);
					}
					i++;
				}
			}
		}
		override protected function onRemoveRenderer(layout:RendererGridLayout, renderer:ILayoutView):void{
			super.onRemoveRenderer(layout, renderer);
			
			var castRend:IAccordionGridRenderer = (renderer as IAccordionGridRenderer);
			for(var data:* in _accordDataToRend){
				if(_accordDataToRend[data]==renderer){
					
					for(var i:* in _gridRendToData){
						var childRend:ILayoutView = (i as ILayoutView);
						var childData:* = _gridRendToData[i];
						if(_dataToParentData[childData]==data){
							if(childRend){
								delete _gridRendToAccordRend[childRend];
								castRend.removeCellRenderer(childRend);
							}
						}
					}
					delete _accordDataToRend[data];
					break;
				}
			}
		}
		protected function onSetAccordionRendererData(layout:AccordionLayout, renderer:IAccordionGridRenderer, data:*, dataField:String) : void{
			var oldRenderer:IAccordionGridRenderer = _accordDataToRend[data];
			if(oldRenderer!=renderer){
				var oldData:* = _rendToAccordData[renderer];
				if(oldData){
					delete _accordDataToRend[oldData];
				}
				var i:*;
				var childRend:ILayoutView;
				if(data){
					_rendToAccordData[renderer] = data;
					_accordDataToRend[data] = renderer;
					for(i in _gridRendToData){
						childRend = (i as ILayoutView);
						var childData:* = _gridRendToData[i];
						var childParent:* = _dataToParentData[childData];
						if(childParent==data){
							if(oldRenderer){
								oldRenderer.removeCellRenderer(childRend);
							}
							renderer.addCellRenderer(childRend,_isHeader[childData]);
							_gridRendToAccordRend[childRend] = renderer;
						}else if(_gridRendToAccordRend[childRend]==renderer){
							renderer.removeCellRenderer(childRend);
							delete _gridRendToAccordRend[childRend];
						}
					}
				}else{
					for(i in _gridRendToAccordRend){
						childRend = (i as ILayoutView);
						if(_gridRendToAccordRend[childRend]==renderer){
							renderer.removeCellRenderer(childRend);
							delete _gridRendToAccordRend[childRend];
						}
					}
					delete _rendToAccordData[renderer];
				}
			}
		}
		protected function onSetGridRendererData(layout:RendererGridLayout, renderer:ILayoutView, data:*, dataField:String) : void{
			var newParent:IAccordionGridRenderer = findParentByData(data);
			var existingParent:IAccordionGridRenderer = _gridRendToAccordRend[renderer];
			
			if(newParent!=existingParent){
				if(existingParent){
					existingParent.removeCellRenderer(renderer);
					delete _gridRendToAccordRend[renderer];
				}
				if(newParent){
					newParent.addCellRenderer(renderer,_isHeader[data]);
					_gridRendToAccordRend[renderer] = newParent;
				}
			}
			_gridRendToData[renderer] = data;
		}
		protected function onRemoveGridRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			var parent:IAccordionGridRenderer = _gridRendToAccordRend[renderer];
			if(parent){
				delete _gridRendToAccordRend[renderer];
				parent.removeCellRenderer(renderer);
			}
			delete _gridRendToData[renderer];
		}
		protected function findParentByData(data:*) : IAccordionGridRenderer{
			var parentData:* = _dataToParentData[data];
			return _accordDataToRend[parentData];
		}
		override protected function commitSize() : void{
			super.commitSize();
			drawGridLayout(position);
		}
		protected function drawGridLayout(position:Point) : void{
			var meas:Point = _gridLayout.measurements;
			_gridLayout.setSize(meas.x,meas.y);
		}
		protected function createGridLayout() : void{
			_gridLayout = new RendererGridLayout(this);
			_gridLayout.equaliseCellHeights = true;
			_gridLayout.equaliseCellWidths = true;
		}
		protected function assessGridFactory():void{
			var factory:IInstanceFactory;
			var dataField:String;
			if(_gridRendererFactory){
				factory = _gridRendererFactory;
				dataField = _gridDataField;
			}else if(_assumedGridRendererAsset){
				if(!_assumedGridRendererFactory){
					createAssumedGridFactory();
				}
				factory = _assumedGridRendererFactory;
				dataField = "data";
			}else{
				factory = null;
				dataField = null;
			}
			if(factory!=_gridLayout.rendererFactory || dataField!=_gridLayout.dataField){
				updateGridFactory(factory,dataField);
			}
		}
		protected function updateGridFactory(factory:IInstanceFactory, dataField:String):void{
			_gridLayout.rendererFactory = factory;
			_gridLayout.dataField = dataField;
		}
		override protected function createAssumedFactory():SimpleInstanceFactory{
			_assumedRendererFactory = new SimpleInstanceFactory(AccordionGridRenderer);
			_assumedRendererFactory.useChildFactories = true;
			_assumedRendererFactory.instanceProperties = new Dictionary();
			checkAssetFactory();
			_assumedRendererFactory.instanceProperties["asset"] = _assumedAssetFactory;
			return _assumedRendererFactory;
		}
		protected function createAssumedGridFactory():void{
			_assumedGridRendererFactory = new SimpleInstanceFactory(AccordionGridRenderer);
			_assumedGridRendererFactory.useChildFactories = true;
			_assumedGridRendererFactory.instanceProperties = new Dictionary();
			_assumedGridRendererFactory.instanceProperties["asset"] = _assumedGridRendererAsset.getCloneFactory();
		}
	}
}