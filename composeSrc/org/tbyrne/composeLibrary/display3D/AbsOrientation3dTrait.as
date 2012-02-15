package org.tbyrne.composeLibrary.display3D
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.display.validation.ValidationFlag;
	
	public class AbsOrientation3dTrait extends AbstractTrait
	{
		public function AbsOrientation3dTrait(){
			super();
		}
		/**
		 * @inheritDoc
		 */
		public function get position3dChanged():IAct{
			return (_position3dChanged || (_position3dChanged = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get rotation3dChanged():IAct{
			return (_rotation3dChanged || (_rotation3dChanged = new Act()));
		}
		
		protected var _rotation3dChanged:Act;
		protected var _position3dChanged:Act;
		
		
		public function get posX():Number{
			return _posX;
		}
		protected function setPosX(value:Number):void{
			if(_posX!=value){
				_posX = value;
				if(_posXChanged)_posXChanged.perform(this);
				if(_position3dChanged)_position3dChanged.perform(this);
				invalidateMatrix();
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get posXChanged():IAct{
			return (_posXChanged || (_posXChanged = new Act()));
		}
		
		protected var _posXChanged:Act;
		protected var _posX:Number = 0;
		
		
		public function get posY():Number{
			return _posY;
		}
		protected function setPosY(value:Number):void{
			if(_posY!=value){
				_posY = value;
				if(_posYChanged)_posYChanged.perform(this);
				if(_position3dChanged)_position3dChanged.perform(this);
				invalidateMatrix();
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get posYChanged():IAct{
			return (_posYChanged || (_posYChanged = new Act()));
		}
		
		protected var _posYChanged:Act;
		protected var _posY:Number = 0;
		
		
		public function get posZ():Number{
			return _posZ;
		}
		protected function setPosZ(value:Number):void{
			if(_posZ!=value){
				_posZ = value;
				if(_posZChanged)_posZChanged.perform(this);
				if(_position3dChanged)_position3dChanged.perform(this);
				invalidateMatrix();
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get posZChanged():IAct{
			return (_posZChanged || (_posZChanged = new Act()));
		}
		
		protected var _posZChanged:Act;
		protected var _posZ:Number = 0;
		
		
		public function get rotX():Number{
			return _rotX;
		}
		protected function setRotX(value:Number):void{
			if(_rotX!=value){
				_rotX = value;
				if(_rotXChanged)_rotXChanged.perform(this);
				if(_rotation3dChanged)_rotation3dChanged.perform(this);
				invalidateMatrix();
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get rotXChanged():IAct{
			return (_rotXChanged || (_rotXChanged = new Act()));
		}
		
		protected var _rotXChanged:Act;
		protected var _rotX:Number = 0;
		
		
		public function get rotY():Number{
			return _rotY;
		}
		protected function setRotY(value:Number):void{
			if(_rotY!=value){
				_rotY = value;
				if(_rotYChanged)_rotYChanged.perform(this);
				if(_rotation3dChanged)_rotation3dChanged.perform(this);
				invalidateMatrix();
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get rotYChanged():IAct{
			return (_rotYChanged || (_rotYChanged = new Act()));
		}
		
		protected var _rotYChanged:Act;
		protected var _rotY:Number = 0;
		
		
		public function get rotZ():Number{
			return _rotZ;
		}
		protected function setRotZ(value:Number):void{
			if(_rotZ!=value){
				_rotZ = value;
				if(_rotZChanged)_rotZChanged.perform(this);
				if(_rotation3dChanged)_rotation3dChanged.perform(this);
				invalidateMatrix();
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get rotZChanged():IAct{
			return (_rotZChanged || (_rotZChanged = new Act()));
		}
		
		protected var _rotZChanged:Act;
		protected var _rotZ:Number = 0;
		
		
		public function setRotation3d(x:Number, y:Number, z:Number):void{
			if(_setRotation3d(x,y,z)){
				if(_rotation3dChanged)_rotation3dChanged.perform(this);
				invalidateMatrix();
			}
		}
		protected function _setRotation3d(x:Number, y:Number, z:Number):Boolean{
			var xDif:Number = (x-_rotX);
			var yDif:Number = (y-_rotY);
			var zDif:Number = (z-_rotZ);
			if(xDif || yDif || zDif){
				
				if(xDif){
					_rotX = x;
					if(_rotXChanged)_rotXChanged.perform(this);
				}
				if(yDif){
					_rotY = y;
					if(_rotYChanged)_rotYChanged.perform(this);
				}
				if(zDif){
					_rotZ = z;
					if(_rotZChanged)_rotZChanged.perform(this);
				}
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get matrix3dChanged():IAct{
			return (_matrix3dChanged || (_matrix3dChanged = new Act()));
		}
		public function get matrix3d():Matrix3D{
			_matrixFlag.validate();
			return _matrix3d;
		}
		public function get invMatrix3d():Matrix3D{
			_invMatrixFlag.validate();
			return _invMatrix3d;
		}
		protected function invalidateMatrix():void{
			_matrixFlag.invalidate();
			_invMatrixFlag.invalidate();
			if(_matrix3dChanged)_matrix3dChanged.perform(this);
		}
		protected function compileMatrix():void{
			_matrix3d.identity()
			_matrix3d.appendRotation( _rotY, Vector3D.Y_AXIS );
			_matrix3d.appendRotation( _rotX, Vector3D.X_AXIS );
			_matrix3d.appendRotation( _rotZ, Vector3D.Z_AXIS );
			_matrix3d.appendTranslation(_posX,_posY,_posZ);
			
			/*
			var comps:Vector.<Vector3D> = _matrix3d.decompose();
			var pos:Vector3D = comps[0];
			var rot:Vector3D = comps[1];
			
			pos.x = _posX;
			pos.y = _posY;
			pos.z = _posZ;
			
			rot.x = _rotX*Math.PI/180;
			rot.y = _rotY*Math.PI/180;
			rot.z = _rotZ*Math.PI/180;
			
			_matrix3d.recompose(comps);*/
		}
		private function createInvMatrix():void{
			_matrixFlag.validate();
			_invMatrix3d.copyFrom(_matrix3d);
			_invMatrix3d.invert();
		}
		protected var _matrix3dChanged:Act;
		protected var _matrix3d:Matrix3D = new Matrix3D();
		protected var _invMatrix3d:Matrix3D = new Matrix3D();
		protected var _matrixFlag:ValidationFlag = new ValidationFlag(compileMatrix,false);
		protected var _invMatrixFlag:ValidationFlag = new ValidationFlag(createInvMatrix,false);
	}
}