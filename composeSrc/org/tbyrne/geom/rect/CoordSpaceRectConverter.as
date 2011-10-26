package org.tbyrne.geom.rect
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.validation.ValidationFlag;

	public class CoordSpaceRectConverter implements IRectangleProvider
	{
		
		/**
		 * @inheritDoc
		 */
		public function get rectangleChanged():IAct{
			return (_rectangleChanged || (_rectangleChanged = new Act()));
		}
		
		protected var _rectangleChanged:Act;
		
		
		/**
		 * @inheritDoc
		 */
		public function get xChanged():IAct{
			return (_xChanged || (_xChanged = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get yChanged():IAct{
			return (_yChanged || (_yChanged = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get widthChanged():IAct{
			return (_widthChanged || (_widthChanged = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get heightChanged():IAct{
			return (_heightChanged || (_heightChanged = new Act()));
		}
		
		protected var _heightChanged:Act;
		protected var _widthChanged:Act;
		protected var _yChanged:Act;
		protected var _xChanged:Act;
		
		
		public function get rectProvider():IRectangleProvider{
			return _rectProvider;
		}
		public function set rectProvider(value:IRectangleProvider):void{
			if(_rectProvider!=value){
				if(_rectProvider){
					_rectProvider.rectangleChanged.removeHandler(onRectChanged);
					_rectProvider.xChanged.removeHandler(onXChanged);
					_rectProvider.yChanged.removeHandler(onYChanged);
					_rectProvider.widthChanged.removeHandler(onWidthChanged);
					_rectProvider.heightChanged.removeHandler(onHeightChanged);
				}
				_rectProvider = value;
				if(_rectProvider){
					_rectProvider.rectangleChanged.addHandler(onRectChanged);
					_rectProvider.xChanged.addHandler(onXChanged);
					_rectProvider.yChanged.addHandler(onYChanged);
					_rectProvider.widthChanged.addHandler(onWidthChanged);
					_rectProvider.heightChanged.addHandler(onHeightChanged);
				}else{
					_x = NaN;
					_y = NaN;
					_width = NaN;
					_height = NaN;
				}
				invalidateRectangle();
			}
		}
			
		
		public function get sourceCoordSpace():DisplayObject{
			return _sourceCoordSpace;
		}
		public function set sourceCoordSpace(value:DisplayObject):void{
			if(_sourceCoordSpace!=value){
				_sourceCoordSpace = value;
				invalidateRectangle();
			}
		}
		
		public function get destinationCoordSpace():DisplayObject{
			return _destinationCoordSpace;
		}
		public function set destinationCoordSpace(value:DisplayObject):void{
			if(_destinationCoordSpace!=value){
				_destinationCoordSpace = value;
				invalidateRectangle();
			}
		}
		
		
		public function get x():Number{
			_rectCalcFlag.validate();
			return _x;
		}
		public function get y():Number{
			_rectCalcFlag.validate();
			return _y;
		}
		public function get width():Number{
			_rectCalcFlag.validate();
			return _width;
		}
		public function get height():Number{
			_rectCalcFlag.validate();
			return _height;
		}
		
		
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		
		
		private var _rectProvider:IRectangleProvider;
		
		private var _destinationCoordSpace:DisplayObject;
		private var _sourceCoordSpace:DisplayObject;
		
		private var _rectCalcFlag:ValidationFlag = new ValidationFlag(calcRect,false);
		
		
		public function CoordSpaceRectConverter(rectProvider:IRectangleProvider=null, sourceCoordSpace:DisplayObject=null, destinationCoordSpace:DisplayObject=null )
		{
			this.rectProvider = rectProvider;
			this.sourceCoordSpace = sourceCoordSpace;
			this.destinationCoordSpace = destinationCoordSpace;
			
		}
		
		private function calcRect():void
		{
			if(_rectProvider){
				var topLeft:Point = new Point(_rectProvider.x,_rectProvider.y);
				var bottomRight:Point = new Point(_rectProvider.x+_rectProvider.width,_rectProvider.y+_rectProvider.height);
				
				if(_sourceCoordSpace){
					topLeft = _sourceCoordSpace.localToGlobal(topLeft);
					bottomRight = _sourceCoordSpace.localToGlobal(bottomRight);
				}
				if(_destinationCoordSpace){
					topLeft = _destinationCoordSpace.globalToLocal(topLeft);
					bottomRight = _destinationCoordSpace.globalToLocal(bottomRight);
				}
				_setRectangle(topLeft.x,topLeft.y,bottomRight.x-topLeft.x,bottomRight.y-topLeft.y);
			}else{
				_setRectangle(NaN,NaN,NaN,NaN);
			}
		}
		
		protected function _setRectangle(x:Number, y:Number, width:Number, height:Number):void{
			_x = x;
			_y = y;
			_width = width;
			_height = height;
		}
		
		private function onRectChanged(from:IRectangleProvider):void{
			_rectCalcFlag.invalidate();
			if(_rectangleChanged)_rectangleChanged.perform(this);
		}
		private function onXChanged(from:IRectangleProvider):void{
			if(_xChanged)_xChanged.perform(this);
		}
		private function onYChanged(from:IRectangleProvider):void{
			if(_yChanged)_yChanged.perform(this);
		}
		private function onWidthChanged(from:IRectangleProvider):void{
			if(_widthChanged)_widthChanged.perform(this);
		}
		private function onHeightChanged(from:IRectangleProvider):void{
			if(_heightChanged)_heightChanged.perform(this);
		}
		
		
		private function invalidateRectangle():void{
			_rectCalcFlag.invalidate();
			if(_rectangleChanged)_rectangleChanged.perform(this);
			if(_xChanged)_xChanged.perform(this);
			if(_yChanged)_yChanged.perform(this);
			if(_widthChanged)_widthChanged.perform(this);
			if(_heightChanged)_heightChanged.perform(this);
		}	
	}
}