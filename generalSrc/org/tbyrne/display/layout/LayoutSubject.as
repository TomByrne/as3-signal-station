package org.tbyrne.display.layout
{
	import flash.geom.Point;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.binding.Watchable;
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.layout.core.ILayoutInfo;
	import org.tbyrne.display.validation.ViewValidationFlag;
	import org.tbyrne.display.validation.ValidationFlag;
	
	public class LayoutSubject extends Watchable implements ILayoutSubject
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
		
		public function get measurements():Point{
			_measureFlag.validate();
			return _measurements;
		}
		public function get position():Point{
			return _position;
		}
		public function get size():Point{
			return _size;
		}
		
		
		public function get layoutInfo():ILayoutInfo{
			return _layoutInfo;
		}
		public function set layoutInfo(value:ILayoutInfo):void{
			_layoutInfo = value;
		}
		
		
		
		
		
		protected var _sizeChanged:Act;
		protected var _positionChanged:Act;
		protected var _measurementsChanged:Act;
		
		private var _measureFlag:ValidationFlag;
		private var _sizeDrawFlag:ViewValidationFlag;
		private var _posDrawFlag:ViewValidationFlag;
		private var _drawFlag:ViewValidationFlag;
		
		protected var _scopeView:IView;
		
		protected var _layoutInfo:ILayoutInfo;
		protected var _size:Point = new Point();
		protected var _position:Point = new Point();
		protected var _measurements:Point;
		
		private var _lastMeasX:Number;
		private var _lastMeasY:Number;
		
		protected var _childDrawFlags:Vector.<ViewValidationFlag>;
		
		public function LayoutSubject(watchableProperties:Array=null){
			super(watchableProperties);
			_drawFlag = new ViewValidationFlag(null,validateAll,false);
			
			_measureFlag = new ValidationFlag(measure, false);
			_measurements = new Point();
			
			addDrawFlag(_posDrawFlag = new ViewValidationFlag(null,commitPos,true));
			addDrawFlag(_sizeDrawFlag = new ViewValidationFlag(null,commitSize,true));
		}
		protected function addDrawFlag(frameValidationFlag:ViewValidationFlag):void{
			if(!_childDrawFlags)_childDrawFlags = new Vector.<ViewValidationFlag>();
			_childDrawFlags.push(frameValidationFlag);
		}
		protected function setScopeView(value:IView):void{
			if(_scopeView!=value){
				_scopeView = value;
				_drawFlag.view = _scopeView;
				for each(var frameValidationFlag:ViewValidationFlag in _childDrawFlags){
					frameValidationFlag.view = value;
				}
			}
		}
		
		
		public function validate(forceDraw: Boolean = false): void{
			_drawFlag.validate(forceDraw);
		}
		protected function invalidateMeasurements(): void{
			_measureFlag.invalidate();
			if(_measurementsChanged)_measurementsChanged.perform(this,_lastMeasX,_lastMeasY);
			_lastMeasX = _measurements.x;
			_lastMeasY = _measurements.y;
		}
		protected function invalidatePos(): void{
			_posDrawFlag.invalidate();
		}
		protected function invalidateSize(): void{
			_sizeDrawFlag.invalidate();
		}
		protected function invalidateAll(): void{
			_drawFlag.invalidate();
		}
		protected final function validateAll():void{
			for each(var frameValidationFlag:ViewValidationFlag in _childDrawFlags){
				frameValidationFlag.validate(true);
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
		
		protected function measure() : void{
			// override me
		}
		protected function validatePos(force:Boolean=false):void{
			_posDrawFlag.validate(force);
		}
		protected function commitPos():void{
			// override me
		}
		protected function validateSize(force:Boolean=false):void{
			_sizeDrawFlag.validate(force);
		}
		protected function commitSize():void{
			// override me
		}
	}
}