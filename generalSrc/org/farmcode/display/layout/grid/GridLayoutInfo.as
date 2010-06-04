package org.farmcode.display.layout.grid
{
	public class GridLayoutInfo implements IGridLayoutInfo
	{
		public function get columnIndex():int{
			return _columnIndex;
		}
		public function set columnIndex(value:int):void{
			_columnIndex = value;
		}
		
		public function get rowIndex():int{
			return _rowIndex;
		}
		public function set rowIndex(value:int):void{
			_rowIndex = value;
		}
		
		private var _rowIndex:int;
		private var _columnIndex:int;
		
		public function GridLayoutInfo(columnIndex:int=-1, rowIndex:int=-1){
			this.columnIndex = columnIndex;
			this.rowIndex = rowIndex;
		}
	}
}