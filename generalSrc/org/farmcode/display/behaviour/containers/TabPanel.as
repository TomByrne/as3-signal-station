package org.farmcode.display.behaviour.containers
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Direction;
	
	
	public class TabPanel extends TabBar
	{
		private static const ASSUMED_DATA_FIELD:String = "data";
		
		public function get panelDataField():String{
			return _panelDataField;
		}
		public function set panelDataField(value:String):void{
			if(_panelDataField!=value){
				_panelDataField = value;
				checkPanelData();
			}
		}
		
		public function get panelDisplay():ILayoutViewBehaviour{
			return _panelDisplay;
		}
		public function set panelDisplay(value:ILayoutViewBehaviour):void{
			if(_panelDisplay!=value){
				if(_panelDisplay){
					if(containerAsset)containerAsset.removeChild(_panelDisplay.asset);
					_panelDisplay.measurementsChanged.removeHandler(onPanelMeasChanged);
				}
				_panelDisplay = value;
				if(_panelDisplay){
					if(containerAsset)containerAsset.addChild(_panelDisplay.asset);
					_panelDisplay.measurementsChanged.addHandler(onPanelMeasChanged);
				}
				checkPanelData();
			}
		}
		public function get direction():String{
			return _layout.flowDirection;
		}
		public function set direction(value:String):void{
			if(_layout.flowDirection!=value){
				_layout.flowDirection = value;
				dispatchMeasurementChange();
				invalidate();
			}
		}
		
		public function get anchor():String{
			return _anchor;
		}
		public function set anchor(value:String):void{
			if(_anchor!=value){
				_anchor = value;
				dispatchMeasurementChange();
				invalidate();
			}
		}
		
		private var _panelDisplay:ILayoutViewBehaviour;
		private var _panelDataField:String;
		private var _listMeasure:Rectangle;
		private var _listPosition:Rectangle;
		private var _anchor:String = Anchor.TOP_LEFT;
		private var _alignHorizontal:Boolean;
		
		public function TabPanel(asset:DisplayObject=null){
			super(asset);
			_listMeasure = new Rectangle();
			_listPosition = new Rectangle();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			if(_panelDisplay){
				containerAsset.addChild(_panelDisplay.asset);
				containerAsset.setChildIndex(_container,containerAsset.numChildren-1);
			}
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			if(_panelDisplay){
				containerAsset.removeChild(_panelDisplay.asset);
			}
		}
		override protected function measure() : void{
			super.measure();
			_listMeasure.x = _displayMeasurements.x;
			_listMeasure.y = _displayMeasurements.y;
			_listMeasure.width = _displayMeasurements.width;
			_listMeasure.height = _displayMeasurements.height;
			
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
			var panelMeas:Rectangle = _panelDisplay.displayMeasurements;
			if(panelMeas){
				if(_alignHorizontal){
					_displayMeasurements.height += panelMeas.height;
					if(_displayMeasurements.width<panelMeas.width){
						_displayMeasurements.width = panelMeas.width;
					}
				}else{
					_displayMeasurements.width += panelMeas.width;
					if(_displayMeasurements.height<panelMeas.height){
						_displayMeasurements.height = panelMeas.height;
					}
				}
			}
		}
		override protected function draw() : void{
			_measureFlag.validate();
			positionAsset();
			positionBacking();
			_listPosition.width = (displayPosition.width<_listMeasure.width?displayPosition.width:_listMeasure.width);
			_listPosition.height = (displayPosition.height<_listMeasure.height?displayPosition.height:_listMeasure.height);
			var panelX:Number;
			var panelY:Number;
			var panelWidth:Number;
			var panelHeight:Number;
			if(_alignHorizontal){
				panelY = 0;
				panelWidth = displayPosition.width-_listPosition.width;
				panelHeight = displayPosition.height;
				switch(anchor){
					case Anchor.TOP_LEFT:
					case Anchor.LEFT:
					case Anchor.BOTTOM_LEFT:
						_listPosition.x = 0;
						panelX = _listPosition.width;
						break;
					case Anchor.TOP_RIGHT:
					case Anchor.RIGHT:
					case Anchor.BOTTOM_RIGHT:
						panelX = 0;
						_listPosition.x = panelWidth;
						break;
				}
				switch(anchor){
					case Anchor.TOP_LEFT:
					case Anchor.TOP_RIGHT:
						_listPosition.y = 0;
						break;
					case Anchor.BOTTOM_LEFT:
					case Anchor.BOTTOM_RIGHT:
						_listPosition.y = displayPosition.height-_listPosition.height;
						break;
					default:
						_listPosition.y = (displayPosition.height-_listPosition.height)/2;
				}
			}else{
				panelX = 0;
				panelHeight = displayPosition.height-_listPosition.height;
				panelWidth = displayPosition.width;
				switch(anchor){
					case Anchor.TOP_LEFT:
					case Anchor.TOP:
					case Anchor.TOP_RIGHT:
						_listPosition.y = 0;
						panelY = _listPosition.height;
						break;
					case Anchor.BOTTOM_LEFT:
					case Anchor.BOTTOM:
					case Anchor.BOTTOM_RIGHT:
						panelY = 0;
						_listPosition.y = panelHeight;
						break;
				}
				switch(anchor){
					case Anchor.TOP_LEFT:
					case Anchor.BOTTOM_LEFT:
						_listPosition.x = 0;
						break;
					case Anchor.TOP_RIGHT:
					case Anchor.BOTTOM_RIGHT:
						_listPosition.x = displayPosition.width-_listPosition.width;
						break;
					default:
						_listPosition.x = (displayPosition.width-_listPosition.width)/2;
				}
			}
			_panelDisplay.setDisplayPosition(panelX,panelY,panelWidth,panelHeight);
			drawListAndScrollbar(_listPosition);
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
		protected function onPanelMeasChanged(from:ILayoutViewBehaviour, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
	}
}