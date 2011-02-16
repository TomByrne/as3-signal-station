package org.tbyrne.display.containers
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.constants.Anchor;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.core.LayoutView;
	import org.tbyrne.display.layout.ILayoutSubject;
	
	
	public class TabPanel extends ToggleButtonList
	{
		private static const ASSUMED_DATA_FIELD:String = "data";
		
		private static const PANEL:String = "panel";
		private static const TAB:String = "tab";
		
		public function get panelDataField():String{
			return _panelDataField;
		}
		public function set panelDataField(value:String):void{
			if(_panelDataField!=value){
				_panelDataField = value;
				checkPanelData();
			}
		}
		
		public function get panelDisplay():ILayoutView{
			return _panelDisplay;
		}
		public function set panelDisplay(value:ILayoutView):void{
			if(_panelDisplay!=value){
				if(_panelDisplay){
					_panelDisplay.assetChanged.removeHandler(onPanelAssetChanged);
					_panelDisplay.measurementsChanged.removeHandler(onPanelMeasChanged);
				}
				_panelDisplay = value;
				_castDisplay = (value as LayoutView);
				if(_panelDisplay){
					checkAssumedPanelAsset();
					setPanelAsset(_panelDisplay.asset);
					_panelDisplay.assetChanged.addHandler(onPanelAssetChanged);
					_panelDisplay.measurementsChanged.addHandler(onPanelMeasChanged);
				}else{
					setPanelAsset(null);
				}
				checkPanelData();
			}
		}
		
		public function get anchor():String{
			return _anchor;
		}
		public function set anchor(value:String):void{
			if(_anchor!=value){
				_anchor = value;
				invalidateMeasurements();
				invalidateSize();
			}
		}
		
		private var _panelDisplay:ILayoutView;
		private var _castDisplay:LayoutView;
		private var _panelAsset:IDisplayObject;
		private var _assumedPanelAsset:IDisplayObject;
		private var _panelDataField:String;
		private var _listMeasure:Point;
		private var _anchor:String = Anchor.TOP_LEFT;
		private var _alignHorizontal:Boolean;
		
		public function TabPanel(asset:IDisplayObject=null){
			super(asset);
			_listMeasure = new Point();
			direction = Direction.HORIZONTAL;
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_assumedPanelAsset = _containerAsset.takeAssetByName(PANEL,true);
			checkAssumedPanelAsset();
			if(_panelDisplay && _panelAsset){
				_containerAsset.addAsset(_panelAsset);
				_containerAsset.setAssetIndex(_container,_containerAsset.numChildren-1);
			}
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			removeAssumedPanelAsset();
			if(_panelDisplay && _panelAsset){
				_containerAsset.removeAsset(_panelAsset);
			}
		}
		override protected function onLayoutMeasChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number) : void{
			super.onLayoutMeasChange(from, oldWidth, oldHeight);
			invalidateSize();
		}
		override protected function measure() : void{
			super.measure();
			_listMeasure.x = _measurements.x;
			_listMeasure.y = _measurements.y;
			
			if(_layout.flowDirection==Direction.VERTICAL){
				switch(anchor){
					case Anchor.TOP:
					case Anchor.BOTTOM:
						_alignHorizontal = false;
						break;
					default:
						_alignHorizontal = true;
				}
			}else{
				switch(anchor){
					case Anchor.LEFT:
					case Anchor.RIGHT:
						_alignHorizontal = true;
						break;
					default:
						_alignHorizontal = false;
				}
			}
			var panelMeas:Point = _panelDisplay.measurements;
			if(panelMeas){
				if(_alignHorizontal){
					_measurements.y += panelMeas.y;
					if(_measurements.x<panelMeas.x){
						_measurements.x = panelMeas.x;
					}
				}else{
					_measurements.x += panelMeas.x;
					if(_measurements.y<panelMeas.y){
						_measurements.y = panelMeas.y;
					}
				}
			}
		}
		override protected function commitSize():void{
			measurements; // this will force measurements to be valid
			sizeBacking(size.x,size.y);
			
			var listX:Number;
			var listY:Number;
			var listWidth:Number = (size.x<_listMeasure.x?size.x:_listMeasure.x);
			var listHeight:Number = (size.y<_listMeasure.y?size.y:_listMeasure.y);
			
			var panelX:Number;
			var panelY:Number;
			var panelWidth:Number;
			var panelHeight:Number;
			if(_alignHorizontal){
				panelY = 0;
				panelWidth = size.x-listWidth;
				panelHeight = size.y;
				switch(anchor){
					case Anchor.TOP_LEFT:
					case Anchor.LEFT:
					case Anchor.BOTTOM_LEFT:
						listX = 0;
						panelX = listWidth;
						break;
					case Anchor.TOP_RIGHT:
					case Anchor.RIGHT:
					case Anchor.BOTTOM_RIGHT:
						panelX = 0;
						listX = panelWidth;
						break;
				}
				switch(anchor){
					case Anchor.TOP_LEFT:
					case Anchor.TOP_RIGHT:
						listY = 0;
						break;
					case Anchor.BOTTOM_LEFT:
					case Anchor.BOTTOM_RIGHT:
						listY = size.y-listHeight;
						break;
					default:
						listY = (size.y-listHeight)/2;
				}
			}else{
				panelX = 0;
				panelHeight = size.y-listHeight;
				panelWidth = size.x;
				switch(anchor){
					case Anchor.TOP_LEFT:
					case Anchor.TOP:
					case Anchor.TOP_RIGHT:
						listY = 0;
						panelY = listHeight;
						break;
					case Anchor.BOTTOM_LEFT:
					case Anchor.BOTTOM:
					case Anchor.BOTTOM_RIGHT:
						panelY = 0;
						listY = panelHeight;
						break;
				}
				switch(anchor){
					case Anchor.TOP_LEFT:
					case Anchor.BOTTOM_LEFT:
						listX = 0;
						break;
					case Anchor.TOP_RIGHT:
					case Anchor.BOTTOM_RIGHT:
						listX = size.x-listWidth;
						break;
					default:
						listX = (size.x-listWidth)/2;
				}
			}
			_panelDisplay.setPosition(panelX,panelY);
			_panelDisplay.setSize(panelWidth,panelHeight);
			_container.setPosition(listX,listY);
			drawListAndScrollbar(listWidth,listHeight);
		}
		override protected function setSelectedIndex(index:int, forceRefresh:Boolean):void{
			super.setSelectedIndex(index, forceRefresh);
			checkPanelData();
		}
		protected function checkPanelData():void{
			if(_panelDisplay){
				var dataField:String = _panelDataField?_panelDataField:ASSUMED_DATA_FIELD;
				_panelDisplay[dataField] = selectedItem;
			}
		}
		protected function onPanelMeasChanged(from:ILayoutView, oldWidth:Number, oldHeight:Number):void{
			invalidateMeasurements();
		}
		protected function onPanelAssetChanged(from:ILayoutView, oldAsset:IAsset):void{
			setPanelAsset(from.asset);
		}
		protected function removeAssumedPanelAsset():void{
			if(_castDisplay && _castDisplay.asset==_assumedPanelAsset && _assumedPanelAsset){
				_castDisplay.asset = null;
			}
		}
		protected function checkAssumedPanelAsset():void{
			if(_castDisplay && _assumedPanelAsset && !_castDisplay.asset){
				_castDisplay.asset = _assumedPanelAsset;
			}
		}
		protected function setPanelAsset(value:IDisplayObject):void{
			if(_panelAsset!=value){
				if(_panelAsset && _containerAsset){
					_containerAsset.removeAsset(_panelAsset);
				}
				_panelAsset = value;
				if(_panelDisplay && _containerAsset){
					_containerAsset.addAsset(_panelAsset);
					_containerAsset.setAssetIndex(_container,_containerAsset.numChildren-1);
				}
				invalidateMeasurements();
			}
		}
		override protected function assumedRendererAssetName() : String{
			return TAB;
		}
	}
}