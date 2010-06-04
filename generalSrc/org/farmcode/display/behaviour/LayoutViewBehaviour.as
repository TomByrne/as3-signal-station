package org.farmcode.display.behaviour
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.ValidationFlag;
	import org.farmcode.display.layout.core.ILayoutInfo;
	
	public class LayoutViewBehaviour extends ViewBehaviour implements ILayoutViewBehaviour
	{
		
		/**
		 * @inheritDoc
		 */
		public function get measurementsChanged():IAct{
			if(!_measurementsChanged)_measurementsChanged = new Act();
			return _measurementsChanged;
		}
		
		protected var _measurementsChanged:Act;
		
		protected var _measureFlag:ValidationFlag;
		protected var _displayMeasurements:Rectangle;
		private var _displayPosition:Rectangle = new Rectangle();
		private var _scrollRect:Rectangle;
		private var _maskDisplay:Boolean;
		private var _layoutInfo:ILayoutInfo;
		
		public function LayoutViewBehaviour(asset:DisplayObject=null){
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
			if(change)invalidate();
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
		public function setAssetAndPosition(asset:DisplayObject):void{
			var bounds:Rectangle = getAssetBounds(asset);
			if(asset.parent){
				bounds.x += asset.x;
				bounds.y += asset.y;
			}
			this.asset = asset;
			setDisplayPosition(bounds.x,bounds.y,bounds.width,bounds.height);
		}
		protected function measure():void{
			// override me, set _displayMeasurements.
			if(asset){
				_displayMeasurements = getAssetBounds();
			}else{
				_measureFlag.invalidate();
			}
		}
		protected function getAssetBounds(asset:DisplayObject=null):Rectangle{
			var contAsset:DisplayObjectContainer;
			if(!asset){
				asset = this.asset;
				contAsset = this.containerAsset;
			}else{
				contAsset = asset as DisplayObjectContainer;
			}
			var boundsSubject:DisplayObject;
			if(contAsset){
				boundsSubject = contAsset.getChildByName("bounds");
				if(!boundsSubject){
					boundsSubject = asset;
				}
			}else{
				boundsSubject = asset;
			}
			return boundsSubject.getBounds(asset);
		}
		override protected function bindToAsset():void{
			super.bindToAsset();
			dispatchMeasurementChange();
		}
		override protected function draw():void{
			_measureFlag.validate();
			var pos:Rectangle = displayPosition;
			var meas:Rectangle = displayMeasurements;
			if(pos && meas){
				if(pos.width && meas.width){
					asset.scaleX = pos.width/meas.width;
				}else{
					asset.scaleX = 1;
				}
				if(pos.height && meas.height){
					asset.scaleY = pos.height/meas.height;
				}else{
					asset.scaleY = 1;
				}
				if(maskDisplay){
					if(!_scrollRect){
						_scrollRect = new Rectangle();
					}
					asset.x = pos.x+meas.x;
					asset.y = pos.y+meas.y;
					_scrollRect.x = meas.x;
					_scrollRect.y = meas.y;
					_scrollRect.width = pos.width;
					_scrollRect.height = pos.height;
					asset.scrollRect = _scrollRect;
				}else{
					asset.x = pos.x;
					asset.y = pos.y;
					asset.scrollRect = null;
				}
			}else{
				asset.scaleX = 1;
				asset.scaleY = 1;
				asset.x = pos.x;
				asset.y = pos.y;
				asset.scrollRect = null;
			}
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
		protected function dispatchEventIf(eventType:String, eventClass:Class):void{
			if(willTrigger(eventType)){
				dispatchEvent(new eventClass(eventType));
			}
		}
	}
}