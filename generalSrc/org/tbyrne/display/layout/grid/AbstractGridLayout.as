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
	 * In the AbstractGridLayout class, length is treated as the direction across the stacking of the list
	 * (i.e. width for a vertical list, height for a horizontal list) and breadth is treated as
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
					_lengthScrollFlag.invalidate();
				}else{
					_breadthScrollFlag.invalidate();
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
					_breadthScrollFlag.invalidate();
				}else{
					_lengthScrollFlag.invalidate();
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
		protected var _breadthScrollFlag:ValidationFlag = new ValidationFlag(validateBreadthScroll,false);
		protected var _lengthScrollFlag:ValidationFlag = new ValidationFlag(validateLengthScroll,false);
		protected var _cellPosFlag:ValidationFlag = new ValidationFlag(validateCellPos,false);
		
		protected var _verticalAxis:GridAxis;
		protected var _horizontalAxis:GridAxis;
		
		protected var _breadthAxis:GridAxis;
		protected var _lengthAxis:GridAxis;
		
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
		protected function getChildRenderer(key:*,length:int,breadth:int):ILayoutSubject{
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
			
			if(_noKeys)return;
			
			// this can save a lot of time for big data sets
			if(!_size.x && !_size.y)return;
			
			var pixelFlow:Boolean = _pixelFlow;
			
			var breadthStackMax:Number;
			if(pixelFlow){
				breadthStackMax = _size[_breadthAxis.coordRef]-_breadthAxis.foreMargin-_breadthAxis.aftMargin+_breadthAxis.gap;
			}
			
			var hasMaxBreadthCount:Boolean = _breadthAxis.hasMaxCount;
			var maxBreadthCount:int = _breadthAxis.maxCount;
			var hasBreadthCellSizes:Boolean = _breadthAxis.hasCellSizes;
			var renderersSameSize:Boolean = _renderersSameSize;
			var newAnyGridInfos:Boolean;
			
			var ignoreMaxCalcs:Boolean;
			
			if(renderersSameSize && pixelFlow){
				// in this case we can treat pixel flowing more like column flowing
				var sameMeasBreadth:Number = _sameCellMeas[_breadthAxis.coordRef];
				var sameMeasLength:Number = _sameCellMeas[_lengthAxis.coordRef];
				
				var maxBreadth:int = int(breadthStackMax/(sameMeasBreadth+_breadthAxis.gap));
				if(!hasMaxBreadthCount || maxBreadthCount>maxBreadth){
					maxBreadthCount = maxBreadth;
				}
				pixelFlow = false;
				hasMaxBreadthCount = true;
				
				
				// optimised way of finding max breadth/lengths
				/*var maxLength:int = int(getChildKeyCount()/maxBreadth);
				if(maxLength%1)maxLength += 1; // round up*/
				var keyCount:int = getChildKeyCount();
				var maxLength:int = Math.ceil(keyCount/maxBreadth);
				
				for(i=0; i<maxBreadthCount; ++i){
					_breadthAxis.maxCellSizes[i] = sameMeasBreadth;
				}
				for(i=0; i<maxLength; ++i){
					_lengthAxis.maxCellSizes[i] = sameMeasLength;
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
				var breadthIndex:int;
				var lengthIndex:int;
				var posFound:Boolean = false;
				var layoutInfo:ILayoutInfo = getChildLayoutInfo(key);
				
				if(_anyGridInfos){
					var gridLayout:IGridLayoutInfo = (layoutInfo as IGridLayoutInfo);
					if(gridLayout){
						newAnyGridInfos = true;
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
				}
				
				// if not we attempt to treat it as an item in a list (which will flow to fill the grid)
				if(!posFound){
					var listLayout:IListLayoutInfo = (layoutInfo as IListLayoutInfo);
					if(listLayout){
						breadthIndex = listLayout.listIndex;
						lengthIndex = 0;
						posFound = true;
					}
				}
				
				// if either of these succeeded and the cell has measurements we attempt to position it in the visible grid
				if(subMeas){
					var subLengthDim:Number = subMeas[_lengthAxis.coordRef];
					var subBreadthDim:Number = subMeas[_breadthAxis.coordRef];
					
					if(posFound){
						var breadthIndices:Array;
						var doFlow:Boolean;
						
						// if there's a maximum amount of columns/rows, we loop it here
						if(hasMaxBreadthCount && breadthIndex>=maxBreadthCount){
							doFlow = true;
							lengthIndex += Math.floor(breadthIndex/maxBreadthCount);
							breadthIndex = breadthIndex%maxBreadthCount;
						}
						
						/*
						Looping behaviour starts here:
						If there's still no breathIndex (it had an unknown/unfilled ILayoutInfo) we use pixelFlowing
						behaviour (this is uncommon).
						If the maximimum rows/cols were reached and therefore this cell was was wrapped then we also run
						through this logic.
						
						It continually wraps until it finds a row/col where it'll fit (some cells can already be filled
						by previous IGridLayoutInfo cells)
						*/
						if(breadthIndex==-1 || doFlow || pixelFlow){
							var satisfied:Boolean = false;
							
							if(breadthIndex==-1){
								breadthIndex = 0;
							}
							
							while(!satisfied){
								breadthIndices = _cellPosCache[lengthIndex];
								var breadthTotal:int;
								if(!breadthIndices){
									// if this row/col hasn't been encountered yet we create a position cache for it
									if(hasMaxBreadthCount){
										_cellPosCache[lengthIndex] = breadthIndices = [];
										breadthTotal = maxBreadthCount;
									}
									satisfied = true;
									break;
								}else{
									if(hasMaxBreadthCount && maxBreadthCount>breadthIndices.length){
										breadthTotal = maxBreadthCount;
									}else{
										// plus an extra one to give it room to wrap into
										breadthTotal = breadthIndices.length+2;
									}
								}
								if(!satisfied){
									var breadthStack:Number = 0;
									
									// loop through cells already added to this row to get total size up to intended index
									for(i=0; i<breadthTotal; i++){
										var otherKey:* = breadthIndices[i];
										var doWrap:Boolean = false;
										
										if(pixelFlow){
											// add to the stack and work out whether it needs to wrap (by pixel)
											var cellBreadth:Number = NaN;
											if(hasBreadthCellSizes){
												cellBreadth = _breadthAxis.cellSizes[i%_breadthAxis.cellSizesCount];
											}else if(otherKey!=null){
												cellBreadth = _cellMeasCache[otherKey][_breadthAxis.coordRef];
											}else{
												/*
												@TODO: this is an assumption. If a later cell fills this slot with
												different measurements to the current cell, it will fail.
												*/
												cellBreadth = subMeas[_breadthAxis.coordRef];
											}
											breadthStack += cellBreadth+_breadthAxis.gap;
											if(breadthStack>breadthStackMax){
												doWrap = true;
											}
										}
										
										// i>=breadthIndex tests whether we've yet passed the intended cell location
										if(!doWrap && i>=breadthIndex){
											if(_breadthAxis.hasMaxCount && i>=maxBreadthCount){
												// if we have exceeded the max cols/rows we wrap
												doWrap = true;
											}else if(otherKey==null){
												// else if slot is unoccupied we take it
												breadthIndex = i;
												satisfied = true;
												break;
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
							Log.error( "AbstractGridLayout.validateCellMapping: Two ILayoutSubjects have the same grid coords");
						}else{
							breadthIndices[breadthIndex] = key;
						}
					}
					
					if(!ignoreMaxCalcs){
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
			}
			_anyGridInfos = newAnyGridInfos;
			
			// if specific sizes have been set for rows/cols, we replace the calculated maxs here 
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
			
			var maxBreadthMeas:Number = _breadthAxis.foreMargin+_breadthAxis.aftMargin+(_breadthAxis.maxCellSizes.length-1)*_breadthAxis.gap;
			for(i=0; i<_breadthAxis.maxCellSizes.length; i++){
				subBreadthDim = _breadthAxis.maxCellSizes[i];
				maxBreadthMeas += (isNaN(subBreadthDim)?0:subBreadthDim);
				
				if(hasBreadthCellSizes){
					var specBreadth:Number = _breadthAxis.cellSizes[i%_breadthAxis.cellSizesCount];
					if(!isNaN(specBreadth)){
						_breadthAxis.maxCellSizes[i] = specBreadth;
					}
				}
			}
			
			// measurement changes get dispatched in the draw() function that wraps this doLayout function
			if(_measurements[_lengthAxis.coordRef]!= maxLengthMeas){
				_measurements[_lengthAxis.coordRef]= maxLengthMeas;
			}
			if(_measurements[_breadthAxis.coordRef]!= maxBreadthMeas){
				_measurements[_breadthAxis.coordRef]= maxBreadthMeas;
			}
			
			_breadthScrollFlag.invalidate();
			_lengthScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		protected function validateAllScrolling():void{
			_ignoreScrollChanges = true;
			_breadthScrollFlag.validate();
			_lengthScrollFlag.validate();
			_ignoreScrollChanges = false;
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
			var equaliseLengths:Boolean = _lengthAxis.equaliseCells;
			var equaliseBreadths:Boolean = _breadthAxis.equaliseCells;
			var lengthStack:Number = _lengthAxis.foreMargin;
			var lengthCount:int=  _cellPosCache.length;
			
			var lengthScroll:Number = __scrollRectMode?0:_lengthAxis.pixScrollMetrics.scrollValue;
			var breadthScroll:Number = __scrollRectMode?0:_breadthAxis.pixScrollMetrics.scrollValue;
			
			var breadthCount:int = _breadthAxis.maxCellSizes.length;
			
			for(var i:int=0; i<lengthCount; i++){
				var breadthIndices:Array = _cellPosCache[i];
				var length:Number = _lengthAxis.maxCellSizes[i];
				if(breadthIndices){
					var breadthStack:Number = _breadthAxis.foreMargin;
					
					for(var j:int=0; j<breadthCount; j++){
						var key:* = breadthIndices[j];
						var subMeas:Point = _cellMeasCache[key];
						
						var subBreadthDim:Number;
						if(equaliseBreadths || !subMeas){
							subBreadthDim = _breadthAxis.maxCellSizes[j];
						}else{
							subBreadthDim = subMeas[_breadthAxis.coordRef];
						}
						
						var subLengthDim:Number;
						if(equaliseLengths || !subMeas){
							subLengthDim = length;
						}else{
							subLengthDim = subMeas[_lengthAxis.coordRef];
						}
						
						if(_isVertical){
							positionRenderer(key,i,j,
								_position.x+lengthStack-lengthScroll,_position.y+breadthStack-breadthScroll,
								subLengthDim,subBreadthDim);
						}else{
							positionRenderer(key,i,j,
								_position.x+breadthStack-breadthScroll,_position.y+lengthStack-lengthScroll,
								subBreadthDim,subLengthDim);
						}
						breadthStack += subBreadthDim+_breadthAxis.gap;
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
		public function onVScrollMetricsChanged(from:IScrollMetrics):void{
			if(!_ignoreScrollChanges){
				_propsFlag.validate();
				if(_isVertical){
					_breadthScrollFlag.invalidate()
				}else{
					_lengthScrollFlag.invalidate();
				}
				validate(true);
			}
		}
		public function onHScrollMetricsChanged(from:IScrollMetrics):void{
			if(!_ignoreScrollChanges){
				_propsFlag.validate();
				if(!_isVertical){
					_breadthScrollFlag.invalidate()
				}else{
					_lengthScrollFlag.invalidate();
				}
				validate(true);
			}
		}
	}
}