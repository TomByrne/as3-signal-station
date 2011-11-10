
package org.tbyrne.composeLibrary.away3d
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.math.*;
	import away3d.entities.Sprite3D;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.binding.Binder;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.core.ComposeGroup;
	import org.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.away3d.materials.SpriteMaterial;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	import org.tbyrne.composeLibrary.away3d.types.IContainer3dTrait;
	import org.tbyrne.composeLibrary.display2D.AbstractLayeredContainer;
	import org.tbyrne.composeLibrary.display2D.LayeredDisplayTrait;
	import org.tbyrne.composeLibrary.display2D.types.IDisplayObjectTrait;
	import org.tbyrne.composeLibrary.display2D.types.ILayeredDisplayTrait;
	import org.tbyrne.composeLibrary.display3D.types.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.draw.types.IDrawAwareTrait;
	import org.tbyrne.composeLibrary.draw.types.IFrameAwareTrait;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.display.validation.ValidationFlag;
	
	public class Away3dDisplay extends AbstractLayeredContainer implements IFrameAwareTrait, IDrawAwareTrait
	{
		static public const THREE_D_LAYER:String = "3dLayer";
		
		
		private static const RADS_TO_DEGS:Number = 180/Math.PI;
		
		
		/**
		 * handler(from:Away3dDisplay)
		 */
		public function get cameraChanged():IAct{
			return (_cameraChanged || (_cameraChanged = new Act()));
		}
		
		protected var _cameraChanged:Act;
		
		
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
					_sceneContainer.scaleX = 1;
					_sceneContainer.scaleY = 1;
					_sceneContainer.scaleZ = 1;
				}
			}
		}
		
		
		public function get farDist():INumberProvider{
			return _farDist;
		}
		public function set farDist(value:INumberProvider):void{
			if(_farDist!=value){
				if(_farDist){
					_farDist.numericalValueChanged.removeHandler(onFarChanged);
				}
				_farDist = value;
				if(_farDist){
					_farDist.numericalValueChanged.addHandler(onFarChanged);
					Binder.bind(_perspectiveLens,"far",_farDist,"numericalValue");
					Binder.bind(_orthogonalLens,"far",_farDist,"numericalValue");
					onFarChanged();
				}else{
					Binder.unbind(_perspectiveLens,"far");
					Binder.unbind(_orthogonalLens,"far");
				}
			}
		}
		
		public function get nearDist():INumberProvider{
			return _nearDist;
		}
		public function set nearDist(value:INumberProvider):void{
			if(_nearDist!=value){
				_nearDist = value;
				if(_nearDist){
					Binder.bind(_perspectiveLens,"near",_nearDist,"numericalValue");
					Binder.bind(_orthogonalLens,"near",_nearDist,"numericalValue");
				}else{
					Binder.unbind(_perspectiveLens,"near");
					Binder.unbind(_orthogonalLens,"near");
				}
			}
		}
		
		
		public function get rootDisplay():DisplayObject{
			return _rootDisplay;
		}
		
		public function get view3D():View3D{
			return _view;
		}
		
		private var _sceneScale:INumberProvider;
		private var _cameraZOffset:INumberProvider;
		private var _backgroundColour:INumberProvider;
		
		private var _focalLength:INumberProvider;
		private var _matrix3dTrait:IMatrix3dTrait;
		
		private var _height:Number;
		
		private var _camDistAwareTraits:IndexedList = new IndexedList();
		
		private var _scene:Scene3D;
		private var _sceneContainer:ObjectContainer3D;
		private var _camera:Camera3D;
		private var _view:View3D;
		private var _lights:Array;
		
		private var _focalLengthFlag:ValidationFlag;
		private var _matrixFlag:ValidationFlag;
		private var _renderFlag:ValidationFlag;
		private var _lowerScaleFlag:ValidationFlag;
		
		private var _rootDisplay:Sprite;
		private var _viewLayerItem:ComposeItem;
		private var _upperContainer:Sprite;
		private var _lowerContainer:MovieClip;
		//private var _lowerContainerShape:Shape;
		private var _lowerContainer3D:Sprite3D;
		
		private var _perspectiveLens:PerspectiveLens;
		private var _orthogonalLens:OrthographicLens;
		private var _lowerMaterial:SpriteMaterial;
		
		private var _nearDist:INumberProvider;
		private var _farDist:INumberProvider;

		private var _lowerShape:Shape;
		
		public function Away3dDisplay()
		{
			_rootDisplay = new Sprite();
			
			_view = new View3D();
			_view.antiAlias = 2;
			_view.backgroundAlpha = 0;
			_rootDisplay.addChild(_view);
			
			_scene = _view.scene;
			
			_sceneContainer = new ObjectContainer3D();
			_scene.addChild(_sceneContainer);
			
			_camera = _view.camera;
			_camera.z = 0;
			
			_perspectiveLens = _camera.lens as PerspectiveLens;
			_orthogonalLens = new OrthographicLens();
			_camera.lens = _orthogonalLens;
			_scene.addChild(_camera);
			
			super();
			
			// this will add the View3D into the layer stack
			_viewLayerItem = new ComposeItem();
			_viewLayerItem.addTrait(new LayeredDisplayTrait(null,THREE_D_LAYER)); 
			
			
			_focalLengthFlag = new ValidationFlag(commitFocalLength,false);
			_matrixFlag = new ValidationFlag(commitMatrix,false);
			_renderFlag = new ValidationFlag(_view.render,false);
			_lowerScaleFlag = new ValidationFlag(commitLowerScale,false,null,readyCommitLower);
			
			addConcern(new Concern(true,true,false,IChild3dTrait,[IContainer3dTrait]));
		}
		
		override protected function onItemAdd():void{
			super.onItemAdd();
			(item as ComposeGroup).addItem(_viewLayerItem);
		}
		override protected function onItemRemove():void{
			super.onItemRemove();
			(item as ComposeGroup).removeItem(_viewLayerItem);
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var child3d:IChild3dTrait;
			var layeredDisplay:ILayeredDisplayTrait;
			
			if(child3d = (trait as IChild3dTrait)){
				_sceneContainer.addChild(child3d.object3d);
			}
			if(layeredDisplay = (trait as ILayeredDisplayTrait)){
				layeredDisplay.requestRedraw.addHandler(onRequestRedraw);
			}
			super.onConcernedTraitAdded(from, trait);
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var child3d:IChild3dTrait;
			var layeredDisplay:ILayeredDisplayTrait;
			
			if(child3d = (trait as IChild3dTrait)){
				if(_scene.contains(child3d.object3d))
					_scene.removeChild(child3d.object3d);
			}
			if(layeredDisplay = (trait as ILayeredDisplayTrait)){
				layeredDisplay.requestRedraw.removeHandler(onRequestRedraw);
			}
			super.onConcernedTraitRemoved(from, trait);
		}
		private function onRequestRedraw(from:ILayeredDisplayTrait):void{
			if(_lowerContainer && _lowerContainer.contains(from.displayObject)){
				checkLowerContainerDims();
				_lowerMaterial.redraw();
			}
		}
		
		public function setSize(width:Number, height:Number):void{
			if(_view.height!=height)_focalLengthFlag.invalidate();
			
			_height = height;
			_view.width = width;
			_view.height = height;
			
			if(_lowerContainer3D){
				checkLowerContainerDims();
				_lowerMaterial.redraw();
			}
			
			_orthogonalLens.projectionHeight = height;
			_focalLengthFlag.validate();
			_renderFlag.invalidate();
			_lowerScaleFlag.invalidate();
		}
		
		private function checkLowerContainerDims():void{
			if(_lowerContainer3D.width != _lowerContainer.width || _lowerContainer3D.height != _lowerContainer.height){
				_lowerContainer3D.width = _lowerContainer.width;
				_lowerContainer3D.height = _lowerContainer.height;
				
				_lowerShape.visible = false;
				var bounds:Rectangle = _lowerContainer.getBounds(_lowerContainer);
				_lowerShape.x = bounds.left;
				_lowerShape.y = bounds.top;
				_lowerShape.visible = true;
				
				_lowerMaterial.redraw();
			}
		}
		public function tick(timeStep:Number):void{
			render();
		}
		
		protected function onMatrixChanged(from:IMatrix3dTrait=null):void{
			_matrixFlag.invalidate();
			_renderFlag.invalidate();
			_lowerScaleFlag.invalidate();
		}
		protected function onFocalLengthChanged(from:INumberProvider=null):void{
			_focalLengthFlag.invalidate();
			_renderFlag.invalidate();
		}
		
		protected function onBackgroundColourChanged(from:INumberProvider=null):void{
			_view.backgroundColor = _backgroundColour?_backgroundColour.numericalValue:0;
			_renderFlag.invalidate();
		}
		
		protected function commitMatrix():void{
			_camera.transform = _matrix3dTrait?_matrix3dTrait.matrix3d:null;
			if(_cameraChanged)_cameraChanged.perform(this);
		}
		protected function commitFocalLength():void{
			var focalLength:Number = _focalLength.numericalValue;
			if(isNaN(focalLength) || focalLength==Number.NEGATIVE_INFINITY || focalLength==Number.POSITIVE_INFINITY){
				_camera.lens = _orthogonalLens;
			}else{
				_perspectiveLens.fieldOfView = (2*Math.atan((_height/2) / focalLength))*RADS_TO_DEGS;
				_camera.lens = _perspectiveLens;
			}
			if(_cameraChanged)_cameraChanged.perform(this);
		}
		public function render():void{
			_focalLengthFlag.validate();
			_matrixFlag.validate();
			_renderFlag.validate(true);
			_lowerScaleFlag.validate();
			if(_lowerContainer3D){
				checkLowerContainerDims();
			}
		}
		
		private function onSceneScaleChanged(from:INumberProvider):void{
			_sceneContainer.scaleX = from.numericalValue;
			_sceneContainer.scaleY = from.numericalValue;
			_sceneContainer.scaleZ = from.numericalValue;
		}
		
		
		private function commitLowerScale():void{
			var vector:Vector3D = new Vector3D(1,0,_camera.lens.far);
			vector = _view.camera.lens.matrix.transformVector(vector);
			var scale:Number = 1/((vector.x/vector.w)*_view.width/2.0);
			
			_lowerContainer3D.scaleX = scale;
			_lowerContainer3D.scaleY = scale;
			
			var bounds:Rectangle = _lowerContainer.getBounds(_lowerContainer);
			_lowerContainer3D.x = (bounds.left+_lowerContainer.width/2-_view.width/2)*scale;
			_lowerContainer3D.y = (-bounds.top-_lowerContainer.height/2+_view.height/2)*scale;
		}
		
		private function readyCommitLower(flag:ValidationFlag):Boolean{
			return _lowerContainer!=null;
		}
		
		protected function getThreeDDepth():int{
			if(_lowerContainer){
				return _lowerContainer.numChildren;
			}else{
				return 0;
			}
		}
		
		override protected function getLayerIndex(layer:ILayeredDisplayTrait):int{
			var threeDDepth:int = getThreeDDepth();
			if(layer.item==_viewLayerItem){
				return threeDDepth;
			}else if(_upperContainer && _upperContainer.contains(layer.displayObject)){
				return threeDDepth+_upperContainer.getChildIndex(layer.displayObject)+1;
			}else if(_lowerContainer && _lowerContainer.contains(layer.displayObject)){
				return _lowerContainer.getChildIndex(layer.displayObject);
			}else{
				return -1;
			}
		}
		override protected function setLayerIndex(layeredDisplayTrait:ILayeredDisplayTrait, depth:int):void{
			var i:int;
			var displayObject:DisplayObject;
			
			var currDepth:int = getLayerIndex(layeredDisplayTrait);
			if(depth==currDepth)return;
			
			var threeDDepth:int = getThreeDDepth();
			if(layeredDisplayTrait.item==_viewLayerItem){
				
				checkLowerContainer();
				
				var dif:int = depth-threeDDepth;
				if(dif>0){
					// move 3D up
					for(i=0; i<dif; ++i){
						displayObject = _upperContainer.removeChildAt(0);
						_lowerContainer.addChild(displayObject);
					}
				}else{
					// move 3D down
					for(i=0; i<dif; ++i){
						displayObject = _lowerContainer.removeChildAt(_lowerContainer.numChildren-1);
						_upperContainer.addChildAt(displayObject,0);
					}
				}
				checkLowerContainerDims();
				_lowerMaterial.redraw();
			}else if(depth>threeDDepth){
				checkUpperContainer();
				if(currDepth<threeDDepth){
					_lowerContainer.removeChild(layeredDisplayTrait.displayObject);
					_upperContainer.addChildAt(layeredDisplayTrait.displayObject,depth-threeDDepth-1);
					checkLowerContainerDims();
					_lowerMaterial.redraw();
				}else{
					_upperContainer.setChildIndex(layeredDisplayTrait.displayObject,depth-threeDDepth-1);
				}
			}else if(depth<threeDDepth){
				checkLowerContainer();
				if(currDepth>threeDDepth){
					_upperContainer.removeChild(layeredDisplayTrait.displayObject);
					_lowerContainer.addChildAt(layeredDisplayTrait.displayObject,depth);
				}else{
					_lowerContainer.setChildIndex(layeredDisplayTrait.displayObject,depth);
				}
				checkLowerContainerDims();
				_lowerMaterial.redraw();
			}
		}
		override protected function addLayerAt(layeredDisplayTrait:ILayeredDisplayTrait, addIndex:int):void{
			if(layeredDisplayTrait.item!=_viewLayerItem){
				var threeDDepth:int = getThreeDDepth();
				if(addIndex<=threeDDepth){
					checkLowerContainer();
					_lowerContainer.addChildAt(layeredDisplayTrait.displayObject,addIndex);
					checkLowerContainerDims();
					_lowerMaterial.redraw();
				}else{
					checkUpperContainer();
					_upperContainer.addChildAt(layeredDisplayTrait.displayObject,addIndex-threeDDepth-1);
				}
			}else{
				setLayerIndex(layeredDisplayTrait, addIndex);
			}
		}
		override protected function addDisplayTrait(displayTrait:IDisplayObjectTrait):void{
			if(displayTrait.item!=_viewLayerItem){
				checkUpperContainer();
				_upperContainer.addChild(displayTrait.displayObject);
			}
		}
		override protected function removeDisplayTrait(displayTrait:IDisplayObjectTrait, displayObject:DisplayObject):void{
			if(displayTrait.item!=_viewLayerItem){
				var cont:DisplayObjectContainer = displayObject.parent;
				cont.removeChild(displayObject);
				if(cont==_lowerContainer){
					checkLowerContainerDims();
					_lowerMaterial.redraw();
				}
			}
		}
		private function checkUpperContainer():void{
			if(!_upperContainer){
				_upperContainer = new Sprite();
				_rootDisplay.addChild(_upperContainer);
			}
		}
		private function checkLowerContainer():void{
			if(!_lowerContainer){
				_lowerContainer = new MovieClip();
				
				_lowerShape = new Shape();
				_lowerShape.graphics.beginFill(0,0);
				_lowerShape.graphics.drawRect(0,0,2,2);
				_lowerContainer.addChild(_lowerShape);
				
				_lowerMaterial = new SpriteMaterial(_lowerContainer);
				
				
				_lowerContainer3D = new Sprite3D(_lowerMaterial,100,100);
				_lowerContainer3D.mouseEnabled = true;
				_lowerContainer3D.z = _orthogonalLens.far-2;
				
				_camera.addChild(_lowerContainer3D);
				
				var vector:Vector3D = new Vector3D(0,0,_lowerContainer3D.z);
				vector = _view.camera.lens.matrix.transformVector(vector);
				_lowerContainer3D.scaleX = vector.w;
				_lowerContainer3D.scaleY = vector.w;
				
				_lowerScaleFlag.invalidate();
			}
		}
		
		private function onFarChanged(from:INumberProvider=null):void{
			if(_lowerContainer3D){
				_lowerContainer3D.z = _farDist.numericalValue-2;
			}
			_lowerScaleFlag.invalidate();
		}
	}
}	