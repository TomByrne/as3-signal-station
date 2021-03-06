package org.tbyrne.composeLibrary.display3D
{
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.composeLibrary.controls.ICameraControls;
	import org.tbyrne.composeLibrary.display3D.types.IMatrix3dTrait;
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.core.NumberData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class CameraControls extends RotationControls implements ICameraControls
	{
		private static const RADS_TO_DEGS:Number = 180/Math.PI;
		private static const DEGS_TO_RADS:Number = Math.PI/180;
		
		/**
		 * @inheritDoc
		 */
		public function get focalLengthChanged():IAct{
			return _focalLengthProvider.numericalValueChanged;
		}
		public function get focalLengthProvider():INumberProvider{
			return _focalLengthProvider;
		}
		public function get focalLength():Number{
			return _focalLengthProvider.numericalValue;
		}
		public function set focalLength(value:Number):void{
			_focalLengthMode = true;
			_focalLengthProvider.numericalValue = value;
		}
		/**
		 * @inheritDoc
		 */
		public function get orthographicChanged():IAct{
			return _orthographicProvider.booleanValueChanged;
		}
		public function get orthographicProvider():IBooleanProvider{
			return _orthographicProvider;
		}
		public function get orthographic():Boolean{
			return _orthographicProvider.booleanValue;
		}
		public function set orthographic(value:Boolean):void{
			_focalLengthMode = true;
			_orthographicProvider.booleanValue = value;
		}
		/**
		 * @inheritDoc
		 */
		public function get fieldOfViewChanged():IAct{
			return _fieldOfViewProvider.numericalValueChanged;
		}
		public function get fieldOfViewProvider():INumberProvider{
			return _fieldOfViewProvider;
		}
		public function get fieldOfView():Number{
			return _fieldOfViewProvider.numericalValue;
		}
		public function set fieldOfView(value:Number):void{
			_focalLengthMode = false;
			_fieldOfViewProvider.numericalValue = value;
		}
		
		public function set posX(value:Number):void{
			setPosX(value);
		}
		public function set posY(value:Number):void{
			setPosY(value);
		}
		public function set posZ(value:Number):void{
			setPosZ(value);
		}
		/**
		 * @inheritDoc
		 */
		public function get positionOffsetChanged():IAct{
			return _positionOffsetProvider.numericalValueChanged;
		}
		public function get positionOffsetProvider():INumberProvider{
			return _positionOffsetProvider;
		}
		public function get positionOffset():Number{
			return _positionOffsetProvider.numericalValue;
		}
		public function set positionOffset(value:Number):void{
			_positionOffsetProvider.numericalValue = value;
		}
		protected var _positionOffsetProvider:NumberData = new NumberData(0);
		
		/**
		 * @inheritDoc
		 */
		public function get sceneScaleChanged():IAct{
			return _sceneScaleProvider.numericalValueChanged;
		}
		public function get sceneScaleProvider():INumberProvider{
			return _sceneScaleProvider;
		}
		public function get sceneScale():Number{
			return _sceneScaleProvider.numericalValue;
		}
		public function set sceneScale(value:Number):void{
			_sceneScaleProvider.numericalValue = value;
		}
		protected var _sceneScaleProvider:NumberData = new NumberData(1);
		
		/**
		 * @inheritDoc
		 */
		public function get nearDistChanged():IAct{
			return _nearDistProvider.numericalValueChanged;
		}
		public function get nearDistProvider():INumberProvider{
			return _nearDistProvider;
		}
		public function get nearDist():Number{
			return _nearDistProvider.numericalValue;
		}
		public function set nearDist(value:Number):void{
			_nearDistProvider.numericalValue = value;
		}
		protected var _nearDistProvider:NumberData = new NumberData(1);
		
		/**
		 * @inheritDoc
		 */
		public function get farDistChanged():IAct{
			return _farDistProvider.numericalValueChanged;
		}
		public function get farDistProvider():INumberProvider{
			return _farDistProvider;
		}
		public function get farDist():Number{
			return _farDistProvider.numericalValue;
		}
		public function set farDist(value:Number):void{
			_farDistProvider.numericalValue = value;
		}
		protected var _farDistProvider:NumberData = new NumberData(1);
		
		
		
		
		public function get offsetMatrixTrait():IMatrix3dTrait{
			return _offsetMatrixTrait;
		}
		public function get matrixTrait():IMatrix3dTrait{
			return _matrixTrait;
		}
		
		protected var _focalLengthProvider:NumberData = new NumberData(Number.POSITIVE_INFINITY);
		protected var _fieldOfViewProvider:NumberData = new NumberData(Number.POSITIVE_INFINITY);
		protected var _orthographicProvider:BooleanData = new BooleanData();
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _diagonalSize:Number;
		protected var _focalLengthMode:Boolean;
		
		protected var _lastValidFocalLength:Number = Number.POSITIVE_INFINITY;
		
		protected var _ignoreEvents:Boolean;
		
		protected var _offsetMatrixTrait:Matrix3dTrait;
		protected var _matrixTrait:Matrix3dTrait;
		
		protected var _ignoreChanges:Boolean;
		
		public function CameraControls(){
			super();
			
			_offsetMatrixTrait = new Matrix3dTrait(new Matrix3D());
			_matrixTrait = new Matrix3dTrait(_matrix3d);
			
			_matrixTrait.matrix3dChanged.addHandler(onMatrixChanged);
			
			_positionOffsetProvider.numericalValueChanged.addHandler(onPosOffsetChanged);
			_focalLengthProvider.numericalValueChanged.addHandler(onFocalLengthChanged);
			_fieldOfViewProvider.numericalValueChanged.addHandler(onFieldOfViewChanged);
			_orthographicProvider.booleanValueChanged.addHandler(onOrthographicChanged);
		}
		
		private function onMatrixChanged(from:Matrix3dTrait):void{
			if(!_ignoreChanges){
				var eular:Vector.<Vector3D> = from.matrix3d.decompose(Orientation3D.EULER_ANGLES);
				
				var pos:Vector3D = eular[0];
				var rot:Vector3D = eular[1];
				
				if(_setPosition(pos.x,pos.y,pos.z) || _setRotation3d(rot.x*RADS_TO_DEGS,rot.y*RADS_TO_DEGS,rot.z*RADS_TO_DEGS)){
					invalidateOffsetMatrix();
				}
				
			}
		}
		
		private function onFieldOfViewChanged(from:NumberData):void{
			if(!_ignoreEvents){
				_focalLengthMode = false;
				calcFocalLength();
			}
		}
		private function onFocalLengthChanged(from:NumberData):void{
			if(!_ignoreEvents){
				_focalLengthMode = true;
				calcFieldOfView();
			}
		}
		private function onPosOffsetChanged(from:NumberData):void{
			invalidateOffsetMatrix();
		}
		private function onOrthographicChanged(from:BooleanData):void{
			if(!_ignoreEvents){
				focalLength = _orthographicProvider.booleanValue?Number.POSITIVE_INFINITY:_lastValidFocalLength;
			}
		}
		public function setViewSize(width:Number, height:Number):void{
			if(_width!=width || _height!=height){
				_width = width;
				_height = height;
				_diagonalSize = Math.sqrt(_width*_width+_height*_height);
				if(_focalLengthMode){
					calcFieldOfView();
				}else{
					calcFocalLength();
				}
			}
		}
		
		private function calcFieldOfView():void{
			var focalLength:Number = _focalLengthProvider.numericalValue;
			
			_ignoreEvents = true;
			if(isNaN(focalLength) || focalLength==Number.POSITIVE_INFINITY || focalLength==Number.NEGATIVE_INFINITY){
				_fieldOfViewProvider.numericalValue = Number.POSITIVE_INFINITY;
				_orthographicProvider.booleanValue = true;
			}else{
				_lastValidFocalLength = focalLength;
				_fieldOfViewProvider.numericalValue = (2*Math.atan((_height/2) / focalLength))*RADS_TO_DEGS;
				_orthographicProvider.booleanValue = false;
			}
			_ignoreEvents = false;
		}
		private function calcFocalLength():void{
			var fov:Number = _fieldOfViewProvider.numericalValue*DEGS_TO_RADS;
			
			_ignoreEvents = true;
			if(isNaN(fov) || fov==Number.POSITIVE_INFINITY || fov==Number.NEGATIVE_INFINITY){
				_focalLengthProvider.numericalValue = Number.POSITIVE_INFINITY;
				_orthographicProvider.booleanValue = true;
			}else{
				var fovFactor:Number = Math.cos(fov/2) / Math.sin(fov/2);
				_lastValidFocalLength = _height/2*fovFactor;
				_focalLengthProvider.numericalValue = _lastValidFocalLength;
				_orthographicProvider.booleanValue = false;
			}
			_ignoreEvents = false;
		}
		public function setPosition(x:Number, y:Number, z:Number):void{
			if(_setPosition(x,y,z)){
				if(_position3dChanged)_position3dChanged.perform(this);
				invalidateMatrix();
			}
		}
		protected function _setPosition(x:Number, y:Number, z:Number):Boolean{
			var xDif:Boolean = (_posX!=x);
			var yDif:Boolean = (_posY!=y);
			var zDif:Boolean = (_posZ!=z);
			if(xDif || yDif || zDif){
				if(xDif){
					_posX = x;
					if(_posXChanged)_posXChanged.perform(this);
				}
				if(yDif){
					_posY = y;
					if(_posYChanged)_posYChanged.perform(this);
				}
				if(zDif){
					_posZ = z;
					if(_posZChanged)_posZChanged.perform(this);
				}
				return true;
			}else{
				return false;
			}
		}
		override protected function invalidateMatrix():void{
			compileMatrix();
			_ignoreChanges = true;
			_matrixTrait.matrix3dChanged.perform(_matrixTrait);
			_ignoreChanges = false;
			invalidateOffsetMatrix();
		}
		protected function invalidateOffsetMatrix():void{
			compileOffsetMatrix();
			_offsetMatrixTrait.matrix3dChanged.perform(_offsetMatrixTrait);
		}
		protected function compileOffsetMatrix():void{
			
			var offsetMatrix:Matrix3D = _offsetMatrixTrait.matrix3d;
			
			offsetMatrix.identity()
			offsetMatrix.appendRotation( _rotX, Vector3D.X_AXIS );
			offsetMatrix.appendRotation( _rotY, Vector3D.Y_AXIS );
			offsetMatrix.appendRotation( _rotZ, Vector3D.Z_AXIS );
			
			if(!isNaN(_positionOffsetProvider.numericalValue) && _positionOffsetProvider.numericalValue!=0){
				var distVec:Vector3D = new Vector3D(0,0,_positionOffsetProvider.numericalValue);
				distVec = offsetMatrix.transformVector(distVec);
				
				offsetMatrix.appendTranslation(_posX+distVec.x,_posY+distVec.y,_posZ+distVec.z);
			}else{
				offsetMatrix.appendTranslation(_posX,_posY,_posZ);
			}
		}
	}
}