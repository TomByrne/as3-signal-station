package org.farmcode.display.containers
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.grid.RendererGridLayout;
	import org.farmcode.display.layout.list.ListLayoutInfo;
	
	
	// TODO: assess the value of this class, should it inherit from AbstractSelectableList?
	public class ToggleButtonList extends AbstractList
	{
		private static const TOGGLE_BUTTON:String = "toggleButton";
		
		
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
		
		public function get marginRight():Number{
			return _layout.marginRight;
		}
		public function set marginRight(value:Number):void{
			_layout.marginRight = value;
		}
		
		public function get marginBottom():Number{
			return _layout.marginBottom;
		}
		public function set marginBottom(value:Number):void{
			_layout.marginBottom = value;
		}
		
		public function get horizontalGap():Number{
			return _layout.horizontalGap;
		}
		public function set horizontalGap(value:Number):void{
			_layout.horizontalGap = value;
		}
		public function get gap():Number{
			return _layout.verticalGap;
		}
		public function set gap(value:Number):void{
			_layout.verticalGap = value;
			_layout.horizontalGap = value;
		}
		
		public function get dataProvider():*{
			return _layout.dataProvider;
		}
		public function set dataProvider(value:*):void{
			if(_layout.dataProvider != value){
				var newIndex:int = 0;
				_layout.dataProvider = value;
				_selectedItem = null;
				for(var i:int=0; i<_layout.getDataCount(); i++){
					var selectableData:IBooleanProvider = (_layout.getDataAt(i) as IBooleanProvider);
					if(selectableData && selectableData.booleanValue){
						newIndex = i;
						break;
					}
				}
				setSelectedIndex(newIndex, true);
			}
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
		
		
		public function get direction():String{
			return _layout.flowDirection;
		}
		public function set direction(value:String):void{
			if(_layout.flowDirection!=value){
				_layout.flowDirection = value;
				invalidateMeasurements();
				invalidateSize();
			}
		}
		public function get selectedIndex():int{
			return _selectedIndex;
		}
		public function set selectedIndex(value:int):void{
			setSelectedIndex(value, false);
		}
		public function get selectedItem():*{
			return _selectedItem;
		}
		
		/**
		 * handler(from:ToggleButtonList)
		 */
		public function get selectedIndexChanged():IAct{
			if(!_selectedIndexChanged)_selectedIndexChanged = new Act();
			return _selectedIndexChanged;
		}
		
		protected var _selectedIndexChanged:Act;
		protected var _selectedIndex:int;
		protected var _ignoreRenderers:Boolean;
		protected var _selectedItem:*;
		
		public function ToggleButtonList(asset:IDisplayAsset=null){
			super(asset);
		}
		// TODO:bring selected renderer to top depth (and arrange others)
		protected function setSelectedIndex(index:int, forceRefresh:Boolean):void{
			var change:Boolean = (_selectedIndex!=index);
			if(change || forceRefresh){
				if(change){
					_selectedIndex = index;
					if(_selectedIndexChanged)_selectedIndexChanged.perform(this);
				}
				_ignoreRenderers = true;
				for(var i:int=0; i<_layout.getDataCount(); i++){
					var data:* = _layout.getDataAt(i);
					var selectableData:IBooleanConsumer = (data as IBooleanConsumer);
					var selected:Boolean = (i==_selectedIndex);
					if(selectableData){
						selectableData.booleanValue = selected;
					}
					if(selected){
						_selectedItem = data;
					}
				}
				_ignoreRenderers = false;
			}
		}
		override protected function onAddRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			super.onAddRenderer(layout, renderer);
			var selRenderer:ISelectableRenderer = (renderer as ISelectableRenderer);
			if(selRenderer){
				selRenderer.selectedChanged.addHandler(onRendererSelect);
			}
		}
		override protected function onRemoveRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			super.onRemoveRenderer(layout, renderer);
			var selRenderer:ISelectableRenderer = (renderer as ISelectableRenderer);
			if(selRenderer){
				selRenderer.selectedChanged.removeHandler(onRendererSelect);
			}
		}
		override protected function assumedRendererAssetName() : String{
			return TOGGLE_BUTTON;
		}
		protected function onRendererSelect(renderer:ISelectableRenderer) : void{
			if(!_ignoreRenderers){
				var dataIndex:int = getDataIndex(renderer[_layout.dataField]);
				setSelectedIndex(dataIndex,false);
			}
		}
		protected function getDataIndex(data:*) : int{
			var layoutInfo:ListLayoutInfo = _layout.getDataLayout(data) as ListLayoutInfo;
			return layoutInfo.listIndex;
		}
	}
}