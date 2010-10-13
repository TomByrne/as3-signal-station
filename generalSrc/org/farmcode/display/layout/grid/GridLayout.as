package org.farmcode.display.layout.grid
{
	import flash.geom.Point;
	
	import org.farmcode.display.core.IView;
	
	
	public class GridLayout extends AbstractGridLayout
	{
		public function get gap():Number{
			if(_verticalGap==_horizontalGap){
				return _verticalGap;
			}else{
				return NaN;
			}
		}
		public function set gap(value:Number):void{
			_verticalGap = _horizontalGap = value;
		}
		public function get horizontalGap():Number{
			return _horizontalGap;
		}
		public function set horizontalGap(value:Number):void{
			_horizontalGap = value;
		}
		public function get verticalGap():Number{
			return _verticalGap;
		}
		public function set verticalGap(value:Number):void{
			_verticalGap = value;
		}
		public function get flowDirection():String{
			return _flowDirection;
		}
		public function set flowDirection(value:String):void{
			_flowDirection = value;
		}
		public function get columns():Number{
			return _maxColumns;
		}
		public function set columns(value:Number):void{
			_maxColumns = value;
		}
		public function get rows():Number{
			return _maxRows;
		}
		public function set rows(value:Number):void{
			_maxRows = value;
		}
		
		
		public function GridLayout(scopeView:IView){
			super(scopeView);
		}
		public function getStandardGridDimensions(rendererWidth:Number, rendererHeight:Number):Point{
			var availWidth:Number = (_size.x+horizontalGap-marginLeft-marginRight);
			var availHeight:Number = (_size.y+verticalGap-marginTop-marginBottom);
			var columns:int = Math.floor(availWidth/(rendererWidth+horizontalGap));
			if(columns<0)columns = 0;
			var rows:int = Math.floor(availHeight/(rendererHeight+verticalGap));
			if(rows<0)rows = 0;
			return new Point(columns, rows);
		}
	}
}