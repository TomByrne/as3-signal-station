package org.tbyrne.composeLibrary.display3D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.composeLibrary.display2D.Position2d;
	import org.tbyrne.composeLibrary.types.display3D.I2dTo3dTrait;
	import org.tbyrne.composeLibrary.types.display3D.I3dTo2dTrait;
	import org.tbyrne.composeLibrary.types.display3D.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.types.display3D.IPosition3dTrait;

	/**
	 * Allows positions to exist in both 2D and 3D space simultaneously.
	 * The actual convertions are done in manager classes.
	 */
	public class Position3d2d extends Position2d implements IPosition3dTrait, I3dTo2dTrait, I2dTo3dTrait 
	{
		/**
		 * @inheritDoc
		 */
		public function get requestProjection():IAct{
			return (_requestProjection || (_requestProjection = new Act()));
		}
		/**
		 * @inheritDoc
		 */
		public function get requestUnprojection():IAct{
			return (_requestUnprojection || (_requestUnprojection = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get position3dChanged():IAct{
			return (_position3dChanged || (_position3dChanged = new Act()));
		}
		
		override public function get x2d():Number{
			return _empirical2d?_x:_projectedX;
		}
		
		override public function get y2d():Number{
			return _empirical2d?_y:_projectedY;
		}
		
		
		public function get cameraDistance():Number{
			return _cameraDistance;
		}
		public function set cameraDistance(value:Number):void{
			if(_cameraDistance!=value){
				_cameraDistance = value;
				if(!_planeTransform && _requestUnprojection)_requestUnprojection.perform(this);
			}
		}
		
		public function get x3d():Number{
			return _x3d;
		}
		public function get y3d():Number{
			return _y3d;
		}
		public function get z3d():Number{
			return _z3d;
		}
		public function get depthIndex():Number{
			return _cameraDistance;
		}
		
		public function get planeTransform():IMatrix3dTrait{
			return _planeTransform;
		}
		public function set planeTransform(value:IMatrix3dTrait):void{
			if(_planeTransform!=value){
				_planeTransform = value;
				if(_empirical2d && _requestUnprojection)_requestUnprojection.perform(this);
			}
		}
		
		private var _planeTransform:IMatrix3dTrait;
		
		private var _projectedY:Number;
		private var _projectedX:Number;
		private var _cameraDistance:Number;
		
		private var _empirical3d:Boolean = false;
		private var _empirical2d:Boolean = false;
		
		private var _z3d:Number;
		private var _y3d:Number;
		private var _x3d:Number;
		
		protected var _requestProjection:Act;
		protected var _requestUnprojection:Act;
		protected var _position3dChanged:Act;
		
		public function Position3d2d(x3d:Number=NaN, y3d:Number=NaN, z3d:Number=NaN){
			super();
			
			setPosition3d(x3d, y3d, z3d);
		}
		
		public function setPosition3d(x:Number, y:Number, z:Number):void{
			if((_x3d!=x && (!isNaN(_x3d) || !isNaN(x))) ||
				(_y3d!=y && (!isNaN(_y3d) || !isNaN(y))) ||
				(_z3d!=z && (!isNaN(_z3d) || !isNaN(z))) || _empirical2d){
				
				_x3d = x;
				_y3d = y;
				_z3d = z;
				
				_empirical3d = true;
				_empirical2d = false;
				if(_position3dChanged)_position3dChanged.perform(this);
				if(_requestProjection)_requestProjection.perform(this);
			}
		}
		override public function setPosition2d(x:Number, y:Number):void{
			if((_x!=x && (!isNaN(_x) || !isNaN(x))) ||
				(_y!=x && (!isNaN(_y) || !isNaN(y))) || _empirical3d){
				
				_empirical3d = false;
				_empirical2d = true;
				
				_x = x;
				_y = y;
				
				if(_position2dChanged)_position2dChanged.perform(this);
				if(_requestUnprojection)_requestUnprojection.perform(this);
			}
		}
		
		public function setUnprojectedPoint(x:Number, y:Number, z:Number):void{
			if(_empirical3d){
				return;
			}
			
			if(_x3d!=x || _y3d!=y || _z3d!=z){
				_x3d = x;
				_y3d = y;
				_z3d = z;
				
				if(!_empirical3d){
					_empirical3d = true;
					_projectedX = _x;
					_projectedY = _y;
				}
				if(_position3dChanged)_position3dChanged.perform(this);
			}
		}
		public function setProjectedPoint(x:Number, y:Number, scale:Number, cameraDistance:Number):void{
			var pointChanged:Boolean;
			if(_empirical3d && (_projectedX!=x || _projectedY!=y)){
				_empirical2d = false;
				_projectedX = x;
				_projectedY = y;
				if(_position2dChanged)_position2dChanged.perform(this);
				pointChanged = true;
			}
			if(_cameraDistance!=cameraDistance){
				_cameraDistance = cameraDistance;
				pointChanged = true;
			}
			
			if(pointChanged && _position2dChanged)_position2dChanged.perform(this);
		}
	}
}