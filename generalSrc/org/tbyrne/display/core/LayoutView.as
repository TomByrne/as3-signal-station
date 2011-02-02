package org.tbyrne.display.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.layout.core.ILayoutInfo;
	import org.tbyrne.display.validation.FrameValidationFlag;
	import org.tbyrne.display.validation.ValidationFlag;
	
	public class LayoutView extends DrawableView implements ILayoutView
	{
		override public function set asset(value:IDisplayObject):void{
			super.asset = value;
			invalidateMeasurements();
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
		public function get position():Point{
			return _position;
		}
		public function get size():Point{
			// TODO: optimise
			return _size?_size:new Point(measurements.x,measurements.y);
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
		public function get sizeChanged():IAct{
			if(!_sizeChanged)_sizeChanged = new Act();
			return _sizeChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get positionChanged():IAct{
			if(!_positionChanged)_positionChanged = new Act();
			return _positionChanged;
		}
		
		protected var _sizeChanged:Act;
		protected var _positionChanged:Act;
		protected var _measurementsChanged:Act;
		
		private var _measureFlag:ValidationFlag;
		private var _sizeDrawFlag:FrameValidationFlag;
		private var _posDrawFlag:FrameValidationFlag;
		
		private var _lastMeasX:Number;
		private var _lastMeasY:Number;
		
		private var _measuring:Boolean;
		
		protected var _measurements:Point;
		protected var _size:Point = new Point();
		protected var _position:Point = new Point();
		//private var _scrollRect:Rectangle;
		//private var _maskDisplay:Boolean;
		private var _layoutInfo:ILayoutInfo;
		
		// mapped childView > assetName
		private var _boundChildren:Dictionary = new Dictionary();
		
		public function LayoutView(asset:IDisplayObject=null){
			_measureFlag = new ValidationFlag(doMeasure, false);
			if(!_measurements)_measurements = new Point();
			super(asset);
			
			addDrawFlag(_posDrawFlag = new FrameValidationFlag(this,commitPosition,true));
			addDrawFlag(_sizeDrawFlag = new FrameValidationFlag(this,commitSize,true));
		}
		
		override protected function unbindFromAsset():void{
			super.unbindFromAsset();
			_posDrawFlag.invalidate();
			unbindChildren();
		}
		protected function bindChildAsset(childView:LayoutView, assetName:String, assetType:Class=null, setPosAlso:Boolean=false) : void{
			if(!_boundChildren)_boundChildren = new Dictionary();
			var asset:IDisplayObject = _containerAsset.takeAssetByName(assetName,assetType);
			if(setPosAlso){
				childView.setAssetAndPosition(asset);
			}else{
				childView.asset = asset;
			}
			_boundChildren[childView] = assetName;
		}
		protected function unbindChildren():void{
			if(_boundChildren){
				for(var i:* in _boundChildren){
					var child:LayoutView = (i as LayoutView);
					var asset:IDisplayObject = child.asset;
					child.asset = null;
					_containerAsset.returnAsset(asset);
				}
				_boundChildren = null;
			}
		}
		
		public function setPosition(x:Number, y:Number):void{
			if(_positionChanged){
				var oldX:Number = _position.x;
				var oldY:Number = _position.y;
			}
			var change:Boolean = false;
			if(_position.x!=x){
				_position.x = x;
				change = true;
			}
			if(_position.y!=y){
				_position.y = y;
				change = true;
			}
			if(change){
				invalidatePos();
				if(_positionChanged)_positionChanged.perform(this,oldX,oldY);
			}
		}
		public function setSize(width:Number, height:Number):void{
			if(_sizeChanged){
				var oldWidth:Number = _size.x;
				var oldHeight:Number = _size.y;
			}
			var change:Boolean = false;
			if(_size.x!=width){
				_size.x = width;
				change = true;
			}
			if(_size.y!=height){
				_size.y = height;
				change = true;
			}
			if(change){
				invalidateSize();
				if(_sizeChanged)_sizeChanged.perform(this,oldWidth,oldHeight);
			}
		}
		protected function invalidatePos(): void{
			_posDrawFlag.invalidate();
		}
		protected function invalidateSize(): void{
			_sizeDrawFlag.invalidate();
		}
		protected function validateSize(force:Boolean): void{
			_sizeDrawFlag.validate(force);
		}
		
		public function setAssetAndPosition(asset:IDisplayObject):void{
			this.asset = asset;
			if(asset){
				//_measureFlag.validate();
				//setDisplayPosition(asset.x,asset.y,_measurements.x,_measurements.y);
				setPosition(asset.x,asset.y);
				setSize(asset.naturalWidth,asset.naturalHeight);
				asset.scaleX = 1;
				asset.scaleY = 1;
			}
		}
		final protected function doMeasure():void{
			attemptInit();
			_measuring = true;
			measure();
			_measuring = false;
		}
		protected function measure():void{
			// override me, set _measurements.x & _measurements.y.
			if(asset){
				_measurements.x = asset.naturalWidth;
				_measurements.y = asset.naturalHeight;
			}else{
				_measureFlag.invalidate();
			}
		}
		protected function commitSize():void{
			asset.setSize(_size.x,_size.y);
		}
		protected function commitPosition():void{
			asset.setPosition(_position.x,_position.y);
		}
		protected function invalidateMeasurements():void{
			_measureFlag.invalidate();
			if(!_measuring){
				if(_measurementsChanged)_measurementsChanged.perform(this,_lastMeasX,_lastMeasY);
				_lastMeasX = _measurements.x;
				_lastMeasY = _measurements.y;
			}
		}
	}
}