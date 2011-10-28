
package org.tbyrne.composeLibrary.away3d
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.math.*;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.primitives.Cube;
	
	import org.tbyrne.binding.Binder;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	import org.tbyrne.composeLibrary.away3d.types.IContainer3dTrait;
	import org.tbyrne.composeLibrary.away3d.types.IScene3dAwareTrait;
	import org.tbyrne.composeLibrary.display2D.LayeredDisplayTrait;
	import org.tbyrne.composeLibrary.types.display3D.ICameraDistanceAwareTrait;
	import org.tbyrne.composeLibrary.types.display3D.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.types.draw.IDrawAwareTrait;
	import org.tbyrne.composeLibrary.types.draw.IFrameAwareTrait;
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
		public function get backgroundColour():INumberProvider{
			return _backgroundColour;
		}
		public function set backgroundColour(value:INumberProvider):void{
			if(_backgroundColour!=value){
				if(_backgroundColour){
					_backgroundColour.numericalValueChanged.removeHandler(onBackgroundColourChanged);
				}
				_backgroundColour = value;
				if(_backgroundColour){
					_backgroundColour.numericalValueChanged.addHandler(onBackgroundColourChanged);
				}
				onBackgroundColourChanged();
			}
		}
		public function get backgroundAlpha():INumberProvider{
			return _backgroundAlpha;
		}
		public function set backgroundAlpha(value:INumberProvider):void{
			if(_backgroundAlpha!=value){
				if(_backgroundAlpha){
					_backgroundAlpha.numericalValueChanged.removeHandler(onBackgroundAlphaChanged);
				}
				_backgroundAlpha = value;
				if(_backgroundAlpha){
					_backgroundAlpha.numericalValueChanged.addHandler(onBackgroundAlphaChanged);
				}
				onBackgroundAlphaChanged();
			}
		}
		
		public function get cameraZOffset():INumberProvider{
			return _cameraZOffset;
		}
		public function set cameraZOffset(value:INumberProvider):void{
			if(_cameraZOffset!=value){
				_cameraZOffset = value;
				if(_cameraZOffset){
					Binder.bind(_camera,"z",value,"numericalValue");
				}else{
					Binder.unbind(_camera,"z");
				}
			}
		}
		
		public function get sceneScale():INumberProvider{
			return _sceneScale;
		}
		public function set sceneScale(value:INumberProvider):void{
			if(_sceneScale!=value){
				if(_sceneScale){
					_sceneScale.numericalValueChanged.removeHandler(onSceneScaleChanged);
				}
				_sceneScale = value;
				if(_sceneScale){
					_sceneScale.numericalValueChanged.addHandler(onSceneScaleChanged);
					onSceneScaleChanged(_sceneScale);
				}else{
					_camera.scaleX = 1;
					_camera.scaleY = 1;
					_camera.scaleZ = 1;
				}
			}
		}
		
		public function get view3D():View3D{
			return _view;
		}
		
		private var _sceneScale:INumberProvider;
		private var _cameraZOffset:INumberProvider;
		private var _backgroundAlpha:INumberProvider;
		private var _backgroundColour:INumberProvider;
		
		private var _focalLength:INumberProvider;
		private var _matrix3dTrait:IMatrix3dTrait;
		
		private var _height:Number;
		
		private var _camDistAwareTraits:IndexedList = new IndexedList();
		
		private var _scene:Scene3D;
		private var _sceneProxy:Away3dSceneProxy;
		private var _camera:Camera3D;
		private var _cameraContainer:ObjectContainer3D;
		private var _view:View3D;
		private var _lights:Array;
		
		private var _focalLengthFlag:ValidationFlag;
		private var _matrixFlag:ValidationFlag;
		private var _renderFlag:ValidationFlag;
		
		private var _perspectiveLens:PerspectiveLens;
		private var _orthogonalLens:OrthographicLens;
		
		public function Away3dDisplay(layerId:String=null)
		{
			_view = new View3D();
			_view.antiAlias = 2;
			_view.visible = false;
			_view.backgroundAlpha = 0;
			//_view.clipping = new FrustumClipping({minZ:10});
			
			_scene = _view.scene;
			_sceneProxy = new Away3dSceneProxy(_scene);
			
			_cameraContainer = new ObjectContainer3D();
			_scene.addChild(_cameraContainer);
			
			_camera = _view.camera;
			_camera.z = 0;
			//_scene.removeChild(_camera);
			_cameraContainer.addChild(_camera);
			
			//_camera.fixedZoom = false;
			//_camera.zoom = 1;
			_perspectiveLens = _camera.lens as PerspectiveLens;
			_orthogonalLens = new OrthographicLens();
			_orthogonalLens.far = 30000;
			_camera.lens = _orthogonalLens;
			
			super(_view, layerId);
			
			/*var material:MaterialBase = new ColorMaterial(0xff0000);
			var cube:Cube = new Cube(material,100,100,100);
			var cont:ObjectContainer3D = new ObjectContainer3D();
			cont.addChild(cube);
			_scene.addChild(cont);*/
			
			
			_focalLengthFlag = new ValidationFlag(commitFocalLength,false);
			_matrixFlag = new ValidationFlag(commitMatrix,false);
			_renderFlag = new ValidationFlag(_view.render,false);
			
			addConcern(new TraitConcern(true,true,IScene3dAwareTrait));
			addConcern(new TraitConcern(true,true,IChild3dTrait,[IContainer3dTrait]));
			addConcern(new TraitConcern(true,true,ICameraDistanceAwareTrait));
		}
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var awareTrait:IScene3dAwareTrait;
			var child3d:IChild3dTrait;
			var cameraDistanceAware:ICameraDistanceAwareTrait;
			
			if(awareTrait = (trait as IScene3dAwareTrait)){
				awareTrait.scene3d = _sceneProxy;
			}else if(child3d = (trait as IChild3dTrait)){
				_scene.addChild(child3d.object3d);
			}else if(cameraDistanceAware = (trait as ICameraDistanceAwareTrait)){
				_camDistAwareTraits.push(cameraDistanceAware);
			}
		}
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
			var awareTrait:IScene3dAwareTrait;
			var child3d:IChild3dTrait;
			var cameraDistanceAware:ICameraDistanceAwareTrait;
			
			if(awareTrait = (trait as IScene3dAwareTrait)){
				awareTrait.scene3d = null;
			}else if(child3d = (trait as IChild3dTrait)){
				if(_scene.contains(child3d.object3d))
					_scene.removeChild(child3d.object3d);
			}else if(cameraDistanceAware = (trait as ICameraDistanceAwareTrait)){
				_camDistAwareTraits.remove(cameraDistanceAware);
			}
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
			_renderFlag.validate(true);
			
			for each(var camAware:ICameraDistanceAwareTrait in _camDistAwareTraits){
				// if a more accurate equation is needed, check out this http://away3d.com/forum/viewthread/1053/
				var objTrait:IChild3dTrait = camAware.item.getTrait(IChild3dTrait);
				camAware.cameraDistance = objTrait.object3d.scenePosition.subtract(_camera.scenePosition).length;
				trace(camAware.cameraDistance);
			}
		}
		
		protected function onMatrixChanged(from:IMatrix3dTrait=null):void{
			_matrixFlag.invalidate();
			_renderFlag.invalidate();
		}
		protected function onFocalLengthChanged(from:INumberProvider=null):void{
			_focalLengthFlag.invalidate();
			_renderFlag.invalidate();
		}
		
		protected function onBackgroundColourChanged(from:INumberProvider=null):void{
			_view.backgroundColor = _backgroundColour?_backgroundColour.numericalValue:0;
			_renderFlag.invalidate();
		}
		protected function onBackgroundAlphaChanged(from:INumberProvider=null):void{
			_view.backgroundAlpha = _backgroundAlpha?_backgroundAlpha.numericalValue:1;
			_renderFlag.invalidate();
		}
		protected function commitMatrix():void{
			_cameraContainer.transform = _matrix3dTrait?_matrix3dTrait.matrix3d:null;
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
		
		private function onSceneScaleChanged(from:INumberProvider):void
		{
			var scale:Number = 1/from.numericalValue;
			_camera.scaleX = scale;
			_camera.scaleY = scale;
			_camera.scaleZ = scale;
		}
	}
}