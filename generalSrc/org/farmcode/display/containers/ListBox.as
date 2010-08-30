package org.farmcode.display.containers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.layout.grid.RendererGridLayout;
	import org.farmcode.display.layout.list.ListLayoutInfo;
	import org.farmcode.display.scrolling.ScrollMetrics;
	import org.farmcode.instanceFactory.IInstanceFactory;
	
	public class ListBox extends AbstractSelectableList
	{
		public function get direction():String{
			return _layout.flowDirection;
		}
		public function set direction(value:String):void{
			_layout.flowDirection = value;
			if(_scrollBar)_scrollBar.direction = value;
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
		
		
		
		public function ListBox(asset:IDisplayAsset=null){
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