package org.tbyrne.composeLibrary.away3d
{
	import away3d.arcane;
	import away3d.containers.View3D;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.display3D.types.I2dTo3dTrait;
	import org.tbyrne.composeLibrary.display3D.types.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.draw.types.IDrawAwareTrait;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
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
		
		public function get sceneScale():INumberProvider{
			return _sceneScale;
		}
		public function set sceneScale(value:INumberProvider):void{
			if(_sceneScale!=value){
				if(_sceneScale){
					_sceneScale.numericalValueChanged.addHandler(onSceneScaleChanged);
				}
				_sceneScale = value;
				if(_sceneScale){
					//_sceneScale.numericalValueChanged.addHandler(onSceneScaleChanged);
				}
				//invalidateAll();
			}
		}
		
		
		public function get sceneTransform():IMatrix3dTrait{
			return _sceneTransform;
		}
		public function set sceneTransform(value:IMatrix3dTrait):void{
			if(_sceneTransform!=value){
				if(_sceneTransform){
					_sceneTransform.matrix3dChanged.removeHandler(onSceneTransformChanged);
				}
				_sceneTransform = value;
				if(_sceneTransform){
					_sceneTransform.matrix3dChanged.addHandler(onSceneTransformChanged);
				}
			}
		}
		
		private var _sceneTransform:IMatrix3dTrait;
		
		private var _sceneScale:INumberProvider;
		private var _cameraChanged:IAct;
		private var _view:View3D;
		
		private var _2dPositions:IndexedList;
		private var _2dInvalid:IndexedList;
		private var _2dAllInvalid:Boolean;
		
		private var _dummyVector:Vector3D;
		
		public function Away3dUnprojector(view:View3D=null, cameraChanged:IAct=null, sceneScale:INumberProvider=null){
			super();
			
			_2dPositions = new IndexedList();
			_2dInvalid = new IndexedList();
			_dummyVector = new Vector3D();
			
			addConcern(new Concern(false,true,false,I2dTo3dTrait));
			
			this.cameraChanged = cameraChanged;
			this.view = view;
			this.sceneScale = sceneScale;
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var trait2d:I2dTo3dTrait;
			
			if(trait2d = (trait as I2dTo3dTrait)){
				_2dPositions.add(trait2d);
				trait2d.requestUnprojection.addHandler(onRequestUnprojection);
				if(!_2dAllInvalid)_2dInvalid.add(trait2d);
				
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
				validatePos(from,_sceneScale?_sceneScale.numericalValue:1);
				_2dInvalid.remove(from);
			}else{
				if(!_2dAllInvalid && !_2dInvalid.containsItem(from))_2dInvalid.add(from);
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
				var sceneScale:Number = _sceneScale?_sceneScale.numericalValue:1;
				translate = new Vector.<Number>();
				output = new Vector.<Number>();
				var readyTraits:Vector.<I2dTo3dTrait> = new Vector.<I2dTo3dTrait>();
				for(i=0; i<invalid2dList.length; ++i){
					pos2d = invalid2dList[i];
					validatePos(pos2d,sceneScale);
					
				}
			}
		}
		
		private function validatePos(pos2d:I2dTo3dTrait,sceneScale:Number):void
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
			
			var x3d:Number = (ray.x + ( camPos.x - ray.x ) * m) / sceneScale;
			var y3d:Number = (ray.y + ( camPos.y - ray.y ) * m) / sceneScale;
			var z3d:Number = (ray.z + ( camPos.z - ray.z ) * m) / sceneScale;
			
			
			if(_sceneTransform){
				var vec:Vector3D = new Vector3D(x3d,y3d,z3d);
				vec = _sceneTransform.invMatrix3d.transformVector(vec);
				
				x3d = vec.x;
				y3d = vec.y;
				z3d = vec.z;
			}
			
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
		
		
		private function onSceneTransformChanged(from:IMatrix3dTrait):void{
			invalidateAll();
		}
		private function onSceneScaleChanged(from:INumberProvider):void{
			invalidateAll();
		}
		private function onCameraChanged(... params):void{
			invalidateAll();
		}
	}
}