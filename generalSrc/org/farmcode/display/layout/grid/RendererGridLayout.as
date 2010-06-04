package org.farmcode.display.layout.grid
{
	import au.com.thefarmdigital.structs.ScrollMetrics;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.collections.ICollection;
	import org.farmcode.collections.IIterator;
	import org.farmcode.collections.IIterator2D;
	import org.farmcode.collections.linkedList.LinkedListConverter;
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.layout.list.ListLayoutInfo;
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
				_dataProvider = value;
				if(value){
					_dataProviderCollection = (value as ICollection);
					if(!_dataProviderCollection){
						_dataProviderCollection = LinkedListConverter.fromNativeCollection(value);
					}
				}else{
					_dataProviderCollection = null;
				}
				_cellKeys = _cellLayouts = null;
				
				_dataChecked = false;
				_dataLayouts = new Dictionary();
				_dataMap = new Dictionary();
				_dataIndices = new Dictionary();
				
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
		protected var _addRendererAct:Act;
		protected var _removeRendererAct:Act;
		protected var _fitRenderersAct:Act;
		
		private var _renderEmptyCells:Boolean;
		private var _dataField:String;
		private var _dataProvider:*;
		private var _dataProviderCollection:ICollection;
		private var _rendererFactory:IInstanceFactory;
		private var _protoRenderer:ILayoutSubject;
		
		private var _dataChecked:Boolean;
		private var _dataCount:int;
		private var _dataLayouts:Dictionary = new Dictionary();
		private var _dataMap:Dictionary = new Dictionary();
		private var _dataIndices:Dictionary = new Dictionary();
		private var _renderers:Array = [];
		private var _positionCache:Array = [];
		private var _coordCache:Array = [];
		
		private var _cellKeys:Dictionary;
		private var _cellLayouts:Dictionary;
		private var _cellKeyCount:int;
		
		private var widthIndex:int;
		private var heightIndex:int;
		private var widthIndexMax:int;
		private var heightIndexMax:int;
		private var _fitRenderers:int;
		
		public function RendererGridLayout(){
			super();
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
			validate();
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
		override protected function draw(): void{
			if(_rendererFactory){
				super.draw();
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
		override protected function remeasureChild(key:*) : Boolean{
			return (!_cellMeasCache[key]);
		}
		override protected function getChildMeasurement(key:*) : Rectangle{
			if(key>=_dataCount){
				return null;
			}
			if(!_protoRenderer){
				_protoRenderer = _rendererFactory.createInstance();
			}
			var data:* = _dataMap[key];
			_protoRenderer[_dataField] = data;
			return _protoRenderer.displayMeasurements.clone();
		}
		override protected function getChildLayoutInfo(key:*) : ILayoutInfo{
			return _dataLayouts[key] || _cellLayouts[key];
		}
		override protected function getChildRenderer(key:*,length:int,breadth:int):ILayoutSubject{
			var minLength:int = this[_lengthDimRef+"Index"];
			var maxLength:int = this[_lengthDimRef+"IndexMax"];
			var minBreadth:int = this[_breadthDimRef+"Index"];
			var maxBreadth:int = this[_breadthDimRef+"IndexMax"];
			var renderIndex:int = ((maxBreadth-minBreadth-1)*(length-minLength))+(breadth-minBreadth);
			var renderer:ILayoutViewBehaviour = _renderers[renderIndex];
			if(length>=minLength && length<maxLength && breadth>=minBreadth && breadth<maxBreadth && (key<_dataCount || _renderEmptyCells)){
				var data:* = _dataMap[key];
				if(!renderer){
					renderer = _rendererFactory.createInstance();
					_renderers[renderIndex] = renderer;
					if(_addRendererAct)_addRendererAct.perform(this,renderer);
				}
				renderer[_dataField] = data;
				return renderer;
			}else{
				if(renderer){
					delete _renderers[renderIndex];
					if(_removeRendererAct)_removeRendererAct.perform(this,renderer);
				}
				return null;
			}
		}
		override protected function validateCellPos():void{
			super.validateCellPos();
			
			/*
			Remove renderers which fall within the visible area but do not relate
			to any data any more.
			*/
			var keyCount:int = _dataCount;
			if(_renderEmptyCells && _fitRenderers>_dataCount){
				keyCount = _fitRenderers;
			}
			if(keyCount<_renderers.length){
				for(var i:int=keyCount; i<_renderers.length; i++){
					var renderer:ILayoutViewBehaviour = _renderers[i];
					if(renderer && _removeRendererAct){
						_removeRendererAct.perform(this,renderer);
					}
				}
				_renderers.splice(keyCount,_renderers.length-keyCount);
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
				var oldBreadthIndex:int = this[_breadthDimRef+"Index"];
				var oldLengthIndex:int = this[_lengthDimRef+"Index"];
				
				var oldBreadthIndexMax:int = this[_breadthDimRef+"IndexMax"];
				var oldLengthIndexMax:int = this[_lengthDimRef+"IndexMax"];
				
				var oldBreadthRange:int = calcRange(oldBreadthIndex,oldBreadthIndexMax);
				var oldLengthRange:int = calcRange(oldLengthIndex,oldLengthIndexMax);
				
				super.validateAllScrolling();
				
				var breadthIndex:int = this[_breadthDimRef+"Index"];
				var lengthIndex:int = this[_lengthDimRef+"Index"];
				
				var breadthIndexMax:int = this[_breadthDimRef+"IndexMax"];
				var lengthIndexMax:int = this[_lengthDimRef+"IndexMax"];
				
				var breadthRange:int = calcRange(breadthIndex,breadthIndexMax);
				var lengthRange:int = calcRange(lengthIndex,lengthIndexMax);
				
				var shiftBreadth:int = oldBreadthIndex-breadthIndex;
				var shiftLength:int = oldLengthIndex-lengthIndex;
				
				var oldTotal:Number = (oldBreadthRange)*(oldLengthRange);
				_fitRenderers = (breadthRange)*(lengthRange);
				if(oldTotal!=_fitRenderers && _fitRenderersAct){
					_fitRenderersAct.perform(this,_fitRenderers);
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
							var renderer:ILayoutViewBehaviour = _renderers[oldRenderIndex];
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
									newRenderers[renderIndex] = renderer;
								}else if(_removeRendererAct){
									_removeRendererAct.perform(this,renderer);
								}
							}
						}
					}
					_renderers = newRenderers;
				}
			}
		}
		override protected function validateScroll(scrollMetrics:ScrollMetrics, pixScrollMetrics:ScrollMetrics, realDimDef:String, measurements:Array,
												   margin:Number, scrollByLine:Boolean, forePadding:Number, gap:Number) : void{
			if(scrollMetrics.value<0 || isNaN(scrollMetrics.value))scrollMetrics.value = 0;
			var pixScroll:Number;
			var pixScrollMax:Number;
			var realDim:Number = _displayPosition[realDimDef];
			var realMeas:Number = displayMeasurements[realDimDef];
			var newIndex:int;
			var newIndexMax:int;
			
			if(realMeas>realDim){
				pixScrollMax = realMeas-realDim;
				newIndexMax = -1;
				var stack:Number = forePadding;
				var total:Number = 0;
				var foundPixMax:Boolean;
				var scrollValue:int = Math.round(scrollMetrics.value);
				for(var i:int=0; i<measurements.length; i++){
					var measurement:Number = measurements[i];
					if(scrollByLine){
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
					if(!foundPixMax && (stack>pixScrollMax || i==measurements.length-1)){
						foundPixMax = true;
						if(scrollByLine){
							scrollMetrics.pageSize = measurements.length-i;
							scrollMetrics.maximum = measurements.length;
						}else{
							scrollMetrics.maximum = realMeas;
							scrollMetrics.pageSize = realDim;
						}
						if(isNaN(pixScroll)){
							pixScroll = pixScrollMax;
						}
						if(newIndexMax!=-1)break;
					}
					if(i<measurements.length-1)stack += gap;
				}
				if(newIndexMax==-1){
					newIndexMax = measurements.length;
				}
			}else{
				var max:int = measurements.length;
				newIndex = 0;
				pixScroll = 0;
				pixScrollMax = 0;
				for(i=0; i<measurements.length; i++){
					measurement = measurements[i];
					pixScrollMax += measurement;
					if(i<measurements.length-1)pixScrollMax += gap;
				}
				if(_protoRenderer){
					var defaultDim:Number = _protoRenderer.displayMeasurements[realDimDef];
					var defMax:int = int((realDim-forePadding+gap)/(defaultDim+gap))+int(1);
					if(max<defMax){
						max = defMax;
						pixScrollMax += ((max-measurements.length)*(defaultDim+gap))-gap;
					}
				}
				newIndexMax = max;
				
				scrollMetrics.pageSize = realDim;
				scrollMetrics.maximum = realDim;
			}
			this[realDimDef+"Index"] = newIndex;
			this[realDimDef+"IndexMax"] = newIndexMax;
			
			if(pixScrollMetrics.maximum != realMeas || pixScrollMetrics.pageSize != realDim || pixScrollMetrics.value != pixScroll){
				pixScrollMetrics.maximum = realMeas;
				pixScrollMetrics.pageSize = realDim;
				pixScrollMetrics.value = pixScroll;
				var dir:String = (scrollMetrics==_horizontalScrollMetrics)?Direction.HORIZONTAL:Direction.VERTICAL;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this, dir, pixScrollMetrics);
			}
		}
		protected function removeAllRenderers():void{
			if(_removeRendererAct){
				for each(var renderer:ILayoutSubject in _renderers){
					_removeRendererAct.perform(this,renderer);
				}
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