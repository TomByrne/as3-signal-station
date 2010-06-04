package org.farmcode.display.layout.grid
{
	import au.com.thefarmdigital.display.scrolling.IScrollable;
	import au.com.thefarmdigital.structs.ScrollMetrics;
	
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.ValidationFlag;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.layout.AbstractLayout;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.layout.list.IListLayoutInfo;
	
	/**
	 * In the AbstractGridLayout class, length is treated as the direction across the stacking of the list
	 * (i.e. width for a vertical list, height for a horizontal list) and breadth is treated as
	 * the direction along the stacking of the list (i.e. height for vertical lists, width for
	 * horizontal lists).
	 */
	public class AbstractGridLayout extends AbstractLayout implements IScrollable
	{
		public function get marginTop():Number{
			return _marginTop;
		}
		public function set marginTop(value:Number):void{
			if(_marginTop!=value){
				_marginTop = value;
				_marginFlag.invalidate();
				invalidate();
			}
		}
		
		public function get marginLeft():Number{
			return _marginLeft;
		}
		public function set marginLeft(value:Number):void{
			if(_marginLeft!=value){
				_marginLeft = value;
				_marginFlag.invalidate();
				invalidate();
			}
		}
		
		public function get marginRight():Number{
			return _marginRight;
		}
		public function set marginRight(value:Number):void{
			if(_marginRight!=value){
				_marginRight = value;
				_marginFlag.invalidate();
				invalidate();
			}
		}
		
		public function get marginBottom():Number{
			return _marginBottom;
		}
		public function set marginBottom(value:Number):void{
			if(_marginBottom!=value){
				_marginBottom = value;
				_marginFlag.invalidate();
				invalidate();
			}
		}
		
		protected function get _horizontalGap():Number{
			return __horizontalGap;
		}
		protected function set _horizontalGap(value:Number):void{
			if(__horizontalGap!=value){
				__horizontalGap = value;
				_gapsFlag.invalidate();
				invalidate();
			}
		}
		
		protected function get _verticalGap():Number{
			return __verticalGap;
		}
		protected function set _verticalGap(value:Number):void{
			if(__verticalGap!=value){
				__verticalGap = value;
				_gapsFlag.invalidate();
				invalidate();
			}
		}
		
		protected function get _maxColumns():int{
			return __maxColumns;
		}
		protected function set _maxColumns(value:int):void{
			if(__maxColumns!=value){
				__maxColumns = value;
				_cellMappingFlag.invalidate();
				invalidate();
			}
		}
		protected function get _maxRows():int{
			return __maxRows;
		}
		protected function set _maxRows(value:int):void{
			if(__maxRows!=value){
				__maxRows = value;
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
			return __columnWidths;
		}
		protected function set _columnWidths(value:Array):void{
			if(__columnWidths!=value){
				__columnWidths = value;
				_cellMappingFlag.invalidate();
				invalidate();
			}
		}
		
		protected function get _rowHeights():Array{
			return __rowHeights;
		}
		protected function set _rowHeights(value:Array):void{
			if(__rowHeights!=value){
				__rowHeights = value;
				_cellMappingFlag.invalidate();
				invalidate();
			}
		}
		
		protected function get _horizontalScroll():Number{
			return _horizontalScrollMetrics.value;
		}
		protected function set _horizontalScroll(value:Number):void{
			if(_horizontalScrollMetrics.value!=value){
				_horizontalScrollMetrics.value = value;
				if(__flowDirection==Direction.VERTICAL){
					_lengthScrollFlag.invalidate();
				}else{
					_breadthScrollFlag.invalidate();
				}
				invalidate();
			}
		}
		protected function get _horizontalScrollByLine():Boolean{
			return __horizontalScrollByLine;
		}
		protected function set _horizontalScrollByLine(value:Boolean):void{
			if(__horizontalScrollByLine!=value){
				__horizontalScrollByLine = value;
				if(__flowDirection==Direction.VERTICAL){
					_lengthScrollFlag.invalidate();
				}else{
					_breadthScrollFlag.invalidate();
				}
				invalidate();
			}
		}
		
		protected function get _verticalScroll():Number{
			return _verticalScrollMetrics.value;
		}
		protected function set _verticalScroll(value:Number):void{
			if(_verticalScrollMetrics.value!=value){
				_verticalScrollMetrics.value = value;
				if(__flowDirection==Direction.VERTICAL){
					_breadthScrollFlag.invalidate();
				}else{
					_lengthScrollFlag.invalidate();
				}
				invalidate();
			}
		}
		protected function get _verticalScrollByLine():Boolean{
			return __verticalScrollByLine;
		}
		protected function set _verticalScrollByLine(value:Boolean):void{
			if(__verticalScrollByLine!=value){
				__verticalScrollByLine = value;
				if(__flowDirection==Direction.VERTICAL){
					_breadthScrollFlag.invalidate();
				}else{
					_lengthScrollFlag.invalidate();
				}
				invalidate();
			}
		}
		
		protected function get _maxVerticalScroll():Number{
			return _verticalScrollMetrics.maximum;
		}
		
		protected function get _maxHorizontalScroll():Number{
			return _horizontalScrollMetrics.maximum;
		}
		
		protected function get _equaliseCellHeights():Boolean{
			return __equaliseCellHeights;
		}
		protected function set _equaliseCellHeights(value:Boolean):void{
			if(__equaliseCellHeights!=value){
				__equaliseCellHeights = value;
				_cellPosFlag.invalidate();
				invalidate();
			}
		}
		protected function get _equaliseCellWidths():Boolean{
			return __equaliseCellWidths;
		}
		protected function set _equaliseCellWidths(value:Boolean):void{
			if(__equaliseCellWidths!=value){
				__equaliseCellWidths = value;
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
		
		private var __equaliseCellWidths:Boolean;
		private var __equaliseCellHeights:Boolean;
		
		private var _marginBottom:Number = 0;
		private var _marginRight:Number = 0;
		private var _marginLeft:Number = 0;
		private var _marginTop:Number = 0;
		
		protected var _cellMeasCache:Dictionary = new Dictionary(true);
		protected var _cellPosCache:Array;
		
		private var __verticalScrollByLine:Boolean;
		private var __horizontalScrollByLine:Boolean;
		
		protected var _verticalScrollMetrics:ScrollMetrics = new ScrollMetrics();
		protected var _horizontalScrollMetrics:ScrollMetrics = new ScrollMetrics();
		
		protected var _lengthScrollMetrics:ScrollMetrics;
		protected var _breadthScrollMetrics:ScrollMetrics;
		
		protected var _lengthPixScrollMetrics:ScrollMetrics = new ScrollMetrics();
		protected var _breadthPixScrollMetrics:ScrollMetrics = new ScrollMetrics();
		
		private var __rowHeights:Array;
		private var __columnWidths:Array;
		private var __flowDirection:String = Direction.VERTICAL;
		private var __maxRows:int = -1;
		private var __maxColumns:int = -1;
		private var __verticalGap:Number;
		private var __horizontalGap:Number;
		
		protected var _propsFlag:ValidationFlag = new ValidationFlag(validateProps,false);
		protected var _marginFlag:ValidationFlag = new ValidationFlag(validateMargins,false);
		protected var _gapsFlag:ValidationFlag = new ValidationFlag(validateGaps,false);
		protected var _cellMappingFlag:ValidationFlag = new ValidationFlag(validateCellMapping,false);
		protected var _breadthScrollFlag:ValidationFlag = new ValidationFlag(validateBreadthScroll,false);
		protected var _lengthScrollFlag:ValidationFlag = new ValidationFlag(validateLengthScroll,false);
		protected var _cellPosFlag:ValidationFlag = new ValidationFlag(validateCellPos,false);
		
		// the following are cached variables to speed up calculation
		protected var _isVertical:Boolean;
		protected var _breadthCoordRef:String;
		protected var _breadthDimRef:String;
		protected var _lengthCoordRef:String;
		protected var _lengthDimRef:String;
		
		private var _foreBreadthRef:String;
		private var _aftBreadthRef:String;
		private var _foreLengthRef:String;
		private var _aftLengthRef:String;
		
		private var _foreBreadth:Number;
		private var _aftBreadth:Number;
		private var _foreLength:Number;
		private var _aftLength:Number;
		
		private var _breadthGapRef:String;
		private var _lengthGapRef:String;
		
		private var _breadthGap:Number;
		private var _lengthGap:Number;
		
		private var _maxBreadthCountRef:String;
		
		private var _maxBreadthCount:int;
		private var _hasMaxBreadth:Boolean;
		
		private var _cellBreadthsRef:String;
		private var _cellLengthsRef:String;
		
		private var _cellBreadths:Array;
		private var _cellLengths:Array;
		private var _maxCellBreadths:Array;
		private var _maxCellLengths:Array;
		private var _hasCellBreadths:Boolean;
		private var _hasCellLengths:Boolean;
		private var _cellBreadthsCount:int;
		private var _cellLengthsCount:int;
		
		private var _breadthScrollByLineRef:String;
		private var _lengthScrollByLineRef:String;
		
		private var _equaliseCellBreadthsRef:String;
		private var _equaliseCellLengthsRef:String;
		
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
		protected function getChildMeasurement(key:*):Rectangle{
			return key.displayMeasurements;
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
			_marginFlag.validate();
			_gapsFlag.validate();
			
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
				_breadthCoordRef = "y";
				_breadthDimRef = "height";
				_lengthCoordRef = "x";
				_lengthDimRef = "width";
				
				_foreBreadthRef = "marginTop";
				_aftBreadthRef = "marginBottom";
				_foreLengthRef = "marginLeft";
				_aftLengthRef = "marginRight";
				
				_breadthGapRef = "_verticalGap";
				_lengthGapRef = "_horizontalGap";
				
				_maxBreadthCountRef = "_maxRows";
				
				_cellBreadthsRef = "_rowHeights";
				_cellLengthsRef = "_columnWidths";
				
				_breadthScrollByLineRef = "_verticalScrollByLine";
				_lengthScrollByLineRef = "_horizontalScrollByLine";
				
				_lengthScrollMetrics = _horizontalScrollMetrics;
				_breadthScrollMetrics = _verticalScrollMetrics;
				
				_equaliseCellBreadthsRef = "_equaliseCellHeights";
				_equaliseCellLengthsRef = "_equaliseCellWidths";
			}else{
				_breadthCoordRef = "x";
				_breadthDimRef = "width";
				_lengthCoordRef = "y";
				_lengthDimRef = "height";
				
				_foreBreadthRef = "marginLeft";
				_aftBreadthRef = "marginRight";
				_foreLengthRef = "marginTop";
				_aftLengthRef = "marginBottom";
				
				_breadthGapRef = "_horizontalGap";
				_lengthGapRef = "_verticalGap";
				
				_maxBreadthCountRef = "_maxColumns";
				
				_cellBreadthsRef = "_columnWidths";
				_cellLengthsRef = "_rowHeights";
				
				_breadthScrollByLineRef = "_horizontalScrollByLine";
				_lengthScrollByLineRef = "_verticalScrollByLine";
				
				_lengthScrollMetrics = _verticalScrollMetrics;
				_breadthScrollMetrics = _horizontalScrollMetrics;
				
				_equaliseCellBreadthsRef = "_equaliseCellWidths";
				_equaliseCellLengthsRef = "_equaliseCellHeights";
			}
			_marginFlag.invalidate();
			_cellMappingFlag.invalidate();
			_breadthScrollFlag.invalidate();
			_lengthScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		protected function validateMargins():void{
			_foreBreadth = this[_foreBreadthRef];
			if(isNaN(_foreBreadth))_foreBreadth = 0;
			
			_aftBreadth = this[_aftBreadthRef];
			if(isNaN(_aftBreadth))_aftBreadth = 0;
			
			_foreLength = this[_foreLengthRef];
			if(isNaN(_foreLength))_foreLength = 0;
			
			_aftLength = this[_aftLengthRef];
			if(isNaN(_aftLength))_aftLength = 0;
			
			_cellMappingFlag.invalidate();
			_breadthScrollFlag.invalidate();
			_lengthScrollFlag.invalidate();
			_cellPosFlag.invalidate();
		}
		protected function validateGaps():void{
			_breadthGap = this[_breadthGapRef];
			if(isNaN(_breadthGap))_breadthGap = 0;
			
			_lengthGap = this[_lengthGapRef];
			if(isNaN(_lengthGap))_lengthGap = 0;
			
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
			
			_maxBreadthCount = this[_maxBreadthCountRef];
			_hasMaxBreadth = (_maxBreadthCount!=-1);
			
			_cellPosCache = [];
			_maxCellBreadths = [];
			_maxCellLengths = [];
			
			_cellBreadths = this[_cellBreadthsRef];
			if(_cellBreadths){
				_hasCellBreadths = true;
				_cellBreadthsCount = _cellBreadths.length;
			}
			_cellLengths = this[_cellLengthsRef];
			if(_cellLengths){
				_hasCellLengths = true;
				_cellLengthsCount = _cellLengths.length;
			}
			
			var breadthStackMax:Number;
			if(_pixelFlow){
				breadthStackMax = _displayPosition[_breadthDimRef]-_foreBreadth-_aftBreadth+_breadthGap;
			}
			
			var keys:Dictionary = getChildKeys();
			for(var key:* in keys){
				var subMeas:Rectangle = _cellMeasCache[key];
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
					var subLengthDim:Number = subMeas[_lengthDimRef];
					var subBreadthDim:Number = subMeas[_breadthDimRef];
					var breadthIndices:Array;
					// do flowing behaviour
					var doFlow:Boolean;
					if(_hasMaxBreadth && breadthIndex>=_maxBreadthCount){
						doFlow = true;
						lengthIndex += Math.floor(breadthIndex/_maxBreadthCount);
						breadthIndex = breadthIndex%_maxBreadthCount;
					}
					if(breadthIndex==-1 || doFlow || _pixelFlow){
						var satisfied:Boolean = false;
						while(!satisfied){
							breadthIndices = _cellPosCache[lengthIndex];
							var breadthTotal:int;
							if(!breadthIndices){
								if(_hasMaxBreadth){
									_cellPosCache[lengthIndex] = breadthIndices = [];
									breadthTotal = _maxBreadthCount;
								}else{
									breadthIndex = 0;
									satisfied = true;
									break;
								}
							}else{
								if(_hasMaxBreadth && _maxBreadthCount>breadthIndices.length){
									breadthTotal = _maxBreadthCount;
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
										if(_hasCellBreadths){
											cellBreadth = _cellBreadths[i%_cellBreadthsCount];
										}else if(otherKey!=null){
											cellBreadth = _cellMeasCache[otherKey][_breadthDimRef];
										}else{
											cellBreadth = subMeas[_breadthDimRef];
										}
										breadthStack += cellBreadth+_breadthGap;
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
											if(_hasMaxBreadth && i>=_maxBreadthCount){
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
					var currentMaxLength:Number = _maxCellLengths[lengthIndex];
					if(isNaN(currentMaxLength) || currentMaxLength<subLengthDim){
						_maxCellLengths[lengthIndex] = subLengthDim;
					}
					var currentMaxBredth:Number = _maxCellBreadths[breadthIndex];
					if(isNaN(currentMaxBredth) || currentMaxBredth<subBreadthDim){
						_maxCellBreadths[breadthIndex] = subBreadthDim;
					}
				}
			}
			var measChanged:Boolean;
			var maxLengthMeas:Number = _foreLength+_aftLength+(_maxCellLengths.length-1)*_lengthGap;
			for(i=0; i<_maxCellLengths.length; i++){
				subLengthDim = _maxCellLengths[i];
				maxLengthMeas += (isNaN(subLengthDim)?0:subLengthDim);
				
				if(_hasCellLengths){
					var specLength:Number = _cellLengths[i%_cellLengthsCount];
					if(!isNaN(specLength) && subLengthDim<specLength){
						_maxCellLengths[i] = specLength;
					}
				}
			}
			if(displayMeasurements[_lengthDimRef]!= maxLengthMeas){
				measChanged = true;
				displayMeasurements[_lengthDimRef] = maxLengthMeas;
			}
			
			var maxBreadthMeas:Number = _foreBreadth+_aftBreadth+(_maxCellBreadths.length-1)*_breadthGap;
			for(i=0; i<_maxCellBreadths.length; i++){
				subBreadthDim = _maxCellBreadths[i];
				maxBreadthMeas += (isNaN(subBreadthDim)?0:subBreadthDim);
				
				if(_hasCellBreadths){
					var specBreadth:Number = _cellBreadths[i%_cellBreadthsCount];
					if(!isNaN(specBreadth) && subBreadthDim<specBreadth){
						_maxCellBreadths[i] = specBreadth;
					}
				}
			}
			if(displayMeasurements[_breadthDimRef]!=maxBreadthMeas){
				measChanged = true;
				displayMeasurements[_breadthDimRef] = maxBreadthMeas;
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
			validateScroll(_breadthScrollMetrics,_breadthPixScrollMetrics,_breadthDimRef,_maxCellBreadths,_foreBreadth,this[_breadthScrollByLineRef], _foreBreadth, _breadthGap);
			_cellPosFlag.invalidate();
		}
		protected function validateLengthScroll():void{
			validateScroll(_lengthScrollMetrics,_lengthPixScrollMetrics,_lengthDimRef,_maxCellLengths,_foreLength,this[_lengthScrollByLineRef], _foreLength, _lengthGap);
			_cellPosFlag.invalidate();
		}
		/**
		 * Corrects any overscrolling, validates maximum scroll values, converts line-by-line scrolling to pixel values
		 * (to be used by validateCellPos).
		 */
		protected function validateScroll(scrollMetrics:ScrollMetrics, pixScrollMetrics:ScrollMetrics, realDimDef:String, measurements:Array,
										  margin:Number, scrollByLine:Boolean, forePadding:Number, gap:Number):void{
			if(scrollMetrics.value<0 || isNaN(scrollMetrics.value))scrollMetrics.value = 0;
			
			var pixScroll:Number;
			var pixScrollMax:Number;
			var realDim:Number = _displayPosition[realDimDef];
			var realMeas:Number = displayMeasurements[realDimDef];
			if(realMeas>realDim){
				pixScrollMax = realMeas-realDim;
				if(scrollByLine){
					var scrollValue:int = Math.round(scrollMetrics.value);
					var stack:Number = forePadding;
					var total:Number = 0;
					scrollMetrics.maximum = measurements.length;
					for(var i:int=0; i<measurements.length; i++){
						if(i==scrollValue){
							pixScroll = stack;
						}
						stack += measurements[i];
						if(stack>pixScrollMax){
							scrollMetrics.pageSize = measurements.length-i;
							if(isNaN(pixScroll)){
								pixScroll = pixScrollMax;
							}
							break;
						}
						stack += gap;
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
			if(pixScrollMetrics.maximum != realMeas || pixScrollMetrics.pageSize != realDim || pixScrollMetrics.value != pixScroll){
				pixScrollMetrics.maximum = realMeas;
				pixScrollMetrics.pageSize = realDim;
				pixScrollMetrics.value = pixScroll;
				var dir:String = (scrollMetrics==_horizontalScrollMetrics)?Direction.HORIZONTAL:Direction.VERTICAL;
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this, dir, pixScrollMetrics);
			}
		}
		protected function validateCellPos():void{
			var equaliseLengths:Boolean = this[_equaliseCellLengthsRef];
			var equaliseBreadths:Boolean = this[_equaliseCellBreadthsRef];
			var lengthStack:Number = _foreLength;
			var lengthCount:int=  _cellPosCache.length;
			for(var i:int=0; i<lengthCount; i++){
				var breadthIndices:Array = _cellPosCache[i];
				var length:Number = _maxCellLengths[i];
				if(breadthIndices){
					var breadthStack:Number = _foreBreadth;
					
					var breadthCount:int = breadthIndices.length;
					for(var j:int=0; j<breadthCount; j++){
						var key:* = breadthIndices[j];
						var subMeas:Rectangle = _cellMeasCache[key];
						if(subMeas){
							var subBreadthDim:Number;
							if(equaliseBreadths){
								subBreadthDim = _maxCellBreadths[j];
							}else{
								subBreadthDim = subMeas[_breadthDimRef];
							}
							
							var subLengthDim:Number;
							if(equaliseLengths){
								subLengthDim = length;
							}else{
								subLengthDim = subMeas[_lengthDimRef];
							}
							if(_isVertical){
								positionRenderer(key,i,j,
									_displayPosition.x+lengthStack-_lengthPixScrollMetrics.value,_displayPosition.y+breadthStack-_breadthPixScrollMetrics.value,
									subLengthDim,subBreadthDim);
							}else{
								positionRenderer(key,i,j,
									_displayPosition.x+breadthStack-_breadthPixScrollMetrics.value,_displayPosition.y+lengthStack-_lengthPixScrollMetrics.value,
									subBreadthDim,subLengthDim);
							}
							breadthStack += subBreadthDim+_breadthGap;
						}
					}
				}
				lengthStack += length+_lengthGap;
			}
		}
		protected function positionRenderer(key:*, length:int, breadth:int, x:Number, y:Number, width:Number, height:Number):void{
			var renderer:ILayoutSubject = getChildRenderer(key,length,breadth);
			if(renderer)renderer.setDisplayPosition(x,y,width,height);
		}
		
		// IScrollable implementation
		public function addScrollWheelListener(direction:String):Boolean{
			return false;
		}
		public function getScrollMetrics(direction:String):ScrollMetrics{
			if(direction==Direction.HORIZONTAL){
				return _horizontalScrollMetrics;
			}else{
				return _verticalScrollMetrics;
			}
		}
		public function setScrollMetrics(direction:String,metrics:ScrollMetrics):void{
			validateProps();
			_propsFlag.validate();
			var fillMetrics:ScrollMetrics;
			if(direction==this._flowDirection){
				_breadthScrollFlag.invalidate()
				fillMetrics = _breadthScrollMetrics;
			}else{
				_lengthScrollFlag.invalidate();
				fillMetrics = _lengthScrollMetrics;
			}
			fillMetrics.value = metrics.value;
			invalidate();
		}
		public function getScrollMultiplier(direction:String):Number{
			return 1;
		}
	}
}