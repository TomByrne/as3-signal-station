package org.tbyrne.composeLibrary.away3d
{
	import away3d.cameras.Camera3D;
	
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.display3D.I3dTo2dTrait;
	import org.tbyrne.composeLibrary.types.display3D.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.types.draw.IDrawAwareTrait;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class Away3dProjector extends AbstractTrait implements IDrawAwareTrait
	{
		private const DUMMY_VECTOR:Vector3D = new Vector3D();
		
		
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
		
		private var _3dPositions:IndexedList;
		private var _3dInvalid:IndexedList;
		private var _3dAllInvalid:Boolean;
		
		public function Away3dProjector(camera:Camera3D=null, cameraChanged:IAct=null){
			super();
			
			_3dPositions = new IndexedList();
			_3dInvalid = new IndexedList();
			
			addConcern(new TraitConcern(false,true,I3dTo2dTrait,[I3dTo2dTrait]));
			
			this.cameraChanged = cameraChanged;
			this.camera = camera;
		}
		
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var trait3d:I3dTo2dTrait;
			
			if(trait3d = (trait as I3dTo2dTrait)){ 
				_3dPositions.push(trait3d);
				trait3d.requestProjection.addHandler(on3dPositionChanged);
				if(!_3dAllInvalid)_3dInvalid.push(trait3d);
				
			}
		}
		
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
			var trait3d:I3dTo2dTrait;
			
			if(trait3d = (trait as I3dTo2dTrait)){ 
				_3dPositions.remove(trait3d);
				_3dInvalid.remove(trait3d);
				trait3d.requestProjection.removeHandler(on3dPositionChanged);
				//trait3d.setProjectedPoint(NaN,NaN,NaN,true);
				
			}
		}
		
		protected function on3dPositionChanged(from:I3dTo2dTrait):void{
			if(!_3dAllInvalid && !_3dInvalid.containsItem(from))_3dInvalid.push(from);
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
			
			if(invalid3dList && _camera && _camera.lens){
				for(i=0; i<invalid3dList.length; ++i){
					pos3d = invalid3dList[i];
					if(!isNaN(pos3d.x3d) && !isNaN(pos3d.y3d) && !isNaN(pos3d.z3d)){
						DUMMY_VECTOR.x = pos3d.x3d;
						DUMMY_VECTOR.y = pos3d.y3d;
						DUMMY_VECTOR.z = pos3d.z3d;
						
						var v : Vector3D = _camera.lens.matrix.transformVector(DUMMY_VECTOR);
						pos3d.setProjectedPoint(v.x/v.w, -v.y/v.w, 1/v.w, v.z);
					}
				}
			}
		}
		
		private function onCameraChanged(... params):void{
			invalidateAll();
		}
	}
}