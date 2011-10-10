package org.tbyrne.tbyrne.composeLibrary.display3D
{
	import org.tbyrne.tbyrne.composeLibrary.controls.ICameraControls;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.tbyrne.composeLibrary.types.display3D.IOrientation3dTrait;
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.core.NumberData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class CameraControls extends AbsOrientation3dTrait implements IOrientation3dTrait, ICameraControls
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
		public function set rotX(value:Number):void{
			setRotX(value);
		}
		public function set rotY(value:Number):void{
			setRotY(value);
		}
		public function set rotZ(value:Number):void{
			setRotZ(value);
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
		
		public function CameraControls(){
			super();
			
			_focalLengthProvider.numericalValueChanged.addHandler(onFocalLengthChanged);
			_fieldOfViewProvider.numericalValueChanged.addHandler(onFieldOfViewChanged);
			_orthographicProvider.booleanValueChanged.addHandler(onOrthographicChanged);
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
				if(_position3dChanged)_position3dChanged.perform(this);
			}
		}
		public function setRotation(x:Number, y:Number, z:Number):void{
			var xDif:Boolean = (_rotX!=x);
			var yDif:Boolean = (_rotY!=y);
			var zDif:Boolean = (_rotZ!=z);
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
				if(_rotation3dChanged)_rotation3dChanged.perform(this);
			}
		}
	}
}