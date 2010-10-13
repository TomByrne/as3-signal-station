package org.tbyrne.display.layout.list
{
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.layout.grid.AbstractGridLayout;
	
	public class ListLayout extends AbstractGridLayout
	{
		public function ListLayout(scopeView:IView=null){
			super(scopeView);
		}
		public function get gap():Number{
			return _verticalGap;
		}
		public function set gap(value:Number):void{
			_verticalGap = _horizontalGap = value;
		}
		
		public function get equaliseCellWidths():Boolean{
			return _equaliseCellWidths;
		}
		public function set equaliseCellWidths(value:Boolean):void{
			_equaliseCellWidths = value;
		}
		public function get rowHeights():Array{
			return _rowHeights;
		}
		public function set rowHeights(value:Array):void{
			_rowHeights = value;
		}
		
		public function get equaliseCellHeights():Boolean{
			return _equaliseCellHeights;
		}
		public function set equaliseCellHeights(value:Boolean):void{
			_equaliseCellHeights = value;
		}
		public function get columnWidths():Array{
			return _columnWidths;
		}
		public function set columnWidths(value:Array):void{
			_columnWidths = value;
		}
		
		public function get direction():String{
			return _flowDirection;
		}
		public function set direction(value:String):void{
			_flowDirection = value;
		}
	}
}