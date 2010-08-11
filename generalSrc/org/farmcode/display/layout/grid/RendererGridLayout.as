package org.farmcode.display.layout.grid
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.collections.ICollection;
	import org.farmcode.collections.ICollection2D;
	import org.farmcode.collections.IIterator;
	import org.farmcode.collections.IIterator2D;
	import org.farmcode.collections.linkedList.LinkedListConverter;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.layout.list.ListLayoutInfo;
	import org.farmcode.display.scrolling.ScrollMetrics;
	import org.farmcode.display.validation.ValidationFlag;
	import org.farmcode.instanceFactory.IInstanceFactory;

	public class RendererGridLayout extends AbstractGridLayout
	{
		public function get pixelFlow():Boolean{
			return super._pixelFlow;
		}
		public function set pixelFlow(value:Boolean):void{
			super._pixelFlow = value;
		}
		public function get columnWidths():Array{
			return super._columnWidths;
		}
		public function set columnWidths(value:Array):void{
			super._columnWidths = value;
		}
		public function get rowHeights():Array{
			return super._rowHeights;
		}
		public function set rowHeights(value:Array):void{
			super._rowHeights = value;
		}
		public function get equaliseCellHeights():Boolean{
			return super._equaliseCellHeights;
		}
		public function set equaliseCellHeights(value:Boolean):void{
			super._equaliseCellHeights = value;
		}
		public function get equaliseCellWidths():Boolean{
			return super._equaliseCellWidths;
		}
		public function set equaliseCellWidths(value:Boolean):void{
			super._equaliseCellWidths = value;
		}
		public function get horizontalGap():Number{
			return super._horizontalGap;
		}
		public function set horizontalGap(value:Number):void{
			super._horizontalGap = value;
		}
		public function get verticalGap():Number{
			return super._verticalGap;
		}
		public function set verticalGap(value:Number):void{
			super._verticalGap = value;
		}
		public function get gap():Number{
			return (verticalGap==horizontalGap?verticalGap:NaN);
		}
		public function set gap(value:Number):void{
			verticalGap = value;
			horizontalGap = value;
		}
		public function get flowDirection():String{
			return super._flowDirection;
		}
		public function set flowDirection(value:String):void{
			super._flowDirection = value;
		}
		
		public function get rendererFactory():IInstanceFactory{
			return _rendererFactory;
		}
		public function set rendererFactory(value:IInstanceFactory):void{
			if(_rendererFactory!=value){
				_rendererFactory = value;
				_protoRenderer = null;
				_cellMeasCache = new Dictionary();
				removeAllRenderers();
				invalidateAll();
				dispatchMeasurementChange();
			}
		}
		
		public function get dataProvider():*{
			return _dataProvider;
		}
		public function set dataProvider(value:*):void{
			if(_dataProvider!=value){
				if(_dataProviderCollection2D){
					_dataProviderCollection2D.collection2DChanged.removeHandler(onCollection2DChanged);
				}else if(_dataProviderCollection){
					_dataProviderCollection.collectionChanged.removeHandler(onCollectionChanged);
				}
				_dataProvider = value;
				_cellMeasCache = new Dictionary();
				_dataToRenderers = new Dictionary();
				if(value){
					_dataProviderCollection2D = (value as ICollection2D);
					if(_dataProviderCollection2D){
						_dataProviderCollection = _dataProviderCollection2D;
						_dataProviderCollection2D.collection2DChanged.addHandler(onCollection2DChanged);
					}else{
						_dataProviderCollection = (value as ICollection);
						if(!_dataProviderCollection){
							_dataProviderCollection = LinkedListConverter.fromNativeCollection(value);
						}
						if(_dataProviderCollection){
							_dataProviderCollection.collectionChanged.addHandler(onCollectionChanged);
						}
					}
				}else{
					_dataProviderCollection = null;
					_dataProviderCollection2D = null;
				}
				_cellKeys = _cellLayouts = null;
				
				clearDataChecks();
				
				invalidateAll();
				dispatchMeasurementChange();
			}
		}
		
		public function get dataField():String{
			return _dataField;
		}
		public function set dataField(value:String):void{
			if(_dataField!=value){
				_dataField = value;
				invalidateAll();
				dispatchMeasurementChange();
			}
		}
		public function get renderEmptyCells():Boolean{
			return _renderEmptyCells;
		}
		public function set renderEmptyCells(value:Boolean):void{
			if(_renderEmptyCells!=value){
				_renderEmptyCells = value;
				_cellPosFlag.invalidate();
				invalidate();
			}
		}
		public function get horizontalScrollByLine():Boolean{
			return super._horizontalScrollByLine;
		}
		public function set horizontalScrollByLine(value:Boolean):void{
			super._horizontalScrollByLine = value
		}
		public function get verticalScrollByLine():Boolean{
			return super._verticalScrollByLine;
		}
		public function set verticalScrollByLine(value:Boolean):void{
			super._verticalScrollByLine = value
		}
		public function get fitRenderers():int{
			validate();
			return _fitRenderers;
		}
		
		/**
		 * handler(layout:RendererGridLayout, fitRenderers:int)
		 */
		public function get fitRenderersAct():IAct{
			if(!_fitRenderersAct)_fitRenderersAct = new Act();
			return _fitRenderersAct;
		}
		/**
		 * handler(layout:RendererGridLayout, renderer:ILayoutSubject)
		 */
		public function get removeRendererAct():IAct{
			if(!_removeRendererAct)_removeRendererAct = new Act();
			return _removeRendererAct;
		}
		/**
		 * handler(layout:RendererGridLayout, renderer:ILayoutSubject)
		 */
		public function get addRendererAct():IAct{
			if(!_addRendererAct)_addRendererAct = new Act();
			return _addRendererAct;
		}
		/**
		 * handler(layout:RendererGridLayout, renderer:ILayoutSubject, data:*, dataField:String)
		 */
		public function get setRendererDataAct():IAct{
			if(!_setRendererDataAct)_setRendererDataAct = new Act();
			return _setRendererDataAct;
		}
		protected var _addRendererAct:Act;
		protected var _removeRendererAct:Act;
		protected var _fitRenderersAct:Act;
		protected var _setRendererDataAct:Act;
		
		private var _renderEmptyCells:Boolean;
		protected var _dataField:String;
		private var _dataProvider:*;
		private var _dataProviderCollection:ICollection;
		private var _dataProviderCollection2D:ICollection2D;
		protected var _rendererFactory:IInstanceFactory;
		protected var _protoRenderer:ILayoutSubject;
		protected var _cullRenderersFlag:ValidationFlag = new ValidationFlag(cullRenderers,true);
		
		private var _dataChecked:Boolean;
		protected var _dataCount:int;
		private var _dataLayouts:Dictionary = new Dictionary();
		protected var _dataMap:Dictionary = new Dictionary();
		private var _dataIndices:Dictionary = new Dictionary();
		protected var _dataToRenderers:Dictionary = new Dictionary();
		private var _renderers:Array = [];
		protected var _positionCache:Array = [];
		protected var _coordCache:Array = [];
		
		private var _cellKeys:Dictionary;
		private var _cellLayouts:Dictionary;
		private var _cellKeyCount:int;
		
		private var _fitRenderers:int;
		
		protected var _verticalRendAxis:RendererGridAxis;
		protected var _horizontalRendAxis:RendererGridAxis;
		
		protected var _breadthRendAxis:RendererGridAxis;
		protected var _lengthRendAxis:RendererGridAxis;
		
		public function RendererGridLayout(scopeView:IView=null){
			super(scopeView);
		}
		override protected function createAxes():void{
			_horizontalAxis = _horizontalRendAxis = new RendererGridAxis("x","width","columnIndex");
			_verticalAxis = _verticalRendAxis = new RendererGridAxis("y","height","rowIndex");
		}
		override protected function validateProps():void{
			super.validateProps();
			if(_isVertical){
				_breadthRendAxis = _verticalRendAxis;
				_lengthRendAxis = _horizontalRendAxis;
			}else{
				_breadthRendAxis = _horizontalRendAxis;
				_lengthRendAxis = _verticalRendAxis;
			}
		}
		public function onCollection2DChanged(from:ICollection2D, fromX:Number, toX:Number, fromY:Number, toY:Number):void{
			clearDataChecks();
			//TODO: use parameters to limit invalidation (would require refactor of data checking logic)
			invalidateAll();
		}
		public function onCollectionChanged(from:ICollection, fromX:Number, toX:Number):void{
			clearDataChecks();
			//TODO: use parameters to limit invalidation (would require refactor of data checking logic)
			invalidateAll();
		}
		public function getDataLayout(data:*) : ILayoutInfo{
			validate();
			var index:int = _dataIndices[data];
			return _dataLayouts[index];
		}
		public function getDataCount() : int{
			if(!_dataChecked)getChildKeys();
			return _dataCount;
		}
		public function getDataAt(index:int):*{
			getChildKeys();
			return _dataMap[index];
		}
		public function getDataPosition(index:int, fillRect:Rectangle=null):Rectangle{
			validate();
			index *= int(4);
			if(!fillRect){
				fillRect = new Rectangle();
			}
			fillRect.x = _positionCache[index];
			fillRect.y = _positionCache[index+1];
			fillRect.width = _positionCache[index+2];
			fillRect.height = _positionCache[index+3];
			return fillRect;
		}
		public function getDataCoords(index:int, fillPoint:Point=null):Point{
			validate();
			index *= int(2);
			if(!fillPoint){
				fillPoint = new Point();
			}
			if(flowDirection==Direction.VERTICAL){
				fillPoint.x = _coordCache[index];
				fillPoint.y = _coordCache[index+1];
			}else{
				fillPoint.x = _coordCache[index+1];
				fillPoint.y = _coordCache[index];
			}
			return fillPoint;
		}
		override protected function invalidateAll() : void{
			super.invalidateAll();
		}
		override protected function draw(): void{
			if(_rendererFactory){
				super.draw();
				_cullRenderersFlag.validate();
			}else{
				_allInvalid = false; // to allow invalidateAll() call to go through again
			}
		}
		override protected function getChildKeys() : Dictionary{
			if(!_dataChecked && _dataProviderCollection){
				_dataChecked = true;
				var iterator:IIterator = _dataProviderCollection.getIterator();
				var iterator2D:IIterator2D = (iterator as IIterator2D);
				var i:int=0;
				var data:*;
				if(iterator2D){
					while(data = iterator2D.next()){
						_dataIndices[data] = i;
						_dataMap[i] = data;
						_dataLayouts[i] = new GridLayoutInfo(iterator2D.x,iterator2D.y);
						++i;
					}
				}else{
					while(data = iterator.next()){
						_dataIndices[data] = i;
						_dataMap[i] = data;
						_dataLayouts[i] = new ListLayoutInfo(i);
						++i;
					}
				}
				iterator.release();
				_dataCount = i;
			}
			var keyCount:int = (_fitRenderers>_dataCount?_fitRenderers:_dataCount);
			if(!_cellKeys || _cellKeyCount!=keyCount){
				_cellKeys = new Dictionary();
				_cellLayouts = new Dictionary();
				for(i=0; i<keyCount; i++){
					_cellKeys[i] = true;
					if(!_dataLayouts[i]){
						_cellLayouts[i] = new ListLayoutInfo(i);
					}
				}
				_cellKeyCount = keyCount;
			}
			return _cellKeys;
		}
		public function clearDataChecks():void{
			_dataChecked = false;
			_dataLayouts = new Dictionary();
			_dataMap = new Dictionary();
			_dataIndices = new Dictionary();
		}
		override protected function remeasureChild(key:*) : Boolean{
			return (!_cellMeasCache[key]);
		}
		override protected function getChildMeasurement(key:*) : Point{
			if(key>=_dataCount){
				return null;
			}
			var data:* = _dataMap[key];
			var renderer:ILayoutSubject = _dataToRenderers[data];
			if(!renderer){
				if(!_protoRenderer){
					_protoRenderer = _rendererFactory.createInstance();
				}
				_protoRenderer[_dataField] = data;
				if(_setRendererDataAct)_setRendererDataAct.perform(this,_protoRenderer,data,_dataField);
				renderer = _protoRenderer;
				
				var ret:Point = renderer.measurements.clone();
				
				_protoRenderer[_dataField] = null;
				if(_setRendererDataAct)_setRendererDataAct.perform(this,_protoRenderer,null,_dataField);
				
				return ret;
			}else{
				return renderer.measurements;
			}
		}
		override protected function getChildLayoutInfo(key:*) : ILayoutInfo{
			return _dataLayouts[key] || _cellLayouts[key];
		}
		override protected function getChildRenderer(key:*,length:int,breadth:int):ILayoutSubject{
			var minLength:int = _lengthRendAxis.dimIndex;
			var maxLength:int = _lengthRendAxis.dimIndexMax;
			var minBreadth:int = _breadthRendAxis.dimIndex;
			var maxBreadth:int = _breadthRendAxis.dimIndexMax;
			var renderIndex:int = ((maxBreadth-minBreadth)*(length-minLength))+(breadth-minBreadth);
			var renderer:ILayoutSubject = _renderers[renderIndex];
			if(length>=minLength && length<maxLength && breadth>=minBreadth && breadth<maxBreadth && (key<_dataCount || _renderEmptyCells)){
				var data:* = _dataMap[key];
				if(!renderer){
					renderer = _rendererFactory.createInstance();
					_renderers[renderIndex] = renderer;
					rendererAdded(renderer);
					_cullRenderersFlag.invalidate();
				}
				if(renderer[_dataField] != data){
					renderer[_dataField] = data;
					if(_setRendererDataAct)_setRendererDataAct.perform(this,renderer,data,_dataField);
				}
				_dataToRenderers[data] = renderer;
				return renderer;
			}else{
				if(renderer){
					delete _renderers[renderIndex];
					rendererRemoved(renderer);
				}
				return null;
			}
		}
		protected function rendererAdded(renderer:ILayoutSubject):void{
			renderer.measurementsChanged.addHandler(onRendMeasChanged);
			if(_addRendererAct)_addRendererAct.perform(this,renderer);
		}
		// TODO: avoid casting all the time
		protected function rendererRemoved(renderer:ILayoutSubject):void{
			var cast:IGridLayoutSubject = (renderer as IGridLayoutSubject);
			if(cast){
				cast.columnIndex = -1;
				cast.rowIndex = -1;
			}
			delete _dataToRenderers[renderer[_dataField]];
			renderer.measurementsChanged.removeHandler(onRendMeasChanged);
			if(_removeRendererAct)_removeRendererAct.perform(this,renderer);
		}
		protected function onRendMeasChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			var data:* = from[_dataField];
			delete _cellMeasCache[data];
			invalidateAll();
		}
		protected function cullRenderers():void{
			/*
			Remove renderers which fall within the visible area but do not relate
			to any data any more.
			*/
			
			var minLength:int = _lengthRendAxis.dimIndex;
			var maxLength:int = _lengthRendAxis.dimIndexMax;
			var minBreadth:int = _breadthRendAxis.dimIndex;
			var maxBreadth:int = _breadthRendAxis.dimIndexMax;
			var breadthRange:int = (maxBreadth-minBreadth);
			
			var totRend:int = _renderers.length;
			var remove:Boolean;
			for(var i:int=0; i<totRend; ++i){
				var renderer:ILayoutSubject = _renderers[i];
				if(renderer){
					remove = false;
					var breadth:int = i%breadthRange;
					var length:int = ((i-breadth)/breadthRange)+minLength;
					breadth += minBreadth;
					if(length<minLength || 
						length>maxLength ||
						(!_renderEmptyCells && (_cellPosCache[length]==null || _cellPosCache[length][breadth]==null))){
						
						delete _renderers[i];
						renderer[_dataField] = null;
						rendererRemoved(renderer);
					}
				}
			}
		}
		protected function calcRange(index:int, indexMax:int):int{
			if(indexMax==index+1){
				return 1;
			}else{
				return indexMax-index-1;
			}
		}
		override protected function validateAllScrolling():void{
			if(!_breadthScrollFlag.valid || !_lengthScrollFlag.valid){
				
				var oldBreadthIndex:int = _breadthRendAxis.dimIndex;
				var oldLengthIndex:int = _lengthRendAxis.dimIndex;
				
				var oldBreadthIndexMax:int = _breadthRendAxis.dimIndexMax;
				var oldLengthIndexMax:int = _lengthRendAxis.dimIndexMax;
				
				var oldBreadthRange:int = calcRange(oldBreadthIndex,oldBreadthIndexMax);
				var oldLengthRange:int = calcRange(oldLengthIndex,oldLengthIndexMax);
				
				super.validateAllScrolling();
				
				
				var breadthIndex:int = _breadthRendAxis.dimIndex;
				var lengthIndex:int = _lengthRendAxis.dimIndex;
				
				var breadthIndexMax:int = _breadthRendAxis.dimIndexMax;
				var lengthIndexMax:int = _lengthRendAxis.dimIndexMax;
				
				var breadthRange:int = calcRange(breadthIndex,breadthIndexMax);
				var lengthRange:int = calcRange(lengthIndex,lengthIndexMax);
				
				var shiftBreadth:int = oldBreadthIndex-breadthIndex;
				var shiftLength:int = oldLengthIndex-lengthIndex;
				
				var oldTotal:Number = (oldBreadthRange)*(oldLengthRange);
				_fitRenderers = (breadthRange)*(lengthRange);
				if(oldTotal!=_fitRenderers && _fitRenderersAct){
					_fitRenderersAct.perform(this,_fitRenderers);
					_cullRenderersFlag.invalidate();
				}
				if(oldTotal!=_fitRenderers && _renderEmptyCells && _fitRenderers>_dataCount){
					validateCellMeas();
					_cellMappingFlag.validate();
					invalidate();
				}
				
				if(shiftBreadth || shiftLength || oldBreadthRange!=breadthRange || oldLengthRange!=lengthRange){
					var newRenderers:Array = [];
					var rangeDif:int;
					if(_pixelFlow){
						rangeDif = (oldBreadthRange-breadthRange);
					}
					for(var length:int=0; length<=oldLengthRange; length++){
						for(var breadth:int=0; breadth<=oldBreadthRange; breadth++){
							var oldRenderIndex:int = ((oldBreadthRange+1)*length)+breadth;
							var renderer:ILayoutSubject = _renderers[oldRenderIndex];
							if(renderer){
								var newLength:int = length;
								var newBreadth:int = breadth;
								if(_pixelFlow && rangeDif){
									// adjust indices to reflect changes in breadthRange
									var renderIndex:int = ((breadthRange+1)*newLength)+newBreadth;
									renderIndex += rangeDif*length;
									newLength = Math.floor(renderIndex/(breadthRange+1));
									newBreadth = renderIndex%(breadthRange+1);
								}
								// shift cells if scrolling has occured (so that dataProviders stay the same)
								if(shiftLength){
									newLength = (length+shiftLength)%(lengthRange+1);
									while(newLength<0)newLength += (lengthRange+1);
								}
								
								if(shiftBreadth){
									newBreadth = (breadth+shiftBreadth)%(breadthRange+1);
									while(newBreadth<0)newBreadth += (breadthRange+1);
								}
								
								// test whether the renderer is still needed
								renderIndex = ((breadthRange+1)*newLength)+newBreadth;
								if(renderIndex<=_fitRenderers && !newRenderers[renderIndex]){
									delete _dataToRenderers[renderer[_dataField]];
									newRenderers[renderIndex] = renderer;
								}else{
									rendererRemoved(renderer);
								}
							}
						}
					}
					_renderers = newRenderers;
				}
			}
		}
		override protected function validateScroll(scrollMetrics:ScrollMetrics, axis:GridAxis) : void{
			if(scrollMetrics.value<0 || isNaN(scrollMetrics.value))scrollMetrics.value = 0;
			var pixScroll:Number;
			var pixScrollMax:Number;
			var realDim:Number = _displayPosition[axis.dimRef];
			var realMeas:Number = _measurements[axis.coordRef];
			var newIndex:int;
			var newIndexMax:int;
			
			if(realMeas>realDim){
				pixScrollMax = realMeas-realDim;
				newIndexMax = -1;
				var stack:Number = axis.foreMargin;
				var total:Number = 0;
				var foundPixMax:Boolean;
				var scrollValue:int = Math.round(scrollMetrics.value);
				for(var i:int=0; i<axis.maxCellSizes.length; i++){
					var measurement:Number = axis.maxCellSizes[i];
					if(axis.scrollByLine){
						if(i==scrollValue){
							pixScroll = stack;
							newIndex = i;
						}
					}else if(stack+measurement>scrollMetrics.value && isNaN(pixScroll)){
						pixScroll = scrollMetrics.value;
						newIndex = i;
					}
					stack += measurement;
					if(!isNaN(pixScroll) && newIndexMax==-1 && stack>realDim+pixScroll){
						newIndexMax = i+1;
						if(foundPixMax)break;
					}
					if(!foundPixMax && (stack>pixScrollMax || i==axis.maxCellSizes.length-1)){
						foundPixMax = true;
						if(axis.scrollByLine){
							scrollMetrics.pageSize = axis.maxCellSizes.length-i;
							scrollMetrics.maximum = axis.maxCellSizes.length;
						}else{
							scrollMetrics.maximum = realMeas;
							scrollMetrics.pageSize = realDim;
						}
						if(isNaN(pixScroll)){
							pixScroll = pixScrollMax;
						}
						if(newIndexMax!=-1)break;
					}
					if(i<axis.maxCellSizes.length-1)stack += axis.gap;
				}
				if(newIndexMax==-1){
					newIndexMax = axis.maxCellSizes.length;
				}
			}else{
				var max:int = axis.maxCellSizes.length;
				newIndex = 0;
				pixScroll = 0;
				pixScrollMax = 0;
				for(i=0; i<axis.maxCellSizes.length; i++){
					measurement = axis.maxCellSizes[i];
					pixScrollMax += measurement;
					if(i<axis.maxCellSizes.length-1)pixScrollMax += axis.gap;
				}
				if(_protoRenderer){
					var defaultDim:Number = _protoRenderer.measurements[axis.coordRef];
					var leftOver:Number = (realDim-axis.foreMargin+axis.gap-pixScrollMax);
					if(leftOver>0){
						var defMax:int = max+int(leftOver/(defaultDim+axis.gap));
						if(max<defMax){
							max = defMax;
							pixScrollMax += ((max-axis.maxCellSizes.length)*(defaultDim+axis.gap))-axis.gap;
						}
					}
				}
				newIndexMax = max;
				
				scrollMetrics.pageSize = realDim;
				scrollMetrics.maximum = realDim;
			}
			var castAxis:RendererGridAxis = (axis as RendererGridAxis);
			castAxis.dimIndex = newIndex;
			castAxis.dimIndexMax = newIndexMax;
			
			if(axis.pixScrollMetrics.maximum != realMeas || axis.pixScrollMetrics.pageSize != realDim || axis.pixScrollMetrics.value != pixScroll){
				axis.pixScrollMetrics.maximum = realMeas;
				axis.pixScrollMetrics.pageSize = realDim;
				axis.pixScrollMetrics.value = pixScroll;
				var dir:String = (scrollMetrics==_horizontalAxis.scrollMetrics)?Direction.HORIZONTAL:Direction.VERTICAL;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this, dir, axis.pixScrollMetrics);
			}
		}
		protected function removeAllRenderers():void{
			for each(var renderer:ILayoutSubject in _renderers){
				rendererRemoved(renderer);
			}
			_renderers = [];
		}
		override protected function positionRenderer(key:*, length:int, breadth:int, x:Number, y:Number, width:Number, height:Number):void{
			super.positionRenderer(key, length, breadth, x, y, width, height);
			var posIndex:int = (key as int)*int(4);
			_positionCache[posIndex] = x;
			_positionCache[posIndex+1] = y;
			_positionCache[posIndex+2] = width;
			_positionCache[posIndex+3] = height;
			var coIndex:int = (key as int)*int(2);
			_coordCache[coIndex] = length;
			_coordCache[coIndex+1] = breadth;
		}
	}
}