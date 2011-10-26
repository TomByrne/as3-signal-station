package org.tbyrne.geom.rect
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;

	public class AbstractRectangleData implements IRectangleProvider
	{
		
		/**
		 * @inheritDoc
		 */
		public function get rectangleChanged():IAct{
			return (_rectangleChanged || (_rectangleChanged = new Act()));
		}
		
		protected var _rectangleChanged:Act;
		
		
		
		public function get x():Number{
			return _x;
		}
		public function set x(value:Number):void{
			if(_x!=value){
				_x = value;
				if(_xChanged)_xChanged.perform(this);
				if(_rectangleChanged)_rectangleChanged.perform(this);
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get xChanged():IAct{
			return (_xChanged || (_xChanged = new Act()));
		}
		
		public function get y():Number{
			return _y;
		}
		public function set y(value:Number):void{
			if(_y!=value){
				_y = value;
				if(_yChanged)_yChanged.perform(this);
				if(_rectangleChanged)_rectangleChanged.perform(this);
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get yChanged():IAct{
			return (_yChanged || (_yChanged = new Act()));
		}
		
		public function get width():Number{
			return _width;
		}
		public function set width(value:Number):void{
			if(_width!=value){
				_width = value;
				if(_widthChanged)_widthChanged.perform(this);
				if(_rectangleChanged)_rectangleChanged.perform(this);
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get widthChanged():IAct{
			return (_widthChanged || (_widthChanged = new Act()));
		}
		
		public function get height():Number{
			return _height;
		}
		public function set height(value:Number):void{
			if(_height!=value){
				_height = value;
				if(_heightChanged)_heightChanged.perform(this);
				if(_rectangleChanged)_rectangleChanged.perform(this);
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get heightChanged():IAct{
			return (_heightChanged || (_heightChanged = new Act()));
		}
		
		protected var _heightChanged:Act;
		protected var _height:Number;
		protected var _widthChanged:Act;
		protected var _width:Number;
		protected var _yChanged:Act;
		protected var _y:Number;
		protected var _xChanged:Act;
		protected var _x:Number;
		
		
		protected function _setRectangle(x:Number, y:Number, width:Number, height:Number):void{
			var xDif:Boolean = _x!=x;
			var yDif:Boolean = _y!=y;
			var wDif:Boolean = _width!=width;
			var hDif:Boolean = _height!=height;
			if(xDif || yDif || wDif || hDif){
				if(xDif){
					_x = x;
					if(_xChanged)_xChanged.perform(this);
				}
				if(yDif){
					_y = y;
					if(_yChanged)_yChanged.perform(this);
				}
				if(wDif){
					_width = width;
					if(_widthChanged)_widthChanged.perform(this);
				}
				if(hDif){
					_height = height;
					if(_heightChanged)_heightChanged.perform(this);
				}
				if(_rectangleChanged)_rectangleChanged.perform(this);
			}
		}
	}
}