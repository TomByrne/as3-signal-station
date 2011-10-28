package org.tbyrne.composeLibrary.away3d
{
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.IRenderable;
	import away3d.core.base.SubMesh;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.render.HitTestRenderer;
	import away3d.core.traverse.EntityCollector;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	import org.tbyrne.composeLibrary.types.display2D.IHitTestTrait;
	
	use namespace arcane;
	
	public class Away3dHitTester extends AbstractTrait implements IHitTestTrait
	{
		
		public function get view3D():View3D{
			return _view3D;
		}
		public function set view3D(value:View3D):void{
			if(_view3D!=value){
				if(_view3D){
					_hitTestRenderer.dispose();
					_hitTestRenderer = null;
					_view3D.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				}
				_view3D = value;
				if(value){
					_hitTestRenderer = new HitTestRenderer(value);
					_hitTestRenderer.stage3DProxy = _view3D.stage3DProxy;
					_view3D.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				}
			}
		}
		
		private var _view3D:View3D;
		private var _hitTestRenderer : HitTestRenderer;
		
		private var _lastScreenX:Number;
		private var _lastScreenY:Number;
		private var _lastViewX:Number;
		private var _lastViewY:Number;
		
		
		public function Away3dHitTester(view3D:View3D){
			super();
			
			this.view3D = view3D;
		}
		
		protected function onAddedToStage(event:Event):void{
			_hitTestRenderer.stage3DProxy = _view3D.stage3DProxy;
		}
		
		public function hitTest(trait:ITrait, screenX:Number, screenY:Number):Boolean{
			var childTrait:IChild3dTrait = (trait as IChild3dTrait) || trait.item.getTrait(IChild3dTrait);
			var object3d:ObjectContainer3D;
			if(childTrait && (object3d = childTrait.object3d)){
				var collector : EntityCollector = _view3D.entityCollector;
				
				if(_lastScreenX!=screenX || _lastScreenY!=screenY || _lastViewX!=_view3D.x || _lastViewY!=_view3D.y){
					_lastScreenX = screenX;
					_lastScreenY = screenY;
					_lastViewX = _view3D.x;
					_lastViewY = _view3D.y;
					
					var localPoint:Point = _view3D.globalToLocal(new Point(screenX,screenY));
					_hitTestRenderer.update((localPoint.x/_view3D.width), (localPoint.y/_view3D.height), collector);
				}
				
				var subMesh:SubMesh = _hitTestRenderer.hitRenderable as SubMesh;
				if(subMesh){
					var hitObject3D:ObjectContainer3D = subMesh.parentMesh;
					do{
						if(hitObject3D==object3d)return true;
						hitObject3D = hitObject3D.parent;
					}while(hitObject3D)
				}
			}
			return false;
		}
	}
}