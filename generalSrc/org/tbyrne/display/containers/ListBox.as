package org.tbyrne.display.containers
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.instanceFactory.IInstanceFactory;
	
	public class ListBox extends AbstractSelectableList
	{
		public function get direction():String{
			return _layout.flowDirection;
		}
		public function set direction(value:String):void{
			setDirection(value);
		}
		public function get fillSpareSpace():Boolean{
			return _layout.fillFlow;
		}
		public function set fillSpareSpace(value:Boolean):void{
			_layout.fillFlow = value;
		}
		
		public function get gap():Number{
			return _layout.gap;
		}
		public function set gap(value:Number):void{
			_layout.gap = value;
		}
		public function get horizontalGap():Number{
			return _layout.horizontalGap;
		}
		public function set horizontalGap(value:Number):void{
			_layout.horizontalGap = value;
		}
		public function get verticalGap():Number{
			return _layout.verticalGap;
		}
		public function set verticalGap(value:Number):void{
			_layout.verticalGap = value;
		}
		
		public function get marginTop():Number{
			return _layout.marginTop;
		}
		public function set marginTop(value:Number):void{
			_layout.marginTop = value;
		}
		public function get marginBottom():Number{
			return _layout.marginBottom;
		}
		public function set marginBottom(value:Number):void{
			_layout.marginBottom = value;
		}
		public function get marginLeft():Number{
			return _layout.marginLeft;
		}
		public function set marginLeft(value:Number):void{
			_layout.marginLeft = value;
		}
		public function get marginRight():Number{
			return _layout.marginRight;
		}
		public function set marginRight(value:Number):void{
			_layout.marginRight = value;
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
		
		public function get dataCount():int{
			return _layout.getDataCount();
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
		
		public function get maxSelected():int{
			return _maxSelected;
		}
		public function set maxSelected(value:int):void{
			if(_maxSelected!=value){
				_maxSelected = value;
				validateSelectionCount();
			}
		}
		
		public function get minSelected():int{
			return _minSelected;
		}
		public function set minSelected(value:int):void{
			if(_minSelected!=value){
				_minSelected = value;
				validateSelectionCount();
			}
		}
		
		
		public function get scrollByLine():Boolean{
			return _scrollByLine;
		}
		public function set scrollByLine(value:Boolean):void{
			if(_scrollByLine!=value){
				_scrollByLine = value;
				_layout.horizontalScrollByLine = value;
				_layout.verticalScrollByLine = value;
			}
		}
		
		public function get autoScrollToSelection():Boolean{
			return _autoScrollToSelection;
		}
		public function set autoScrollToSelection(value:Boolean):void{
			if(_autoScrollToSelection!=value){
				_autoScrollToSelection = value;
				checkAutoScroll();
			}
		}
		
		
		
		public function ListBox(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			_layout.equaliseCellWidths = true;
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			if(_scrollBar)_scrollBar.direction = direction;
		}
		override protected function updateFactory(factory:IInstanceFactory, dataField:String):void{
			super.updateFactory(factory,dataField);
			validateSelectionCount();
		}
	}
}