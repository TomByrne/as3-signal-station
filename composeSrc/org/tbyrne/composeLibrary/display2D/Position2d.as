package org.tbyrne.composeLibrary.display2D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.display2D.types.IPosition2dTrait;
	
	public class Position2d extends AbstractTrait implements IPosition2dTrait
	{
		/**
		 * @inheritDoc
		 */
		public function get position2dChanged():IAct{
			return (_position2dChanged || (_position2dChanged = new Act()));
		}
		
		public function get x2d():Number{
			return _x;
		}
		
		public function get y2d():Number{
			return _y;
		}
		
		protected var _position2dChanged:Act;
		
		protected var _x:Number;
		protected var _y:Number;
		
		
		public function Position2d(x:Number=NaN, y:Number=NaN){
			super();
			setPosition2d(x,y);
		}
		
		
		public function setPosition2d(x:Number, y:Number):void
		{
			if(_x!=x || _y!=y){
				_x = x;
				_y = y;
				if(_position2dChanged)_position2dChanged.perform(this);
			}
		}
	}
}