package org.tbyrne.display.layout.grid
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.layout.AbstractCompositeLayout;
	import org.tbyrne.display.layout.AbstractLayout;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.display.layout.core.ILayoutInfo;
	import org.tbyrne.display.layout.list.IListLayoutInfo;
	import org.tbyrne.display.scrolling.IScrollMetrics;
	import org.tbyrne.display.scrolling.IScrollable;
	import org.tbyrne.display.scrolling.ScrollMetrics;
	import org.tbyrne.display.validation.ValidationFlag;
	
	/**
	 * In the AbstractGridLayout class, 'across' is treated as the direction across the stacking of the list
	 * (i.e. width for a vertical list, height for a horizontal list) and 'flow' is treated as
	 * the direction along the stacking of the list (i.e. height for vertical lists, width for
	 * horizontal lists).
	 */
	public class AbstractGridLayout extends AbstractCompositeLayout implements IScrollable
	{
		public function set margin(value:Number):void{
			marginTop = value;
			marginLeft = value;
			marginRight = value;
			marginBottom= value;
		}
		public function get marginTop():Number{
			return _verticalAxis.foreMargin;
		}
		public function set marginTop(value:Number):void{
			if(_verticalAxis.foreMargin!=value){
				_verticalAxis.foreMargin = value;
				invalidateGapsAndMargins();
				invalidateSize();
			}
		}
		
		public function get marginLeft():Number{
			return _horizontalAxis.foreMargin;
		}
		public function set marginLeft(value:Number):void{
			if(_horizontalAxis.foreMargin!=value){
				_horizontalAxis.foreMargin = value;
				invalidateGapsAndMargins();
				invalidateSize();
			}
		}
		
		public function get marginRight():Number{
			return _horizontalAxis.aftMargin;
		}
		public function set marginRight(value:Number):void{
			if(_horizontalAxis.aftMargin!=value){
				_horizontalAxis.aftMargin = value;
				invalidateGapsAndMargins();
				invalidateSize();
			}
		}
		
		public function get marginBottom():Number{
			return _verticalAxis.aftMargin;
		}
		public function set marginBottom(value:Number):void{
			if(_verticalAxis.aftMargin!=value){
				_verticalAxis.aftMargin = value;
				invalidateGapsAndMargins();
				invalidateSize();
			}
		}
		
		protected function get _horizontalGap():Number{
			return _horizontalAxis.gap;
		}
		protected function set _horizontalGap(value:Number):void{
			if(_horizontalAxis.gap!=value){
				_horizontalAxis.gap = value;
				invalidateGapsAndMargins();
				invalidateSize();
			}
		}
		
		protected function get _verticalGap():Number{
			return _verticalAxis.gap;
		}
		protected function set _verticalGap(value:Number):void{
			if(_verticalAxis.gap!=value){
				_verticalAxis.gap = value;
				invalidateGapsAndMargins();
				invalidateSize();
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
				invalidateSize();
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
				invalidateSize();
			}
		}
		
		protected function get _flowDirection():String{
			return __flowDirection;
		}
		protected function set _flowDirection(value:String):void{
			if(__flowDirection!=value){
				__flowDirection = value;
				_isVertical = (value==Direction.VERTICAL);
				_propsFlag.invalidate();
				invalidateSize();
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
				invalidateSize();
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
				invalidateSize();
			}
		}
		
		protected function get _horizontalScroll():Number{
			return _horizontalAxis.scrollMetrics.scrollValue;
		}
		protected function set _horizontalScroll(value:Number):void{
			if(_horizontalAxis.scrollMetrics.scrollValue!=value){
				_horizontalAxis.scrollMetrics.scrollValue = value;
			}
		}
		protected function get _horizontalScrollByLine():Boolean{
			return _horizontalAxis.scrollByLine;
		}
		protected function set _horizontalScrollByLine(value:Boolean):void{
			if(_horizontalAxis.scrollByLine!=value){
				_horizontalAxis.scrollByLine = value;
				if(_isVertical){
					_acrossScrollFlag.invalidate();
				}else{
					_flowScrollFlag.invalidate();
				}
				invalidateSize();
			}
		}
		
		protected function get _verticalScroll():Number{
			return _verticalAxis.scrollMetrics.scrollValue;
		}
		protected function set _verticalScroll(value:Number):void{
			if(_verticalAxis.scrollMetrics.scrollValue!=value){
				_verticalAxis.scrollMetrics.scrollValue = value;
			}
		}
		protected function get _verticalScrollByLine():Boolean{
			return _verticalAxis.scrollByLine;
		}
		protected function set _verticalScrollByLine(value:Boolean):void{
			if(_verticalAxis.scrollByLine!=value){
				_verticalAxis.scrollByLine = value;
				if(_isVertical){
					_flowScrollFlag.invalidate();
				}else{
					_acrossScrollFlag.invalidate();
				}
				invalidateSize();
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
				invalidateSize();
			}
		}
		protected function get _equaliseCellWidths():Boolean{
			return _horizontalAxis.equaliseCells;
		}
		protected function set _equaliseCellWidths(value:Boolean):void{
			if(_horizontalAxis.equaliseCells!=value){
				_horizontalAxis.equaliseCells = value;
				_cellPosFlag.invalidate();
				invalidateSize();
			}
		}
		/**
		 * When a row is smaller than the dimension (width or height) this evenly distributes
		 * remaining space across the cells.
		 */
		protected function get _fillFlow():Boolean{
			return __fillFlow;
		}
		protected function set _fillFlow(value:Boolean):void{
			if(__fillFlow!=value){
				__fillFlow = value;
				_cellPosFlag.invalidate();
				invalidateSize();
			}
		}
		protected function get _pixelFlow():Boolean{
			return __pixelFlow;
		}
		protected function set _pixelFlow(value:Boolean):void{
			if(__pixelFlow!=value){
				__pixelFlow = value;
				_cellMappingFlag.invalidate();
				invalidateSize();
			}
		}
		protected function get _renderersSameSize():Boolean{
			return __renderersSameSize;
		}
		protected function set _renderersSameSize(value:Boolean):void{
			if(__renderersSameSize!=value){
				__renderersSameSize = value;
				_cellMeasFlag.invalidate();
				invalidateSize();
			}
		}
		protected function get _scrollRectMode():Boolean{
			return __scrollRectMode;
		}
		protected function set _scrollRectMode(value:Boolean):void{
			if(__scrollRectMode!=value){
				__scrollRectMode = value;
				_cellPosFlag.invalidate();
				invalidateSize();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mouseWheel():IAct{
			if(!_mouseWheel)_mouseWheel = new Act();
			return _mouseWheel;
		}
		
		protected var _mouseWheel:Act;
		
		protected var __pixelFlow:Boolean;
		protected var __renderersSameSize:Boolean;
		protected var __scrollRectMode:Boolean;
		protected var __fillFlow:Boolean;
		
		protected var _sameCellMeas:Point; // when renderersSameSize is true the first measurement is stored here
		protected var _cellMeasCache:Dictionary = new Dictionary(true);
		protected var _cellPosCache:Array;
		
		protected var __flowDirection:String = Direction.VERTICAL;
		protected var _isVertical:Boolean = true;
		protected var _ignoreScrollChanges:Boolean;
		protected var _noKeys:Boolean;
		
		protected var _propsFlag:ValidationFlag = new ValidationFlag(validateProps,false);
		protected var _cellMeasFlag:ValidationFlag = new ValidationFlag(validateCellMeas,false);
		protected var _cellMappingFlag:ValidationFlag = new ValidationFlag(validateCellMapping,false);
		protected var _flowScrollFlag:ValidationFlag = new ValidationFlag(validateFlowScroll,false);
		protected var _acrossScrollFlag:ValidationFlag = new ValidationFlag(validateAcrossScroll,false);
		protected var _cellPosFlag:ValidationFlag = new ValidationFlag(validateCellPos,false);
		
		protected var _verticalAxis:GridAxis;
		protected var _horizontalAxis:GridAxis;
		
		protected var _flowDirectionAxis:GridAxis;
		protected var _acrossFlowAxis:GridAxis;
		
		protected var _subjectCount:int;
		
		// we can optimise heavily if no IGridLayoutInfo objects are added, we track that here
		protected var _anyGridInfos:Boolean;
		
		protected var _subjMeasChanged:Dictionary = new Dictionary();
		
		public function AbstractGridLayout(scopeView:IView=null){
			super(scopeView);
			createAxes();
			_horizontalAxis.scrollMetrics.scrollMetricsChanged.addHandler(onHScrollMetricsChanged);
			_verticalAxis.scrollMetrics.scrollMetricsChanged.addHandler(onVScrollMetricsChanged);
		}
		override protected function onSizeChanged(from:AbstractLayout, oldWidth:Number, oldHeight:Number): void{
			_cellMappingFlag.invalidate();
		}
		override protected function onSubjectMeasChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number): void{
			_subjMeasChanged[from] = true;
			_cellMeasFlag.invalidate();
			super.onSubjectMeasChanged(from, oldWidth, oldHeight);
		}
		protected function createAxes():void{
			_horizontalAxis = new GridAxis("x"/*,"width"*/,"columnIndex");
			_verticalAxis = new GridAxis("y"/*,"height"*/,"rowIndex");
		}
		
		override public function addSubject(subject:ILayoutSubject):Boolean{
			if(super.addSubject(subject)){
				if(!_anyGridInfos){
					if(subject.layoutInfo is IGridLayoutInfo){
						// this gets set back to false if the unoptimised version runs and notices no IGridLayoutInfos
						_anyGridInfos = true;
					}
				}
				++_subjectCount;
				return true;
			}else{
				return false;
			}
		}
		override public function removeSubject(subject:ILayoutSubject):Boolean{
			if(super.removeSubject(subject)){
				var cast:IGridLayoutSubject = (subject as IGridLayoutSubject);
				if(cast){
					cast.columnIndex = -1;
					cast.rowIndex = -1;
				}
				--_subjectCount;
				return true;
			}
			return false;
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
		protected function getChildKeyCount():int{
			return _subjectCount;
		}
		/**
		 * Whether to remeasure this key.
		 */
		protected function remeasureChild(key:*):Boolean{
			return (_subjMeasChanged[key] || !_cellMeasCache[key]);
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
		protected function getChildRenderer(key:*,across:int,flow:int):ILayoutSubject{
			return key as ILayoutSubject;
		}
		
		override protected function doLayout(): void{
			_propsFlag.validate();
			_cellMeasFlag.validate();
			_cellMappingFlag.validate();
			validateAllScrolling();
			_cellPosFlag.validate();
		}
		protected function validateProps():void{
			if(_isVertical){
				_flowDirectionAxis = _verticalAxis;
				_acrossFlowAxis = _horizontalAxis;
				
				_acrossFlowAxis.scrollMetrics = _horizontalAxis.scrollMetrics;
				_flowDirectionAxis.scrollMetrics = _verticalAxis.scrollMetrics;
			}else{
				_flowDirectionAxis = _horizontalAxis;
				_acrossFlowAxis = _verticalAxis;
				
				_acrossFlowAxis.scrollMetrics = _verticalAxis.scrollMetrics;
				_flowDirectionAxis.scrollMetrics = _horizontalAxis.scrollMetrics;
			}
			_cellMappingFlag.invalidate();
			_flowScrollFlag.invalidate();
			_acrossScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		protected function invalidateGapsAndMargins():void{
			_cellMappingFlag.invalidate();
			_flowScrollFlag.invalidate();
			_acrossScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		protected function validateCellMeas():void{
			_sameCellMeas = null;
			_noKeys = true;
			var keys:Dictionary = getChildKeys();
			for(var key:* in keys){
				_noKeys = false;
				if(remeasureChild(key)){
					if(_renderersSameSize){
						_sameCellMeas = getChildMeasurement(key);
						break;
					}else{
						_cellMeasCache[key] = getChildMeasurement(key);
					}
				}else if(_renderersSameSize){
					break;
				}
			}
			_subjMeasChanged = new Dictionary();
			
			_cellMappingFlag.invalidate();
			_flowScrollFlag.invalidate();
			_acrossScrollFlag.invalidate();
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
			_flowDirectionAxis.maxCellSizes = [];
			_acrossFlowAxis.maxCellSizes = [];
			
			if(_noKeys)return;
			
			// this can save a lot of time for big data sets
			if(!_size.x && !_size.y)return;
			
			var pixelFlow:Boolean = _pixelFlow;
			
			var flowStackMax:Number;
			if(pixelFlow){
				flowStackMax = _size[_flowDirectionAxis.coordRef]-_flowDirectionAxis.foreMargin-_flowDirectionAxis.aftMargin+_flowDirectionAxis.gap;
			}
			
			var hasMaxFlowCount:Boolean = _flowDirectionAxis.hasMaxCount;
			var maxFlowCount:int = _flowDirectionAxis.maxCount;
			var hasFlowCellSizes:Boolean = _flowDirectionAxis.hasCellSizes;
			var renderersSameSize:Boolean = _renderersSameSize;
			var newAnyGridInfos:Boolean;
			
			var ignoreMaxCalcs:Boolean;
			
			if(renderersSameSize && pixelFlow){
				// in this case we can treat pixel flowing more like column flowing
				var sameMeasFlow:Number = _sameCellMeas[_flowDirectionAxis.coordRef];
				var sameMeasAcross:Number = _sameCellMeas[_acrossFlowAxis.coordRef];
				
				var maxFlow:int = int(flowStackMax/(sameMeasFlow+_flowDirectionAxis.gap));
				if(!hasMaxFlowCount || maxFlowCount>maxFlow){
					maxFlowCount = maxFlow;
				}
				pixelFlow = false;
				hasMaxFlowCount = true;
				
				
				// optimised way of finding max flow/across
				var maxAcross:int = Math.ceil(getChildKeyCount()/maxFlow);
				
				for(i=0; i<maxFlowCount; ++i){
					_flowDirectionAxis.maxCellSizes[i] = sameMeasFlow;
				}
				for(i=0; i<maxAcross; ++i){
					_acrossFlowAxis.maxCellSizes[i] = sameMeasAcross;
				}
				ignoreMaxCalcs = true;
			}
			
			var keys:Dictionary = getChildKeys();
			for(var key:* in keys){
				var subMeas:Point;
				if(renderersSameSize){
					subMeas = _sameCellMeas;
				}else{
					subMeas = _cellMeasCache[key];
				}
				
				// if cell has specific grid position, we get it here
				var flowIndex:int;
				var acrossIndex:int;
				var posFound:Boolean = false;
				var layoutInfo:ILayoutInfo = getChildLayoutInfo(key);
				
				if(_anyGridInfos){
					var gridLayout:IGridLayoutInfo = (layoutInfo as IGridLayoutInfo);
					if(gridLayout){
						newAnyGridInfos = true;
						if(_isVertical){
							flowIndex = gridLayout.rowIndex;
							acrossIndex = gridLayout.columnIndex;
						}else{
							flowIndex = gridLayout.columnIndex;
							acrossIndex = gridLayout.rowIndex;
						}
						if(acrossIndex!=-1){
							posFound = true;
						}
					}
				}
				
				// if not we attempt to treat it as an item in a list (which will flow to fill the grid)
				if(!posFound){
					var listLayout:IListLayoutInfo = (layoutInfo as IListLayoutInfo);
					if(listLayout){
						flowIndex = listLayout.listIndex;
						acrossIndex = 0;
						posFound = true;
					}
				}
				
				// if either of these succeeded and the cell has measurements we attempt to position it in the visible grid
				if(subMeas){
					var subAcrossDim:Number = subMeas[_acrossFlowAxis.coordRef];
					var subFlowDim:Number = subMeas[_flowDirectionAxis.coordRef];
					
					if(posFound){
						var flowIndices:Array;
						var doFlow:Boolean;
						
						// if there's a maximum amount of columns/rows, we loop it here
						if(hasMaxFlowCount && flowIndex>=maxFlowCount){
							doFlow = true;
							acrossIndex += Math.floor(flowIndex/maxFlowCount);
							flowIndex = flowIndex%maxFlowCount;
						}
						
						/*
						Looping behaviour starts here:
						If there's still no flowIndex (it had an unknown/unfilled ILayoutInfo) we use pixelFlowing
						behaviour (this is uncommon).
						If the maximimum rows/cols were reached and therefore this cell was was wrapped then we also run
						through this logic.
						
						It continually wraps until it finds a row/col where it'll fit (some cells can already be filled
						by previous IGridLayoutInfo cells)
						*/
						if(flowIndex==-1 || doFlow || pixelFlow){
							var satisfied:Boolean = false;
							
							if(flowIndex==-1){
								flowIndex = 0;
							}
							
							while(!satisfied){
								flowIndices = _cellPosCache[acrossIndex];
								var flowTotal:int;
								if(!flowIndices){
									// if this row/col hasn't been encountered yet we create a position cache for it
									if(hasMaxFlowCount){
										_cellPosCache[acrossIndex] = flowIndices = [];
										flowTotal = maxFlowCount;
									}
									satisfied = true;
									break;
								}else{
									if(hasMaxFlowCount && maxFlowCount>flowIndices.length){
										flowTotal = maxFlowCount;
									}else{
										// plus an extra one to give it room to wrap into
										flowTotal = flowIndices.length+2;
									}
								}
								if(!satisfied){
									var flowStack:Number = 0;
									
									// loop through cells already added to this row to get total size up to intended index
									for(i=0; i<flowTotal; i++){
										var otherKey:* = flowIndices[i];
										var doWrap:Boolean = false;
										
										if(pixelFlow){
											// add to the stack and work out whether it needs to wrap (by pixel)
											var cellFlowSize:Number = NaN;
											if(hasFlowCellSizes){
												cellFlowSize = _flowDirectionAxis.cellSizes[i%_flowDirectionAxis.cellSizesCount];
											}else if(otherKey!=null){
												cellFlowSize = _cellMeasCache[otherKey][_flowDirectionAxis.coordRef];
											}else{
												/*
												@TODO: this is an assumption. If a later cell fills this slot with
												different measurements to the current cell, it will fail.
												*/
												cellFlowSize = subMeas[_flowDirectionAxis.coordRef];
											}
											flowStack += cellFlowSize+_flowDirectionAxis.gap;
											if(flowStack>flowStackMax){
												doWrap = true;
											}
										}
										
										// i>=flowIndex tests whether we've yet passed the intended cell location
										if(!doWrap && i>=flowIndex){
											if(_flowDirectionAxis.hasMaxCount && i>=maxFlowCount){
												// if we have exceeded the max cols/rows we wrap
												doWrap = true;
											}else if(otherKey==null){
												// else if slot is unoccupied we take it
												flowIndex = i;
												satisfied = true;
												break;
											}
										}
										if(doWrap){
											flowIndex = 0;
											acrossIndex++;
											break;
										}
									}
								}
							}
						}
						// store grid position
						flowIndices = _cellPosCache[acrossIndex];
						if(!flowIndices){
							_cellPosCache[acrossIndex] = flowIndices = [];
						}
						
						if(flowIndices[flowIndex]){
							Log.error( "AbstractGridLayout.validateCellMapping: Two ILayoutSubjects have the same grid coords");
						}else{
							flowIndices[flowIndex] = key;
						}
					}
					
					if(!ignoreMaxCalcs){
						// store measurements against grid position
						var currentMaxAcross:Number = _acrossFlowAxis.maxCellSizes[acrossIndex];
						if(isNaN(currentMaxAcross) || currentMaxAcross<subAcrossDim){
							_acrossFlowAxis.maxCellSizes[acrossIndex] = subAcrossDim;
						}
						var currentMaxFlow:Number = _flowDirectionAxis.maxCellSizes[flowIndex];
						if(isNaN(currentMaxFlow) || currentMaxFlow<subFlowDim){
							_flowDirectionAxis.maxCellSizes[flowIndex] = subFlowDim;
						}
					}
				}
			}
			_anyGridInfos = newAnyGridInfos;
			
			// if specific sizes have been set for rows/cols, we replace the calculated maxs here 
			var maxAcrossMeas:Number = _acrossFlowAxis.foreMargin+_acrossFlowAxis.aftMargin+(_acrossFlowAxis.maxCellSizes.length-1)*_acrossFlowAxis.gap;
			for(i=0; i<_acrossFlowAxis.maxCellSizes.length; i++){
				subAcrossDim = _acrossFlowAxis.maxCellSizes[i];
				maxAcrossMeas += (isNaN(subAcrossDim)?0:subAcrossDim);
				
				if(_acrossFlowAxis.hasCellSizes){
					var specAcross:Number = _acrossFlowAxis.cellSizes[i%_acrossFlowAxis.cellSizesCount];
					if(!isNaN(specAcross)){
						_acrossFlowAxis.maxCellSizes[i] = specAcross;
					}
				}
			}
			
			var maxFlowMeas:Number = _flowDirectionAxis.foreMargin+_flowDirectionAxis.aftMargin+(_flowDirectionAxis.maxCellSizes.length-1)*_flowDirectionAxis.gap;
			for(i=0; i<_flowDirectionAxis.maxCellSizes.length; i++){
				subFlowDim = _flowDirectionAxis.maxCellSizes[i];
				maxFlowMeas += (isNaN(subFlowDim)?0:subFlowDim);
				
				if(hasFlowCellSizes){
					var specFlowSize:Number = _flowDirectionAxis.cellSizes[i%_flowDirectionAxis.cellSizesCount];
					if(!isNaN(specFlowSize)){
						_flowDirectionAxis.maxCellSizes[i] = specFlowSize;
					}
				}
			}
			
			// measurement changes get dispatched in the draw() function that wraps this doLayout function
			if(_measurements[_acrossFlowAxis.coordRef]!= maxAcrossMeas){
				_measurements[_acrossFlowAxis.coordRef]= maxAcrossMeas;
			}
			if(_measurements[_flowDirectionAxis.coordRef]!= maxFlowMeas){
				_measurements[_flowDirectionAxis.coordRef]= maxFlowMeas;
			}
			
			_flowScrollFlag.invalidate();
			_acrossScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		protected function validateAllScrolling():void{
			_ignoreScrollChanges = true;
			_flowScrollFlag.validate();
			_acrossScrollFlag.validate();
			_ignoreScrollChanges = false;
		}
		protected function validateFlowScroll():void{
			validateScroll(_flowDirectionAxis.scrollMetrics,_flowDirectionAxis);
			_cellPosFlag.invalidate();
		}
		protected function validateAcrossScroll():void{
			validateScroll(_acrossFlowAxis.scrollMetrics,_acrossFlowAxis);
			_cellPosFlag.invalidate();
		}
		/**
		 * Corrects any overscrolling, validates maximum scroll values, converts line-by-line scrolling to pixel values
		 * (to be used by validateCellPos).
		 */
		protected function validateScroll(scrollMetrics:ScrollMetrics, axis:GridAxis):void{
			if(scrollMetrics.scrollValue<0 || isNaN(scrollMetrics.scrollValue))scrollMetrics.scrollValue = 0;
			
			var pixScroll:Number;
			var pixScrollMax:Number;
			var realDim:Number = _size[axis.coordRef];
			var realMeas:Number = midDrawMeas[axis.coordRef];
			if(realMeas>realDim){
				pixScrollMax = realMeas-realDim;
				if(axis.scrollByLine){
					var scrollValue:int = Math.round(scrollMetrics.scrollValue);
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
					pixScroll = scrollMetrics.scrollValue;
					if(pixScroll>pixScrollMax)pixScroll = pixScrollMax;
				}
			}else{
				pixScroll = 0;
				pixScrollMax = 0;
			}
			if(axis.pixScrollMetrics.maximum != realMeas || axis.pixScrollMetrics.pageSize != realDim || axis.pixScrollMetrics.scrollValue != pixScroll){
				axis.pixScrollMetrics.maximum = realMeas;
				axis.pixScrollMetrics.pageSize = realDim;
				axis.pixScrollMetrics.scrollValue = pixScroll;
			}
		}
		protected function validateCellPos():void{
			var equaliseAcrossSizes:Boolean = _acrossFlowAxis.equaliseCells;
			var equaliseFlowSizes:Boolean = _flowDirectionAxis.equaliseCells;
			
			var acrossStack:Number = _acrossFlowAxis.foreMargin;
			var acrossCount:int=  _cellPosCache.length;
			
			var acrossScroll:Number = __scrollRectMode?0:_acrossFlowAxis.pixScrollMetrics.scrollValue;
			var flowScroll:Number = __scrollRectMode?0:_flowDirectionAxis.pixScrollMetrics.scrollValue;
			
			var flowCount:int = _flowDirectionAxis.maxCellSizes.length;
			
			var realSize:Number = _size[_flowDirectionAxis.coordRef];
			
			//var flowFills:Vector.<Number> = new Vector.<Number>(flowCount, false);
			
			for(var i:int=0; i<acrossCount; i++){
				var flowIndices:Array = _cellPosCache[i];
				var acrossMax:Number = _acrossFlowAxis.maxCellSizes[i];
				
				var j:int;
				var key:*;
				var subMeas:Point;
				
				if(flowIndices){
					var flowStack:Number = _flowDirectionAxis.foreMargin;
					
					var fillSize:Number;
					
					if(__fillFlow){
						var remainingSize:Number = realSize-_flowDirectionAxis.foreMargin-_flowDirectionAxis.aftMargin-(_flowDirectionAxis.gap*(flowCount-1));
						fillSize = (remainingSize/flowCount);
						
						
						// TODO: move these fill calculations higher up in the validation cycle (probably into the and of the cell mapping/flowing code)
						if(!equaliseFlowSizes){
							var searching:Boolean = true;
							var elligable:Array = flowIndices.concat();
							while(searching){
								searching = false;
								for(j=0; j<elligable.length; j++){
									key = elligable[j];
									subMeas = _cellMeasCache[key];
									var flowMeas:Number = subMeas[_flowDirectionAxis.coordRef];
									if(subMeas && flowMeas>fillSize){
										elligable.splice(j,1);
										remainingSize -= flowMeas;
										fillSize = (remainingSize/elligable.length);
										searching = true;
										break;
									}
									
								}
							}
						}
					}
					
					for(j=0; j<flowCount; j++){
						key = flowIndices[j];
						if(key!=null){
							subMeas = _cellMeasCache[key];
							
							var subFlowDim:Number = subMeas[_flowDirectionAxis.coordRef];
							if(__fillFlow && (equaliseFlowSizes || subFlowDim<fillSize)){
								subFlowDim = fillSize;
							}else if(equaliseFlowSizes || !subMeas){
								subFlowDim = _flowDirectionAxis.maxCellSizes[j];
							}
							
							var subAcrossDim:Number;
							if(equaliseAcrossSizes || !subMeas){
								subAcrossDim = acrossMax;
							}else{
								subAcrossDim = subMeas[_acrossFlowAxis.coordRef];
							}
							
							if(_isVertical){
								positionRenderer(key,i,j,
									_position.x+acrossStack-acrossScroll,_position.y+flowStack-flowScroll,
									subAcrossDim,subFlowDim);
							}else{
								positionRenderer(key,i,j,
									_position.x+flowStack-flowScroll,_position.y+acrossStack-acrossScroll,
									subFlowDim,subAcrossDim);
							}
							flowStack += subFlowDim+_flowDirectionAxis.gap;
						}
					}
				}
				acrossStack += acrossMax+_acrossFlowAxis.gap;
			}
		}
		// TODO: avoid casting all the time
		protected function positionRenderer(key:*, acrossSize:int, flowSize:int, x:Number, y:Number, width:Number, height:Number):void{
			var renderer:ILayoutSubject = getChildRenderer(key,acrossSize,flowSize);
			var cast:IGridLayoutSubject = (renderer as IGridLayoutSubject);
			if(cast){
				cast[_acrossFlowAxis.indexRef] = acrossSize;
				cast[_flowDirectionAxis.indexRef] = flowSize;
			}
			if(renderer){
				renderer.setPosition(x,y);
				renderer.setSize(width,height);
			}
		}
		
		// IScrollable implementation
		public function getScrollMetrics(direction:String):IScrollMetrics{
			if(direction==Direction.HORIZONTAL){
				return _horizontalAxis.scrollMetrics;
			}else{
				return _verticalAxis.scrollMetrics;
			}
		}
		public function getPixScrollMetrics(direction:String):IScrollMetrics{
			if(direction==Direction.HORIZONTAL){
				return _horizontalAxis.pixScrollMetrics;
			}else{
				return _verticalAxis.pixScrollMetrics;
			}
		}
		public function onVScrollMetricsChanged(from:IScrollMetrics):void{
			if(!_ignoreScrollChanges){
				_propsFlag.validate();
				if(_isVertical){
					_flowScrollFlag.invalidate()
				}else{
					_acrossScrollFlag.invalidate();
				}
				validate(true);
			}
		}
		public function onHScrollMetricsChanged(from:IScrollMetrics):void{
			if(!_ignoreScrollChanges){
				_propsFlag.validate();
				if(!_isVertical){
					_flowScrollFlag.invalidate()
				}else{
					_acrossScrollFlag.invalidate();
				}
				validate(true);
			}
		}
	}
}