package org.tbyrne.composeLibrary.away3d
{
	import away3d.cameras.Camera3D;
	import away3d.core.math.Plane3D;
	import away3d.tools.utils.Ray;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.display3D.I2dTo3dTrait;
	import org.tbyrne.composeLibrary.types.display3D.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.types.draw.IDrawAwareTrait;

	public class Away3dUnprojector extends AbstractTrait implements IDrawAwareTrait
	{
		//private static const ROUND_REPROJECT_VALUES:int = 3; //decimal places
		private static const UP_VECTOR:Vector3D = new Vector3D(0,1,0);
		
		public function get camera():Camera3D{
			return _camera;
		}
		public function set camera(value:Camera3D):void{
			if(_camera!=value){
				_camera = value;
			}
		}
		
		public function get cameraChanged():IAct{
			return _cameraChanged;
		}
		public function set cameraChanged(value:IAct):void{
			if(_cameraChanged!=value){
				if(_cameraChanged){
					_cameraChanged.removeHandler(onCameraChanged);
				}
				_cameraChanged = value;
				if(_cameraChanged){
					_cameraChanged.addHandler(onCameraChanged);
				}
			}
		}
		
		private var _cameraChanged:IAct;
		private var _camera:Camera3D;
		
		private var _2dPositions:IndexedList;
		private var _2dInvalid:IndexedList;
		private var _2dAllInvalid:Boolean;
		
		private var _dummyVector:Vector3D;
		
		public function Away3dUnprojector(camera:Camera3D=null, cameraChanged:IAct=null){
			super();
			
			_2dPositions = new IndexedList();
			_2dInvalid = new IndexedList();
			_dummyVector = new Vector3D();
			
			addConcern(new TraitConcern(false,true,I2dTo3dTrait,[I2dTo3dTrait]));
			
			this.cameraChanged = cameraChanged;
			this.camera = camera;
		}
		
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var trait2d:I2dTo3dTrait;
			
			if(trait2d = (trait as I2dTo3dTrait)){
				_2dPositions.push(trait2d);
				trait2d.requestUnprojection.addHandler(on2dPositionChanged);
				if(!_2dAllInvalid)_2dInvalid.push(trait2d);
				
			}
		}
		
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
			var trait2d:I2dTo3dTrait;
			
			if(trait2d = (trait as I2dTo3dTrait)){
				_2dPositions.remove(trait2d);
				_2dInvalid.remove(trait2d);
				trait2d.requestUnprojection.removeHandler(on2dPositionChanged);
				//trait2d.setProjectedPoint(NaN, NaN, NaN, NaN);
				
			}
		}
		
		protected function on2dPositionChanged(from:I2dTo3dTrait):void{
			if(!_2dAllInvalid && !_2dInvalid.containsItem(from))_2dInvalid.push(from);
		}
		
		protected function invalidateAll():void{
			if(!_2dAllInvalid){
				_2dAllInvalid = true;
				if(_2dInvalid.list.length)_2dInvalid.clear();
			}
		}
		
		
		
		
		
		public function tick(timeStep:Number):void{
			var i:int;
			var translate:Vector.<Number>;
			var output:Vector.<Number>;
			
			var invalid2dList:Array;
			if(_2dAllInvalid){
				_2dAllInvalid = false;
				invalid2dList = _2dPositions.list;
			}else if(_2dInvalid.list.length){
				invalid2dList = _2dInvalid.list;
				_2dInvalid.clear();
			}
			
			var pos2d:I2dTo3dTrait;
			var z2d:Number;
			
			if(invalid2dList){
				translate = new Vector.<Number>();
				output = new Vector.<Number>();
				var readyTraits:Vector.<I2dTo3dTrait> = new Vector.<I2dTo3dTrait>();
				for(i=0; i<invalid2dList.length; ++i){
					pos2d = invalid2dList[i];
					
					var planePos:Vector3D;
					var planeNormal:Vector3D;
					if(pos2d.planeTransform){
						planePos = pos2d.planeTransform.matrix3d.position;
						planeNormal = pos2d.planeTransform.matrix3d.transformVector(new Vector3D(1,0,0));
					}else{
						var distance:Vector3D = new Vector3D(0,0,pos2d.cameraDistance);
						
						var values:Vector.<Number> = _camera.sceneTransform.rawData;
						values[12] = 0;
						values[13] = 0; // reset translation
						values[14] = 0;
						var matrix:Matrix3D = new Matrix3D(values);
						
						distance = matrix.transformVector(distance);
						
						planePos = _camera.sceneTransform.position.clone();
						planePos.x += distance.x;
						planePos.y += distance.y;
						planePos.z += distance.z;
						planeNormal = _camera.sceneTransform.transformVector(new Vector3D(1,0,0));
					}
					
					var planeD:Number = planePos.x*planeNormal.x + planePos.y*planeNormal.y + planePos.z*planeNormal.z;
					
					var pMouse:Vector3D = _camera.unproject(pos2d.x2d, pos2d.y2d);
					var cam:Vector3D = _camera.position;
					var d0: Number = planeNormal.x * cam.x + planeNormal.y * cam.y + planeNormal.z * cam.z - planeD;
					var d1: Number = planeNormal.x * pMouse.x + planeNormal.y * pMouse.y + planeNormal.z * pMouse.z - planeD;
					var m: Number = d1 / ( d1 - d0 );
					
					var x3d:Number = pMouse.x + ( cam.x - pMouse.x ) * m;
					var y3d:Number = pMouse.y + ( cam.y - pMouse.y ) * m;
					var z3d:Number = pMouse.z + ( cam.z - pMouse.z ) * m;
					
					pos2d.setUnprojectedPoint(x3d,y3d,z3d);
				}
			}
		}
		
		private function onCameraChanged(... params):void{
			invalidateAll();
		}
	}
}