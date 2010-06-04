package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.collections.MultiArray;
	
	import flash.display.DisplayObject;
	
	public class GridView extends Container
	{
		public function get horizontalGap():Number{
			return _horizontalGap;
		}
		public function set horizontalGap(value:Number):void{
			if(_horizontalGap!=value){
				_horizontalGap = value;
				invalidate();
			}
		}
		public function get verticalGap():Number{
			return _verticalGap;
		}
		public function set verticalGap(value:Number):void{
			if(_verticalGap!=value){
				_verticalGap = value;
				invalidate();
			}
		}
		public function get columns():Number{
			return (isNaN(_columns)?_children.getLength(0):_columns);;
		}
		public function set columns(value:Number):void{
			if(_columns!=value){
				_columns = value;
				invalidate();
			}
		}
		public function get rows():Number{
			return (isNaN(_rows)?_children.getLength(1):_rows);;
		}
		public function set rows(value:Number):void{
			if(_rows!=value){
				_rows = value;
				invalidate();
			}
		}
		public function get rowHeights():Array{
			return _rowHeights;
		}
		public function set rowHeights(value:Array):void{
			if(_rowHeights!=value){
				_rowHeights = value;
				invalidate();
			}
		}
		public function get columnWidths():Array{
			return _columnWidths;
		}
		public function set columnWidths(value:Array):void{
			if(_columnWidths!=value){
				_columnWidths = value;
				invalidate();
			}
		}
		public function get imposeCellSize():Boolean{
			return _imposeCellSize;
		}
		public function set imposeCellSize(value:Boolean):void{
			if(_imposeCellSize!=value){
				_imposeCellSize = value;
				invalidate();
			}
		}
		
		private var _children:MultiArray;
		private var _horizontalGap:Number = 2;
		private var _verticalGap:Number = 2;
		private var _columns:Number;
		private var _rows:Number;
		private var _rowHeights:Array;
		private var _columnWidths:Array;
		private var _imposeCellSize:Boolean = false;
		
		public function GridView(){
			super();
		}
		override protected function removeCompiledClips():void{
			_children = new MultiArray(2);
			super.removeCompiledClips();
			_columns = container.numChildren;
			var length:int = container.numChildren;
			for(var i:int=0; i<length; ++i){
				addGridChild(container.getChildAt(i));
			}
		}
		public function getGridChildAt(column:Number, row:Number):DisplayObject{
			return _children.get([column,row])
		}
		public function addGridChild(child:DisplayObject, column:Number=NaN, row:Number=NaN):DisplayObject{
			if(!_children.indicesOf(child)){
				if(isNaN(row) && isNaN(column)){
					for(row=0; (row<_rows || isNaN(_rows)); row++){
						column = findEmptyColumn(row);
						if(!isNaN(column))break;
					}
				}else if(isNaN(row)){
					row = findEmptyRow(column);
				}else if(isNaN(column)){
					column = findEmptyColumn(row);
				}
				if(!isNaN(column) && !isNaN(row)){
					removeGridChildAt(column,row);
					_children.set([column,row],child);
					if(child && child.parent!=container){
						container.addChild(child);
					}
				}
				invalidateMeasurements();
				invalidate();
			}
			return child;
		}
		protected function findEmptyRow(column:int):Number{
			for(var i:int=0; i<_rows; ++i){
				if(!_children.get([column,i]))return i;
			}
			return NaN;
		}
		protected function findEmptyColumn(row:int):Number{
			for(var i:int=0; i<_columns; ++i){
				if(!_children.get([i,row]))return i;
			}
			return NaN;
		}
		public function removeGridChild(child:DisplayObject):void{
			var indices:Array = _children.indicesOf(child);
			if(indices){
				_children.set(indices,null);
				container.removeChild(child);
				invalidateMeasurements();
				invalidate();
			}
		}
		public function removeGridChildAt(column:int, row:int):void{
			var child:DisplayObject = _children.get([column,row]);
			if(child){
				_children.set([column,row],null);
				container.removeChild(child);
				invalidateMeasurements();
				invalidate();
			}
		}
		public function removeAllGridChildren():void{
			_children = new MultiArray(2);
			while(container.numChildren){
				container.removeChildAt(0);
			}
			invalidateMeasurements();
			invalidate();
		}
		public function executeChildren(func:Function, additionalParams:Array=null):MultiArray{
			var retArr:MultiArray = new MultiArray(2);
			var frozenChildren:MultiArray = _children.clone();
			for(var i:int=0; i<columns; ++i){
				for(var j:int=0; j<rows; ++j){
					var child:DisplayObject = frozenChildren.get([i,j]);
					if(child){
						var params:Array = [child];
						if(additionalParams)params.concat(additionalParams);
						var ret:* = func.apply(null,params);
						if(ret!=null){
							retArr.set([i,j],ret);
						}
					}
				}
			}
			return retArr;
		}
		override protected function measure():void{
			super.measure();
			validate();
		}
		override protected function draw():void{
			super.draw();
			var measuredDims:Object = measureCellDimensions();
			var hStack:Array = [0];
			for(var i:int=0; (_columnWidths && i<_columnWidths.length) || i<measuredDims.columnWidths.length; ++i){
				var width:Number = _columnWidths && _columnWidths.length?_columnWidths[i%_columnWidths.length]:NaN;
				if(!isNaN(width))measuredDims.columnWidths[i] = width;
				hStack.push(hStack[i]+measuredDims.columnWidths[i]+_horizontalGap);
			}
			var vStack:Array = [0];
			for(i=0; (_rowHeights && i<_rowHeights.length) || i<measuredDims.rowHeights.length; ++i){
				var height:Number = _rowHeights && _rowHeights.length?_rowHeights[i%_rowHeights.length]:NaN;
				if(!isNaN(height))measuredDims.rowHeights[i] = height;
				vStack.push(vStack[i]+measuredDims.rowHeights[i]+_verticalGap);
			}
			var columns:Number = (isNaN(_columns)?_children.getLength(0):_columns);
			var rows:Number = (isNaN(_rows)?_children.getLength(1):_rows);
			var child:DisplayObject;
			for(i=0; i<columns; ++i){
				for(var j:int=0; j<rows; ++j){
					child = _children.get([i,j]);
					if(child){
						child.x = hStack[i];
						child.y = vStack[j];
						if(_imposeCellSize){
							child.width = measuredDims.columnWidths[i];
							child.height = measuredDims.rowHeights[j];
						}
					}
				}
			}
			_measuredWidth = leftPadding+hStack[hStack.length-1]+rightPadding;
			_measuredHeight = topPadding+vStack[vStack.length-1]+bottomPadding;
		}
		protected function measureCellDimensions():Object{
			var columns:Number = (isNaN(_columns)?_children.getLength(0):_columns);
			var rows:Number = (isNaN(_rows)?_children.getLength(1):_rows);
			var ret:Object = {};
			ret.columnWidths = [];
			ret.rowHeights = [];
			for(var i:int=0; i<columns; ++i){
				for(var j:int=0; j<rows; ++j){
					var child:DisplayObject = _children.get([i,j]);
					if(child){
						if(isNaN(ret.columnWidths[i]))ret.columnWidths[i] = child.width;
						else ret.columnWidths[i] = Math.max(ret.columnWidths[i],child.width);
						
						if(isNaN(ret.rowHeights[j])) ret.rowHeights[j] = child.height;
						else ret.rowHeights[j] = Math.max(ret.rowHeights[j],child.height);
					}
				}
			}
			return ret;
		}
	}
}