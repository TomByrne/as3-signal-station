package org.farmcode.display.layout.grid
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.AbstractLayout;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.layout.list.IListLayoutInfo;
	import org.farmcode.display.scrolling.IScrollable;
	import org.farmcode.display.scrolling.ScrollMetrics;
	import org.farmcode.display.validation.ValidationFlag;
	
	/**
	 * In the AbstractGridLayout class, length is treated as the direction across the stacking of the list
	 * (i.e. width for a vertical list, height for a horizontal list) and breadth is treated as
	 * the direction along the stacking of the list (i.e. height for vertical lists, width for
	 * horizontal lists).
	 */
	public class AbstractGridLayout extends AbstractLayout implements IScrollable
	{
		public function get marginTop():Number{
			return _verticalAxis.foreMargin;
		}
		public function set marginTop(value:Number):void{
			if(_verticalAxis.foreMargin!=value){
				_verticalAxis.foreMargin = value;
				invalidateGapsAndMargins();
				invalidate();
			}
		}
		
		public function get marginLeft():Number{
			return _horizontalAxis.foreMargin;
		}
		public function set marginLeft(value:Number):void{
			if(_horizontalAxis.foreMargin!=value){
				_horizontalAxis.foreMargin = value;
				invalidateGapsAndMargins();
				invalidate();
			}
		}
		
		public function get marginRight():Number{
			return _horizontalAxis.aftMargin;
		}
		public function set marginRight(value:Number):void{
			if(_horizontalAxis.aftMargin!=value){
				_horizontalAxis.aftMargin = value;
				invalidateGapsAndMargins();
				invalidate();
			}
		}
		
		public function get marginBottom():Number{
			return _verticalAxis.aftMargin;
		}
		public function set marginBottom(value:Number):void{
			if(_verticalAxis.aftMargin!=value){
				_verticalAxis.aftMargin = value;
				invalidateGapsAndMargins();
				invalidate();
			}
		}
		
		protected function get _horizontalGap():Number{
			return _horizontalAxis.gap;
		}
		protected function set _horizontalGap(value:Number):void{
			if(_horizontalAxis.gap!=value){
				_horizontalAxis.gap = value;
				invalidateGapsAndMargins();
				invalidate();
			}
		}
		
		protected function get _verticalGap():Number{
			return _verticalAxis.gap;
		}
		protected function set _verticalGap(value:Number):void{
			if(_verticalAxis.gap!=value){
				_verticalAxis.gap = value;
				invalidateGapsAndMargins();
				invalidate();
			}
		}
		
		protected function get _maxColumns():int{
			return _horizontalAxis.maxCount;
		}
		protected function set _maxColumns(value:int):void{
			if(_horizontalAxis.maxCount!=value){
				_horizontalAxis.maxCount = value;
				_horizontalAxis.hasMaxCount = (value!=-1);
				_cellMappingFlag.invalidate();
				invalidate();
			}
		}
		protected function get _maxRows():int{
			return _verticalAxis.maxCount;
		}
		protected function set _maxRows(value:int):void{
			if(_verticalAxis.maxCount!=value){
				_verticalAxis.maxCount = value;
				_verticalAxis.hasMaxCount = (value!=-1);
				_cellMappingFlag.invalidate();
				invalidate();
			}
		}
		
		protected function get _flowDirection():String{
			return __flowDirection;
		}
		protected function set _flowDirection(value:String):void{
			if(__flowDirection!=value){
				__flowDirection = value;
				_propsFlag.invalidate();
				invalidate();
			}
		}
		
		protected function get _columnWidths():Array{
			return _horizontalAxis.cellSizes;
		}
		protected function set _columnWidths(value:Array):void{
			if(_horizontalAxis.cellSizes!=value){
				_horizontalAxis.cellSizes = value;
				_horizontalAxis.cellSizesCount = (value?value.length:0);
				_horizontalAxis.hasCellSizes = _horizontalAxis.cellSizesCount>0;
				_cellMappingFlag.invalidate();
				invalidate();
			}
		}
		
		protected function get _rowHeights():Array{
			return _verticalAxis.cellSizes;
		}
		protected function set _rowHeights(value:Array):void{
			if(_verticalAxis.cellSizes!=value){
				_verticalAxis.cellSizes = value;
				_verticalAxis.cellSizesCount = (value?value.length:0);
				_verticalAxis.hasCellSizes = _verticalAxis.cellSizesCount>0;
				_cellMappingFlag.invalidate();
				invalidate();
			}
		}
		
		protected function get _horizontalScroll():Number{
			return _horizontalAxis.scrollMetrics.value;
		}
		protected function set _horizontalScroll(value:Number):void{
			if(_horizontalAxis.scrollMetrics.value!=value){
				_horizontalAxis.scrollMetrics.value = value;
				if(__flowDirection==Direction.VERTICAL){
					_lengthScrollFlag.invalidate();
				}else{
					_breadthScrollFlag.invalidate();
				}
				invalidate();
			}
		}
		protected function get _horizontalScrollByLine():Boolean{
			return _horizontalAxis.scrollByLine;
		}
		protected function set _horizontalScrollByLine(value:Boolean):void{
			if(_horizontalAxis.scrollByLine!=value){
				_horizontalAxis.scrollByLine = value;
				if(__flowDirection==Direction.VERTICAL){
					_lengthScrollFlag.invalidate();
				}else{
					_breadthScrollFlag.invalidate();
				}
				invalidate();
			}
		}
		
		protected function get _verticalScroll():Number{
			return _verticalAxis.scrollMetrics.value;
		}
		protected function set _verticalScroll(value:Number):void{
			if(_verticalAxis.scrollMetrics.value!=value){
				_verticalAxis.scrollMetrics.value = value;
				if(__flowDirection==Direction.VERTICAL){
					_breadthScrollFlag.invalidate();
				}else{
					_lengthScrollFlag.invalidate();
				}
				invalidate();
			}
		}
		protected function get _verticalScrollByLine():Boolean{
			return _verticalAxis.scrollByLine;
		}
		protected function set _verticalScrollByLine(value:Boolean):void{
			if(_verticalAxis.scrollByLine!=value){
				_verticalAxis.scrollByLine = value;
				if(__flowDirection==Direction.VERTICAL){
					_breadthScrollFlag.invalidate();
				}else{
					_lengthScrollFlag.invalidate();
				}
				invalidate();
			}
		}
		
		protected function get _maxVerticalScroll():Number{
			return _verticalAxis.scrollMetrics.maximum;
		}
		
		protected function get _maxHorizontalScroll():Number{
			return _horizontalAxis.scrollMetrics.maximum;
		}
		
		protected function get _equaliseCellHeights():Boolean{
			return _verticalAxis.equaliseCells;
		}
		protected function set _equaliseCellHeights(value:Boolean):void{
			if(_verticalAxis.equaliseCells!=value){
				_verticalAxis.equaliseCells = value;
				_cellPosFlag.invalidate();
				invalidate();
			}
		}
		protected function get _equaliseCellWidths():Boolean{
			return _horizontalAxis.equaliseCells;
		}
		protected function set _equaliseCellWidths(value:Boolean):void{
			if(_horizontalAxis.equaliseCells!=value){
				_horizontalAxis.equaliseCells = value;
				_cellPosFlag.invalidate();
				invalidate();
			}
		}
		protected function get _pixelFlow():Boolean{
			return __pixelFlow;
		}
		protected function set _pixelFlow(value:Boolean):void{
			if(__pixelFlow!=value){
				__pixelFlow = value;
				_cellPosFlag.invalidate();
				invalidate();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get scrollMetricsChanged():IAct{
			if(!_scrollMetricsChanged)_scrollMetricsChanged = new Act();
			return _scrollMetricsChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mouseWheel():IAct{
			if(!_mouseWheel)_mouseWheel = new Act();
			return _mouseWheel;
		}
		
		protected var _mouseWheel:Act;
		protected var _scrollMetricsChanged:Act;
		
		private var __pixelFlow:Boolean;
		
		protected var _cellMeasCache:Dictionary = new Dictionary(true);
		protected var _cellPosCache:Array;
		
		private var __flowDirection:String = Direction.VERTICAL;
		
		protected var _propsFlag:ValidationFlag = new ValidationFlag(validateProps,false);
		protected var _cellMappingFlag:ValidationFlag = new ValidationFlag(validateCellMapping,false);
		protected var _breadthScrollFlag:ValidationFlag = new ValidationFlag(validateBreadthScroll,false);
		protected var _lengthScrollFlag:ValidationFlag = new ValidationFlag(validateLengthScroll,false);
		protected var _cellPosFlag:ValidationFlag = new ValidationFlag(validateCellPos,false);
		
		protected var _isVertical:Boolean;
		
		protected var _verticalAxis:GridAxis;
		protected var _horizontalAxis:GridAxis;
		
		protected var _breadthAxis:GridAxis;
		protected var _lengthAxis:GridAxis;
		
		public function AbstractGridLayout(scopeView:IView=null){
			super(scopeView);
			createAxes();
		}
		protected function createAxes():void{
			_horizontalAxis = new GridAxis("x","width","columnIndex");
			_verticalAxis = new GridAxis("y","height","rowIndex");
		}
		
		override public function removeSubject(subject:ILayoutSubject):void{
			super.removeSubject(subject);
			var cast:IGridLayoutSubject = (subject as IGridLayoutSubject);
			if(cast){
				cast.columnIndex = -1;
				cast.rowIndex = -1;
			}
		}
		/**
		 * Gets the collection of keys that will be used generate and store
		 * measurements and cell coordinates. In a normal case this would be
		 * the ILayoutSubject, but in the case of a renderer generating layout
		 * it would be the coordinate reference of the data.
		 */
		protected function getChildKeys():Dictionary{
			return _subjects;
		}
		/**
		 * Whether to remeasure this key.
		 */
		protected function remeasureChild(key:*):Boolean{
			return (_invalidSubjects[key] || !_cellMeasCache[key]);
		}
		/**
		 * The measurements of the object associated with this key.
		 */
		protected function getChildMeasurement(key:*):Point{
			return key.measurements;
		}
		/**
		 * The ILayoutInfo of the object associated with this key.
		 */
		protected function getChildLayoutInfo(key:*):ILayoutInfo{
			return key.layoutInfo;
		}
		/**
		 * The ILayoutSubject of the object associated with this key.
		 */
		protected function getChildRenderer(key:*,length:int,breadth:int):ILayoutSubject{
			return key as ILayoutSubject;
		}
		
		override protected function draw(): void{
			_propsFlag.validate();
			
			var hasInvalid:Boolean;
			for each(var i:* in _invalidSubjects){
				hasInvalid = true;
				break;
			}
			if(_allInvalid || hasInvalid){
				validateCellMeas();
			}
			_cellMappingFlag.validate();
			validateAllScrolling();
			_cellPosFlag.validate();
		}
		protected function validateProps():void{
			_isVertical = (_flowDirection==Direction.VERTICAL);
			if(_isVertical){
				_breadthAxis = _verticalAxis;
				_lengthAxis = _horizontalAxis;
				
				_lengthAxis.scrollMetrics = _horizontalAxis.scrollMetrics;
				_breadthAxis.scrollMetrics = _verticalAxis.scrollMetrics;
			}else{
				_breadthAxis = _horizontalAxis;
				_lengthAxis = _verticalAxis;
				
				_lengthAxis.scrollMetrics = _verticalAxis.scrollMetrics;
				_breadthAxis.scrollMetrics = _horizontalAxis.scrollMetrics;
			}
			_cellMappingFlag.invalidate();
			_breadthScrollFlag.invalidate();
			_lengthScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		protected function invalidateGapsAndMargins():void{
			_cellMappingFlag.invalidate();
			_breadthScrollFlag.invalidate();
			_lengthScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		protected function validateCellMeas():void{
			var allInvalid:Boolean = _allInvalid;
			var keys:Dictionary = getChildKeys();
			for(var key:* in keys){
				if(allInvalid || remeasureChild(key)){
					_cellMeasCache[key] = getChildMeasurement(key);
				}
			}
			if(!allInvalid){
				_invalidSubjects = new Dictionary();
			}else{
				_allInvalid = false;
			}
			_cellMappingFlag.invalidate();
			_breadthScrollFlag.invalidate();
			_lengthScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		/**
		 * Maps ILayoutSubjects into cell position arrays. Executes flowing behaviour
		 * (when cells wrap onto the next row/column). Also stores either the specifically set
		 * or the maximum size of each row/column.
		 */
		protected function validateCellMapping():void{
			var i:int;
			
			_cellPosCache = [];
			_breadthAxis.maxCellSizes = [];
			_lengthAxis.maxCellSizes = [];
			
			var breadthStackMax:Number;
			if(_pixelFlow){
				breadthStackMax = _displayPosition[_breadthAxis.dimRef]-_breadthAxis.foreMargin-_breadthAxis.aftMargin+_breadthAxis.gap;
			}
			
			var keys:Dictionary = getChildKeys();
			for(var key:* in keys){
				var subMeas:Point = _cellMeasCache[key];
				// derive grid position
				var breadthIndex:int;
				var lengthIndex:int;
				var posFound:Boolean = false;
				var layoutInfo:ILayoutInfo = getChildLayoutInfo(key);
				var gridLayout:IGridLayoutInfo = (layoutInfo as IGridLayoutInfo);
				if(gridLayout){
					if(_isVertical){
						breadthIndex = gridLayout.rowIndex;
						lengthIndex = gridLayout.columnIndex;
					}else{
						breadthIndex = gridLayout.columnIndex;
						lengthIndex = gridLayout.rowIndex;
					}
					if(lengthIndex!=-1){
						posFound = true;
					}
				}
				if(!posFound){
					var listLayout:IListLayoutInfo = (layoutInfo as IListLayoutInfo);
					if(listLayout){
						breadthIndex = listLayout.listIndex;
						lengthIndex = 0;
						posFound = true;
					}
				}
				if(subMeas && posFound){
					var subLengthDim:Number = subMeas[_lengthAxis.coordRef];
					var subBreadthDim:Number = subMeas[_breadthAxis.coordRef];
					var breadthIndices:Array;
					// do flowing behaviour
					var doFlow:Boolean;
					if(_breadthAxis.hasMaxCount && breadthIndex>=_breadthAxis.maxCount){
						doFlow = true;
						lengthIndex += Math.floor(breadthIndex/_breadthAxis.maxCount);
						breadthIndex = breadthIndex%_breadthAxis.maxCount;
					}
					if(breadthIndex==-1 || doFlow || _pixelFlow){
						var satisfied:Boolean = false;
						while(!satisfied){
							breadthIndices = _cellPosCache[lengthIndex];
							var breadthTotal:int;
							if(!breadthIndices){
								if(_breadthAxis.hasMaxCount){
									_cellPosCache[lengthIndex] = breadthIndices = [];
									breadthTotal = _breadthAxis.maxCount;
								}else{
									breadthIndex = 0;
									satisfied = true;
									break;
								}
							}else{
								if(_breadthAxis.hasMaxCount && _breadthAxis.maxCount>breadthIndices.length){
									breadthTotal = _breadthAxis.maxCount;
								}else{
									breadthTotal = breadthIndices.length+1;
								}
							}
							if(!satisfied){
								if(breadthIndex==-1){
									breadthIndex = 0;
								}
								var breadthStack:Number = 0;
								for(i=0; i<breadthTotal; i++){
									var otherKey:* = breadthIndices[i];
									var doWrap:Boolean = false;
									
									if(_pixelFlow){
										var cellBreadth:Number = NaN;
										if(_breadthAxis.hasCellSizes){
											cellBreadth = _breadthAxis.cellSizes[i%_breadthAxis.cellSizesCount];
										}else if(otherKey!=null){
											cellBreadth = _cellMeasCache[otherKey][_breadthAxis.coordRef];
										}else{
											cellBreadth = subMeas[_breadthAxis.coordRef];
										}
										breadthStack += cellBreadth+_breadthAxis.gap;
										if(breadthStack>breadthStackMax){
											doWrap = true;
										}
									}
									
									if(i>=breadthIndex){
										if(otherKey==null && !doWrap){
											breadthIndex = i;
											satisfied = true;
											break;
										}else{
											if(_breadthAxis.hasMaxCount && i>=_breadthAxis.maxCount){
												doWrap = true;
											}
										}
									}
									if(doWrap){
										breadthIndex = 0;
										lengthIndex++;
										break;
									}
								}
							}
						}
					}
					// store grid position
					breadthIndices = _cellPosCache[lengthIndex];
					if(!breadthIndices){
						_cellPosCache[lengthIndex] = breadthIndices = [];
					}
					if(breadthIndices[breadthIndex]){
						throw new Error("Two ILayoutSubjects have the same grid coords.");
					}else{
						breadthIndices[breadthIndex] = key;
					}
					
					// store measurements against grid position
					var currentMaxLength:Number = _lengthAxis.maxCellSizes[lengthIndex];
					if(isNaN(currentMaxLength) || currentMaxLength<subLengthDim){
						_lengthAxis.maxCellSizes[lengthIndex] = subLengthDim;
					}
					var currentMaxBredth:Number = _breadthAxis.maxCellSizes[breadthIndex];
					if(isNaN(currentMaxBredth) || currentMaxBredth<subBreadthDim){
						_breadthAxis.maxCellSizes[breadthIndex] = subBreadthDim;
					}
				}
			}
			var measChanged:Boolean;
			var maxLengthMeas:Number = _lengthAxis.foreMargin+_lengthAxis.aftMargin+(_lengthAxis.maxCellSizes.length-1)*_lengthAxis.gap;
			for(i=0; i<_lengthAxis.maxCellSizes.length; i++){
				subLengthDim = _lengthAxis.maxCellSizes[i];
				maxLengthMeas += (isNaN(subLengthDim)?0:subLengthDim);
				
				if(_lengthAxis.hasCellSizes){
					var specLength:Number = _lengthAxis.cellSizes[i%_lengthAxis.cellSizesCount];
					if(!isNaN(specLength)){
						_lengthAxis.maxCellSizes[i] = specLength;
					}
				}
			}
			if(_measurements[_lengthAxis.coordRef]!= maxLengthMeas){
				measChanged = true;
				_measurements[_lengthAxis.coordRef] = maxLengthMeas;
			}
			
			var maxBreadthMeas:Number = _breadthAxis.foreMargin+_breadthAxis.aftMargin+(_breadthAxis.maxCellSizes.length-1)*_breadthAxis.gap;
			for(i=0; i<_breadthAxis.maxCellSizes.length; i++){
				subBreadthDim = _breadthAxis.maxCellSizes[i];
				maxBreadthMeas += (isNaN(subBreadthDim)?0:subBreadthDim);
				
				if(_breadthAxis.hasCellSizes){
					var specBreadth:Number = _breadthAxis.cellSizes[i%_breadthAxis.cellSizesCount];
					if(!isNaN(specBreadth)){
						_breadthAxis.maxCellSizes[i] = specBreadth;
					}
				}
			}
			if(_measurements[_breadthAxis.coordRef]!=maxBreadthMeas){
				measChanged = true;
				_measurements[_breadthAxis.coordRef] = maxBreadthMeas;
			}
			
			if(measChanged){
				dispatchMeasurementChange();
			}
			_breadthScrollFlag.invalidate();
			_lengthScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		protected function validateAllScrolling():void{
			_breadthScrollFlag.validate();
			_lengthScrollFlag.validate();
		}
		protected function validateBreadthScroll():void{
			validateScroll(_breadthAxis.scrollMetrics,_breadthAxis);
			_cellPosFlag.invalidate();
		}
		protected function validateLengthScroll():void{
			validateScroll(_lengthAxis.scrollMetrics,_lengthAxis);
			_cellPosFlag.invalidate();
		}
		/**
		 * Corrects any overscrolling, validates maximum scroll values, converts line-by-line scrolling to pixel values
		 * (to be used by validateCellPos).
		 */
		protected function validateScroll(scrollMetrics:ScrollMetrics, axis:GridAxis):void{
			if(scrollMetrics.value<0 || isNaN(scrollMetrics.value))scrollMetrics.value = 0;
			
			var pixScroll:Number;
			var pixScrollMax:Number;
			var realDim:Number = _displayPosition[axis.dimRef];
			var realMeas:Number = measurements[axis.dimRef];
			if(realMeas>realDim){
				pixScrollMax = realMeas-realDim;
				if(axis.scrollByLine){
					var scrollValue:int = Math.round(scrollMetrics.value);
					var stack:Number = axis.foreMargin;
					var total:Number = 0;
					scrollMetrics.maximum = axis.maxCellSizes.length;
					for(var i:int=0; i<axis.maxCellSizes.length; i++){
						if(i==scrollValue){
							pixScroll = stack;
						}
						stack += axis.maxCellSizes[i];
						if(stack>pixScrollMax){
							scrollMetrics.pageSize = axis.maxCellSizes.length-i;
							if(isNaN(pixScroll)){
								pixScroll = pixScrollMax;
							}
							break;
						}
						stack += axis.gap;
					}
				}else{
					scrollMetrics.pageSize = realDim
					scrollMetrics.maximum = realMeas;
					pixScroll = scrollMetrics.value;
					if(pixScroll>pixScrollMax)pixScroll = pixScrollMax;
				}
			}else{
				pixScroll = 0;
				pixScrollMax = 0;
			}
			if(axis.pixScrollMetrics.maximum != realMeas || axis.pixScrollMetrics.pageSize != realDim || axis.pixScrollMetrics.value != pixScroll){
				axis.pixScrollMetrics.maximum = realMeas;
				axis.pixScrollMetrics.pageSize = realDim;
				axis.pixScrollMetrics.value = pixScroll;
				var dir:String = (scrollMetrics==_horizontalAxis.scrollMetrics)?Direction.HORIZONTAL:Direction.VERTICAL;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this, dir, axis.pixScrollMetrics);
			}
		}
		protected function validateCellPos():void{
			var equaliseLengths:Boolean = _lengthAxis.equaliseCells;
			var equaliseBreadths:Boolean = _breadthAxis.equaliseCells;
			var lengthStack:Number = _lengthAxis.foreMargin;
			var lengthCount:int=  _cellPosCache.length;
			for(var i:int=0; i<lengthCount; i++){
				var breadthIndices:Array = _cellPosCache[i];
				var length:Number = _lengthAxis.maxCellSizes[i];
				if(breadthIndices){
					var breadthStack:Number = _breadthAxis.foreMargin;
					
					var breadthCount:int = breadthIndices.length;
					for(var j:int=0; j<breadthCount; j++){
						var key:* = breadthIndices[j];
						var subMeas:Point = _cellMeasCache[key];
						if(subMeas){
							var subBreadthDim:Number;
							if(equaliseBreadths){
								subBreadthDim = _breadthAxis.maxCellSizes[j];
							}else{
								subBreadthDim = subMeas[_breadthAxis.coordRef];
							}
							
							var subLengthDim:Number;
							if(equaliseLengths){
								subLengthDim = length;
							}else{
								subLengthDim = subMeas[_lengthAxis.coordRef];
							}
							if(_isVertical){
								positionRenderer(key,i,j,
									_displayPosition.x+lengthStack-_lengthAxis.pixScrollMetrics.value,_displayPosition.y+breadthStack-_breadthAxis.pixScrollMetrics.value,
									subLengthDim,subBreadthDim);
							}else{
								positionRenderer(key,i,j,
									_displayPosition.x+breadthStack-_breadthAxis.pixScrollMetrics.value,_displayPosition.y+lengthStack-_lengthAxis.pixScrollMetrics.value,
									subBreadthDim,subLengthDim);
							}
							breadthStack += subBreadthDim+_breadthAxis.gap;
						}
					}
				}
				lengthStack += length+_lengthAxis.gap;
			}
		}
		// TODO: avoid casting all the time
		protected function positionRenderer(key:*, length:int, breadth:int, x:Number, y:Number, width:Number, height:Number):void{
			var renderer:ILayoutSubject = getChildRenderer(key,length,breadth);
			var cast:IGridLayoutSubject = (renderer as IGridLayoutSubject);
			if(cast){
				cast[_lengthAxis.indexRef] = length;
				cast[_breadthAxis.indexRef] = breadth;
			}
			if(renderer)renderer.setDisplayPosition(x,y,width,height);
		}
		
		// IScrollable implementation
		public function addScrollWheelListener(direction:String):Boolean{
			return false;
		}
		public function getScrollMetrics(direction:String):ScrollMetrics{
			if(direction==Direction.HORIZONTAL){
				return _horizontalAxis.scrollMetrics;
			}else{
				return _verticalAxis.scrollMetrics;
			}
		}
		public function setScrollMetrics(direction:String,metrics:ScrollMetrics):void{
			validateProps();
			_propsFlag.validate();
			var fillMetrics:ScrollMetrics;
			if(direction==this._flowDirection){
				_breadthScrollFlag.invalidate()
				fillMetrics = _breadthAxis.scrollMetrics;
			}else{
				_lengthScrollFlag.invalidate();
				fillMetrics = _lengthAxis.scrollMetrics;
			}
			fillMetrics.value = metrics.value;
			invalidate();
		}
		public function getScrollMultiplier(direction:String):Number{
			return 1;
		}
	}
}