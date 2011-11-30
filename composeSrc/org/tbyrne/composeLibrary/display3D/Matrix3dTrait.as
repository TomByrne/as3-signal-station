package org.tbyrne.composeLibrary.display3D
{
	import flash.geom.Matrix3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.display3D.types.IMatrix3dTrait;
	
	public class Matrix3dTrait extends AbstractTrait implements IMatrix3dTrait
	{
		
		
		/**
		 * @inheritDoc
		 */
		public function get matrix3dChanged():IAct{
			return (_matrix3dChanged || (_matrix3dChanged = new Act()));
		}
		
		public function get matrix3d():Matrix3D{
			return _matrix3d;
		}
		public function set matrix3d(value:Matrix3D):void{
			if(_matrix3d!=value){
				_matrix3d = value;
				_invMatrixInvalid = true;
				if(_matrix3dChanged)_matrix3dChanged.perform(this);
			}
		}
		public function get invMatrix3d():Matrix3D
		{
			if(_invMatrixInvalid){
				if(_matrix3d){
					_invMatrix3d = _matrix3d.clone();
					_invMatrix3d.invert();
				}else{
					_invMatrix3d = null;
				}
			}
			return _invMatrix3d;
		}
		
		private var _invMatrixInvalid:Boolean = false;
		private var _invMatrix3d:Matrix3D;
		private var _matrix3d:Matrix3D;
		protected var _matrix3dChanged:Act;
		
		public function Matrix3dTrait(matrix3d:Matrix3D=null){
			super();
			this.matrix3d = matrix3d;
		}
	}
}