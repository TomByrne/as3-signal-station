package org.tbyrne.composeLibrary.display3D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.display3D.types.IPosition3dTrait;
	
	public class Position3dTrait extends AbstractTrait implements IPosition3dTrait
	{
		
		/**
		 * @inheritDoc
		 */
		public function get position3dChanged():IAct{
			return (_position3dChanged || (_position3dChanged = new Act()));
		}
		
		public function get x3d():Number{
			return _x3d;
		}
		public function set x3d(value:Number):void{
			if(_x3d!=value){
				_x3d = value;
				if(_position3dChanged)_position3dChanged.perform(this);
			}
		}
		
		public function get y3d():Number{
			return _y3d;
		}
		public function set y3d(value:Number):void{
			if(_y3d!=value){
				_y3d = value;
				if(_position3dChanged)_position3dChanged.perform(this);
			}
		}
		
		public function get z3d():Number{
			return _z3d;
		}
		public function set z3d(value:Number):void{
			if(_z3d!=value){
				_z3d = value;
				if(_position3dChanged)_position3dChanged.perform(this);
			}
		}
		
		private var _z3d:Number;
		private var _y3d:Number;
		private var _x3d:Number;
		
		protected var _position3dChanged:Act;
		
		public function Position3dTrait()
		{
			super();
		}
		
		
		public function setPosition3d(x:Number, y:Number, z:Number):void{
			if(_x3d!=x || _y3d!=y || _z3d!=z){
				_x3d = x;
				_y3d = y;
				_z3d = z;
				if(_position3dChanged)_position3dChanged.perform(this);
			}
		}
	}
}