package org.farmcode.display.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.validation.ValidationFlag;
	
	public class LayoutView extends DrawableView implements ILayoutView
	{
		override public function set asset(value:IDisplayAsset):void{
			super.asset = value;
			performMeasChanged();
		}
		public function get layoutInfo():ILayoutInfo{
			return _layoutInfo;
		}
		public function set layoutInfo(value:ILayoutInfo):void{
			_layoutInfo = value;
		}
		
		public function get measurements():Point{
			checkIsBound();
			_measureFlag.validate();
			return _measurements;
		}
		
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
		protected var _measurements:Point;
		private var _displayPosition:Rectangle = new Rectangle();
		private var _scrollRect:Rectangle;
		private var _maskDisplay:Boolean;
		private var _layoutInfo:ILayoutInfo;
		
		public function LayoutView(asset:IDisplayAsset=null){
			_measureFlag = new ValidationFlag(doMeasure, false);
			if(!_measurements)_measurements = new Point();
			super(asset);
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
			// TODO: optimise
			return _displayPosition?_displayPosition:new Rectangle(0,0,measurements.x,measurements.y);
		}
		
		public function setAssetAndPosition(asset:IDisplayAsset):void{
			this.asset = asset;
			if(asset){
				//_measureFlag.validate();
				//setDisplayPosition(asset.x,asset.y,_measurements.x,_measurements.y);
				setDisplayPosition(asset.x,asset.y,asset.naturalWidth,asset.naturalHeight);
			}
		}
		final protected function doMeasure():void{
			attemptInit();
			measure();
		}
		protected function measure():void{
			// override me, set _displayMeasurements.
			if(asset){
				_measurements.x = asset.naturalWidth;
				_measurements.y = asset.naturalHeight;
			}else{
				_measureFlag.invalidate();
			}
		}
		override protected function draw():void{
			positionAsset();
			asset.setSize(_displayPosition.width,_displayPosition.height);
		}
		protected function positionAsset():void{
			asset.setPosition(_displayPosition.x,_displayPosition.y);
		}
		protected function performMeasChanged():void{
			_measureFlag.invalidate();
			if(_measurementsChanged)_measurementsChanged.perform(this, _measurements.x, _measurements.y);
		}
	}
}