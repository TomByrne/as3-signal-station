package org.farmcode.display.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.validation.ValidationFlag;
	
	public class LayoutView extends View implements ILayoutView
	{
		
		/**
		 * @inheritDoc
		 */
		public function get measurementsChanged():IAct{
			if(!_measurementsChanged)_measurementsChanged = new Act();
			return _measurementsChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get positionChanged():IAct{
			if(!_positionChanged)_positionChanged = new Act();
			return _positionChanged;
		}
		
		protected var _positionChanged:Act;
		protected var _measurementsChanged:Act;
		
		protected var _measureFlag:ValidationFlag;
		protected var _displayMeasurements:Rectangle;
		private var _displayPosition:Rectangle = new Rectangle();
		private var _scrollRect:Rectangle;
		private var _maskDisplay:Boolean;
		private var _layoutInfo:ILayoutInfo;
		
		public function LayoutView(asset:IDisplayAsset=null){
			_measureFlag = new ValidationFlag(measure, false);
			_measureFlag.invalidateAct.addHandler(onMeasInvalidate);
			super(asset);
		}
		
		public function get layoutInfo():ILayoutInfo{
			return _layoutInfo;
		}
		public function set layoutInfo(value:ILayoutInfo):void{
			_layoutInfo = value;
		}
		
		public function get displayMeasurements():Rectangle{
			checkIsBound();
			_measureFlag.validate();
			return _displayMeasurements;
		}
		public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			if(_positionChanged){
				var oldX:Number = _displayPosition.x;
				var oldY:Number = _displayPosition.y;
				var oldWidth:Number = _displayPosition.width;
				var oldHeight:Number = _displayPosition.height;
			}
			var change:Boolean = false;
			if(_displayPosition.x!=x){
				_displayPosition.x = x;
				change = true;
			}
			if(_displayPosition.y!=y){
				_displayPosition.y = y;
				change = true;
			}
			if(_displayPosition.width!=width){
				_displayPosition.width = width;
				change = true;
			}
			if(_displayPosition.height!=height){
				_displayPosition.height = height;
				change = true;
			}
			if(change){
				invalidate();
				if(_positionChanged)_positionChanged.perform(this,oldX,oldY,oldWidth,oldHeight);
			}
		}
		public function get displayPosition():Rectangle{
			return _displayPosition?_displayPosition:displayMeasurements;
		}
		
		public function get maskDisplay():Boolean{
			return _maskDisplay;
		}
		public function set maskDisplay(value:Boolean):void{
			if(_maskDisplay!=value){
				_maskDisplay = value;
				invalidate();
			}
		}
		public function setAssetAndPosition(asset:IDisplayAsset):void{
			this.asset = asset;
			if(asset){
				_measureFlag.validate();
				setDisplayPosition(asset.x,asset.y,_displayMeasurements.width,_displayMeasurements.height);
			}
		}
		protected function measure():void{
			// override me, set _displayMeasurements.
			if(asset){
				if(!_displayMeasurements){
					_displayMeasurements = new Rectangle();
					_displayMeasurements.x = 0;
					_displayMeasurements.y = 0;
					_displayMeasurements.width = asset.naturalWidth;
					_displayMeasurements.height = asset.naturalHeight;
				}
			}else{
				_measureFlag.invalidate();
			}
		}
		override protected function draw():void{
			positionAsset();
			asset.width = _displayPosition.width;
			asset.height = _displayPosition.height;
		}
		protected function positionAsset():void{
			asset.x = _displayPosition.x;
			asset.y = _displayPosition.y;
		}
		protected function dispatchMeasurementChange():void{
			_measureFlag.invalidate();
		}
		protected function onMeasInvalidate(validationFlag:ValidationFlag):void{
			if(_measurementsChanged){
				if(_displayMeasurements)_measurementsChanged.perform(this, _displayMeasurements.x, _displayMeasurements.y, _displayMeasurements.width, _displayMeasurements.height);
				else _measurementsChanged.perform(this, NaN, NaN, NaN, NaN);
			}
		}
		/*protected function dispatchEventIf(eventType:String, eventClass:Class):void{
			if(willTrigger(eventType)){
				dispatchEvent(new eventClass(eventType));
			}
		}*/
	}
}