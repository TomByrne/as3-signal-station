package org.farmcode.display.containers.grid
{
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.containers.AbstractList;
	import org.farmcode.instanceFactory.IInstanceFactory;

	public class GridView extends AbstractList
	{
		public function get dataProvider():*{
			return _dataProvider;
		}
		public function set dataProvider(value:*):void{
			if(_dataProvider!=value){
				attemptInit();
				_dataProvider = value;
				_layout.dataProvider = value;
			}
		}
		
		public function get marginTop():Number{
			return _layout.marginTop;
		}
		public function set marginTop(value:Number):void{
			_layout.marginTop = value;
		}
		public function get marginLeft():Number{
			return _layout.marginLeft;
		}
		public function set marginLeft(value:Number):void{
			_layout.marginLeft = value;
		}
		public function get marginBottom():Number{
			return _layout.marginBottom;
		}
		public function set marginBottom(value:Number):void{
			_layout.marginBottom = value;
		}
		public function get marginRight():Number{
			return _layout.marginRight;
		}
		public function set marginRight(value:Number):void{
			_layout.marginRight = value;
		}
		public function get gap():Number{
			var ret:Number = _layout.verticalGap;
			return _layout.horizontalGap==ret?ret:NaN;
		}
		public function set gap(value:Number):void{
			_layout.horizontalGap = value;
			_layout.verticalGap = value;
		}
		public function get gridFlowDirection():String{
			return _layout.flowDirection;
		}
		public function set gridFlowDirection(value:String):void{
			_layout.flowDirection = value;
		}
		public function get columnWidths():Array{
			return _layout.columnWidths;
		}
		public function set columnWidths(value:Array):void{
			_layout.columnWidths = value;
		}
		public function get rowHeights():Array{
			return _layout.rowHeights;
		}
		public function set rowHeights(value:Array):void{
			_layout.rowHeights = value;
		}
		public function get dataField():String{
			return _dataField;
		}
		public function set dataField(value:String):void{
			if(_dataField != value){
				_dataField = value;
				assessFactory();
			}
		}
		
		private var _dataProvider:*;
		
		
		public function GridView(){
			
		}
		override protected function createLayout():void{
			super.createLayout();
			_layout.equaliseCellHeights = true;
			_layout.equaliseCellWidths = true;
			_layout.flowDirection = Direction.HORIZONTAL;
		}
		override protected function setLayoutDimensions(width:Number, height:Number):void{
			_layout.setSize(width,height);
		}
		
		override protected function assumedRendererAssetName() : String{
			return AssetNames.CELL_RENDERER;
		}
	}
}