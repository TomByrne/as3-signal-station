package org.tbyrne.tbyrne.composeLibrary.away3d
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.math.*;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.primitives.Cube;
	
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	
	import org.tbyrne.tbyrne.composeLibrary.display2D.LayeredDisplayTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.display3D.IMatrix3dTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.draw.IDrawAwareTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.draw.IFrameAwareTrait;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.display.validation.ValidationFlag;
	
	public class Away3dDisplay extends LayeredDisplayTrait implements IFrameAwareTrait, IDrawAwareTrait
	{
		private static const RADS_TO_DEGS:Number = 180/Math.PI;
		
		public function get matrix3dTrait():IMatrix3dTrait{
			return _matrix3dTrait;
		}
		public function set matrix3dTrait(value:IMatrix3dTrait):void{
			if(_matrix3dTrait!=value){
				if(_matrix3dTrait){
					_matrix3dTrait.matrix3dChanged.removeHandler(onMatrixChanged);
				}
				_matrix3dTrait = value;
				if(_matrix3dTrait){
					_matrix3dTrait.matrix3dChanged.addHandler(onMatrixChanged);
				}
				onMatrixChanged();
			}
		}
		
		public function get focalLength():INumberProvider{
			return _focalLength;
		}
		public function set focalLength(value:INumberProvider):void{
			if(_focalLength!=value){
				if(_focalLength){
					_focalLength.numericalValueChanged.removeHandler(onFocalLengthChanged);
				}
				_focalLength = value;
				if(_focalLength){
					_focalLength.numericalValueChanged.addHandler(onFocalLengthChanged);
				}
				onFocalLengthChanged();
			}
		}
		
		private var _focalLength:INumberProvider;
		private var _matrix3dTrait:IMatrix3dTrait;
		
		private var _height:Number;
		
		private var _scene:Scene3D;
		private var _camera:Camera3D;
		private var _view:View3D;
		
		private var _focalLengthFlag:ValidationFlag;
		private var _matrixFlag:ValidationFlag;
		private var _renderFlag:ValidationFlag;
		
		private var _perspectiveLens:PerspectiveLens;
		private var _orthogonalLens:OrthographicLens;
		
		public function Away3dDisplay(layerId:String=null)
		{
			_view = new View3D();
			//_view.clipping = new FrustumClipping({minZ:10});
			
			_scene = _view.scene;
			
			_camera = _view.camera;
			//_camera.fixedZoom = false;
			//_camera.zoom = 1;
			_perspectiveLens = _camera.lens as PerspectiveLens;
			_orthogonalLens = new OrthographicLens();
			_camera.lens = _orthogonalLens;
			
			super(_view, layerId);
			
			var material:MaterialBase = new ColorMaterial(0xff0000);
			
			var cube:Cube = new Cube(material,300,300,300);
			var cont:ObjectContainer3D = new ObjectContainer3D();
			cont.addChild(cube);
			_scene.addChild(cont);
			
			var light:DirectionalLight = new DirectionalLight();
			light.direction = new Vector3D(-1, -1, 1);
			//light.ambient = 0.2;
			
			material.lights = [light];
			
			_scene.addChild(light);
			
			_focalLengthFlag = new ValidationFlag(commitFocalLength,false);
			_matrixFlag = new ValidationFlag(commitMatrix,false);
			_renderFlag = new ValidationFlag(_view.render,false);
		}		
		
		public function setSize(width:Number, height:Number):void{
			_height = height;
			_view.width = width;
			_view.height = height;
			_orthogonalLens.projectionHeight = height;
			_focalLengthFlag.validate();
			_renderFlag.invalidate();
		}
		public function tick(timeStep:Number):void{
			_focalLengthFlag.validate();
			_matrixFlag.validate();
			_renderFlag.validate();
		}
		
		protected function onMatrixChanged(from:IMatrix3dTrait=null):void{
			_matrixFlag.invalidate();
			_renderFlag.invalidate();
		}
		protected function onFocalLengthChanged(from:INumberProvider=null):void{
			_focalLengthFlag.invalidate();
			_renderFlag.invalidate();
		}
		protected function commitMatrix():void{
			_camera.transform = _matrix3dTrait?_matrix3dTrait.matrix3d:null;
		}
		protected function commitFocalLength():void{
			var focalLength:Number = _focalLength.numericalValue;
			if(isNaN(focalLength) || focalLength==Number.NEGATIVE_INFINITY || focalLength==Number.POSITIVE_INFINITY){
				_camera.lens = _orthogonalLens;
			}else{
				_perspectiveLens.fieldOfView = (2*Math.atan((_height/2) / focalLength))*RADS_TO_DEGS;
				_camera.lens = _perspectiveLens;
			}
		}
	}
}