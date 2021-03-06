package org.tbyrne.composeLibrary.away3d
{
	import away3d.containers.View3D;
	
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.display3D.types.I3dTo2dTrait;
	import org.tbyrne.composeLibrary.display3D.types.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.draw.types.IDrawAwareTrait;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class Away3dProjector extends AbstractTrait implements IDrawAwareTrait
	{
		private var DUMMY_VECTOR:Vector3D = new Vector3D();
		
		
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
		
		private var _3dPositions:IndexedList;
		private var _3dInvalid:IndexedList;
		private var _3dAllInvalid:Boolean;
		
		public function Away3dProjector(view:View3D=null, cameraChanged:IAct=null, sceneScale:INumberProvider=null){
			super();
			
			_3dPositions = new IndexedList();
			_3dInvalid = new IndexedList();
			
			addConcern(new Concern(false,true,false,I3dTo2dTrait));
			
			this.cameraChanged = cameraChanged;
			this.view = view;
			this.sceneScale = sceneScale;
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var trait3d:I3dTo2dTrait;
			
			if(trait3d = (trait as I3dTo2dTrait)){ 
				_3dPositions.add(trait3d);
				trait3d.requestProjection.addHandler(on3dPositionChanged);
				if(!_3dAllInvalid)_3dInvalid.add(trait3d);
				
			}
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var trait3d:I3dTo2dTrait;
			
			if(trait3d = (trait as I3dTo2dTrait)){ 
				_3dPositions.remove(trait3d);
				_3dInvalid.remove(trait3d);
				trait3d.requestProjection.removeHandler(on3dPositionChanged);
				//trait3d.setProjectedPoint(NaN,NaN,NaN,true);
				
			}
		}
		
		protected function on3dPositionChanged(from:I3dTo2dTrait, immediate:Boolean):void{
			if(immediate){
				validatePos(from,_sceneScale?_sceneScale.numericalValue:1);
				_3dInvalid.remove(from)
			}else{
				if(!_3dAllInvalid && !_3dInvalid.containsItem(from))_3dInvalid.add(from);
			}
		}
		
		protected function invalidateAll():void{
			if(!_3dAllInvalid){
				_3dAllInvalid = true;
				_3dInvalid.clear();
			}
		}
		
		
		
		
		public function tick(timeStep:Number):void{
			var i:int;
			var translate:Vector.<Number>;
			var output:Vector.<Number>;
			
			var pos3d:I3dTo2dTrait;
			
			var invalid3dList:Array;
			if(_3dAllInvalid){
				_3dAllInvalid = false;
				invalid3dList = _3dPositions.list;
			}else if(_3dInvalid.list.length){
				invalid3dList = _3dInvalid.list;
				_3dInvalid.clear();
			}
			var sceneScale:Number = _sceneScale?_sceneScale.numericalValue:1;
			
			if(invalid3dList && _view && _view.camera.lens){
				
				for(i=0; i<invalid3dList.length; ++i){
					pos3d = invalid3dList[i];
					validatePos(pos3d,sceneScale);
				}
			}
		}
		
		private function validatePos(pos3d:I3dTo2dTrait,sceneScale:Number):void{
			if(!isNaN(pos3d.x3d) && !isNaN(pos3d.y3d) && !isNaN(pos3d.z3d)){
				
				DUMMY_VECTOR.x = pos3d.x3d;
				DUMMY_VECTOR.y = pos3d.y3d;
				DUMMY_VECTOR.z = pos3d.z3d;
				
				//var test:Point = _view.project(DUMMY_VECTOR);
				
				if(_sceneTransform){
					DUMMY_VECTOR = _sceneTransform.matrix3d.transformVector(DUMMY_VECTOR);
				}
				
				DUMMY_VECTOR.x *= sceneScale;
				DUMMY_VECTOR.y *= sceneScale;
				DUMMY_VECTOR.z *= sceneScale;
				
				var cameraPos:Vector3D = _view.camera.inverseSceneTransform.transformVector(DUMMY_VECTOR);
				var v : Vector3D = _view.camera.lens.matrix.transformVector(cameraPos);
				var x:Number = ((v.x/v.w) + 1.0)*_view.width/2.0;
				var y:Number = ((-v.y/v.w) + 1.0)*_view.height/2.0;
				var z:Number = cameraPos.z;
				
				
				pos3d.setProjectedPoint(x, y, 1/v.w, z);
			}
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