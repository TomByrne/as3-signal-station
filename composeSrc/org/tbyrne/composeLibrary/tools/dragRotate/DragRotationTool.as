package org.tbyrne.composeLibrary.tools.dragRotate
{
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.controls.ICameraControls;
	import org.tbyrne.composeLibrary.display2D.types.IPosition2dTrait;
	import org.tbyrne.composeLibrary.display3D.types.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.draw.types.IFrameAwareTrait;
	import org.tbyrne.composeLibrary.ui.types.IMouseActsTrait;
	
	public class DragRotationTool extends AbstractTrait implements IFrameAwareTrait
	{
		public function get centerPos():IPosition2dTrait{
			return _centerPos;
		}
		public function set centerPos(value:IPosition2dTrait):void{
			if(_centerPos!=value){
				_centerPos = value;
			}
		}
		
		public function get matrix():IMatrix3dTrait{
			return _matrix;
		}
		public function set matrix(value:IMatrix3dTrait):void{
			if(_matrix!=value){
				_matrix = value;
			}
		}
		
		public function get cameraControls():ICameraControls{
			return _cameraControls;
		}
		public function set cameraControls(value:ICameraControls):void{
			if(_cameraControls!=value){
				_cameraControls = value;
			}
		}
		
		
		public function get allowRoll():Boolean{
			return _allowRoll;
		}
		public function set allowRoll(value:Boolean):void{
			if(_allowRoll!=value){
				_allowRoll = value;
			}
		}
		
		private var _allowRoll:Boolean;
		
		private var _cameraControls:ICameraControls;
		private var _matrix:IMatrix3dTrait;
		private var _centerPos:IPosition2dTrait;
		private var _width:Number;
		private var _height:Number;
		private var _dragRadius:Number;
		
		private var _startVector:Vector3D = new Vector3D();
		private var _dragVector:Vector3D = new Vector3D();
		
		private var _dragQuat:Vector3D = new Vector3D();
		
		private var _startComps:Vector.<Vector3D>;
		private var _dummyComps:Vector.<Vector3D>;
		private var _dummyMatrix:Matrix3D = new Matrix3D();
		
		public function DragRotationTool(cameraControls:ICameraControls=null, matrix:IMatrix3dTrait=null, centerPos:IPosition2dTrait=null){
			super();
			
			this.cameraControls = cameraControls;
			this.matrix = matrix;
			this.centerPos = centerPos;
			
			addConcern(new Concern(true,true,false,IMouseActsTrait));
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var mouseActs:IMouseActsTrait = (trait as IMouseActsTrait);
			
			if(mouseActs){
				mouseActs.mouseDragStart.addHandler(onDragStart);
				mouseActs.mouseDrag.addHandler(onDrag);
				mouseActs.mouseDragFinish.addHandler(onDragStop);
			}
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var mouseActs:IMouseActsTrait = (trait as IMouseActsTrait);
			
			if(mouseActs){
				mouseActs.mouseDragStart.removeHandler(onDragStart);
				mouseActs.mouseDrag.removeHandler(onDrag);
				mouseActs.mouseDragFinish.removeHandler(onDragStop);
			}
		}
		
		
		private function onDragStart(from:IMouseActsTrait, info:IMouseActInfo):void{
			_startVector = coordinate2DToSphere(info.screenX,info.screenY,_startVector);
			startDragThis(_startVector);
			//canDrag=true;
		}
		private function onDrag(from:IMouseActsTrait, info:IMouseActInfo, byX:Number, byY:Number):void{
			_dragVector = coordinate2DToSphere(info.screenX,info.screenY,_dragVector);
			dragTo(_dragVector);
		}
		private function onDragStop(from:IMouseActsTrait, info:IMouseActInfo):void{
			//canDrag=false;
		}
		
		
		public function setSize(width:Number, height:Number):void{
			_width = width;
			_height = height;
			_dragRadius = Math.sqrt(_width*_width+_height*_height);
		}
		
		
		protected function startDragThis(vector3D:Vector3D):void
		{
			
			_startComps = _matrix.matrix3d.decompose(Orientation3D.EULER_ANGLES);
			
			_dummyMatrix.identity();
			_dummyComps = _dummyMatrix.decompose(Orientation3D.QUATERNION);
			
			_dragQuat = _dummyComps[1];
			_dragQuat.x = _dragQuat.y = _dragQuat.z = _dragQuat.w = 0;
		}
		protected function dragTo(vector:Vector3D):void
		{
			var v:Vector3D = _startVector.crossProduct(_dragVector);
			_dragQuat.x = v.x;
			_dragQuat.y = v.y;
			_dragQuat.z = v.z;
			_dragQuat.w = _startVector.dotProduct(_dragVector);
			//multiplyQuats(_dragQuat, _startQuat, _newQuat);
			//_transformComponents[1] = _newQuat;
			//_matrix.matrix3d.recompose(_transformComponents, Orientation3D.QUATERNION);
			//_matrix.matrix3dChanged.perform(_matrix);
			
			_dummyMatrix.recompose(_dummyComps, Orientation3D.QUATERNION);
			var eular:Vector.<Vector3D> = _dummyMatrix.decompose();
			var rots:Vector3D = eular[1];
			
			var startRot:Vector3D = _startComps[1];
			trace("\ndra: "+(rots.x*180/Math.PI),(rots.y*180/Math.PI),(rots.z*180/Math.PI));
			_cameraControls.rotX = (startRot.x+rots.x)*180/Math.PI;
			_cameraControls.rotY = (startRot.y+rots.y)*180/Math.PI;
			_cameraControls.rotZ = (startRot.z+rots.z)*180/Math.PI;
		}
		protected function coordinate2DToSphere(x:Number, y:Number, targetVector:Vector3D):Vector3D{
			
			var centerX:Number;
			var centerY:Number;
			if(_centerPos){
				centerX = _centerPos.x2d;
				centerY = _centerPos.y2d;
			}else{
				centerX = _width/2;
				centerY = _height/2;
			}
			targetVector.x = -(centerX-x)/_dragRadius;
			targetVector.y = (centerY-y)/_dragRadius;
			targetVector.z = 0;
			if(targetVector.lengthSquared > 1){
				targetVector.normalize();
			}else{
				targetVector.z = Math.sqrt(1-targetVector.lengthSquared);
			}
			return targetVector;
			
		}
		public  function multiplyQuats(q1:Vector3D, q2:Vector3D, out:Vector3D):void
		{
			out.x = q1.w*q2.x+q1.x*q2.w+q1.y*q2.z-q1.z*q2.y;
			out.y = q1.w*q2.y+q1.y*q2.w+q1.z*q2.x-q1.x*q2.z;
			out.z = q1.w*q2.z+q1.z*q2.w+q1.x*q2.y-q1.y*q2.x;
			out.w = q1.w*q2.w-q1.x*q2.x-q1.y*q2.y-q1.z*q2.z;
		}
	}
}