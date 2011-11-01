package org.tbyrne.composeLibrary.away3d
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.core.math.Plane3D;
	import away3d.tools.utils.Ray;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.display3D.I2dTo3dTrait;
	import org.tbyrne.composeLibrary.types.display3D.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.types.draw.IDrawAwareTrait;
	
	use namespace arcane;

	public class Away3dUnprojector extends AbstractTrait implements IDrawAwareTrait
	{
		//private static const ROUND_REPROJECT_VALUES:int = 3; //decimal places
		private static const UP_VECTOR:Vector3D = new Vector3D(0,1,0);
		
		public function get view():View3D{
			return _view;
		}
		public function set view(value:View3D):void{
			_view = value;
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
		private var _view:View3D;
		
		private var _2dPositions:IndexedList;
		private var _2dInvalid:IndexedList;
		private var _2dAllInvalid:Boolean;
		
		private var _dummyVector:Vector3D;
		
		public function Away3dUnprojector(view:View3D=null, cameraChanged:IAct=null){
			super();
			
			_2dPositions = new IndexedList();
			_2dInvalid = new IndexedList();
			_dummyVector = new Vector3D();
			
			addConcern(new Concern(false,true,false,I2dTo3dTrait));
			
			this.cameraChanged = cameraChanged;
			this.view = view;
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var trait2d:I2dTo3dTrait;
			
			if(trait2d = (trait as I2dTo3dTrait)){
				_2dPositions.push(trait2d);
				trait2d.requestUnprojection.addHandler(onRequestUnprojection);
				if(!_2dAllInvalid)_2dInvalid.push(trait2d);
				
			}
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var trait2d:I2dTo3dTrait;
			
			if(trait2d = (trait as I2dTo3dTrait)){
				_2dPositions.remove(trait2d);
				_2dInvalid.remove(trait2d);
				trait2d.requestUnprojection.removeHandler(onRequestUnprojection);
				//trait2d.setProjectedPoint(NaN, NaN, NaN, NaN);
				
			}
		}
		
		protected function onRequestUnprojection(from:I2dTo3dTrait, immediate:Boolean):void{
			if(immediate){
				validatePos(from);
				_2dInvalid.remove(from);
			}else{
				if(!_2dAllInvalid && !_2dInvalid.containsItem(from))_2dInvalid.push(from);
			}
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
					validatePos(pos2d);
					
				}
			}
		}
		
		private function validatePos(pos2d:I2dTo3dTrait):void
		{
			var planePos:Vector3D;
			var planeNormal:Vector3D;
			if(pos2d.planeTransform){
				planePos = pos2d.planeTransform.matrix3d.position;
				planeNormal = pos2d.planeTransform.matrix3d.transformVector(new Vector3D(1,0,0));
			}else{
				planeNormal = new Vector3D(0,0,pos2d.cameraDistance);
				
				var values:Vector.<Number> = _view.camera.sceneTransform.rawData;
				values[12] = 0;
				values[13] = 0; // reset translation
				values[14] = 0;
				var matrix:Matrix3D = new Matrix3D(values);
				
				planeNormal = matrix.transformVector(planeNormal);
				
				planePos = _view.camera.sceneTransform.position.clone();
				planePos.x += planeNormal.x;
				planePos.y += planeNormal.y;
				planePos.z += planeNormal.z;
				
				planeNormal.normalize();
			}
			var planeD:Number = planePos.x*planeNormal.x + planePos.y*planeNormal.y + planePos.z*planeNormal.z;
			
			var ray:Vector3D = _view.unproject(pos2d.x2d, pos2d.y2d);
			var camPos:Vector3D = _view.camera.scenePosition;
			
			var d0: Number = planeNormal.x * camPos.x + planeNormal.y * camPos.y + planeNormal.z * camPos.z - planeD;
			var d1: Number = planeNormal.x * ray.x    + planeNormal.y * ray.y    + planeNormal.z * ray.z    - planeD;
			var m: Number = d1 / ( d1 - d0 );
			
			if(isNaN(m))m = 0;
			
			var x3d:Number = ray.x + ( camPos.x - ray.x ) * m;
			var y3d:Number = ray.y + ( camPos.y - ray.y ) * m;
			var z3d:Number = ray.z + ( camPos.z - ray.z ) * m;
			
			//trace("unproject: "+pos2d.x2d,pos2d.y2d,pos2d.cameraDistance,x3d,y3d,z3d,planeNormal,camPos);
			pos2d.setUnprojectedPoint(x3d,y3d,z3d);
			
			/*
			var d0: Number = _point.x * v0.x + _point.y * v0.y + _point.z * v0.z - d;
			var d1: Number = _point.x * v1.x + _point.y * v1.y + _point.z * v1.z - d;
			var m: Number = d1 / ( d1 - d0 );
			
			return new Vector3D(
			
				v1.x + ( v0.x - v1.x ) * m,
				
				v1.y + ( v0.y - v1.y ) * m,
				
				v1.z + ( v0.z - v1.z ) * m
				
			);*/
		}
		
		private function onCameraChanged(... params):void{
			invalidateAll();
		}
	}
}