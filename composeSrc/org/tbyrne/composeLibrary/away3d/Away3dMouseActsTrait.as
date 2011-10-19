package org.tbyrne.composeLibrary.away3d
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.events.MouseEvent3D;
	
	import flash.utils.getTimer;
	
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	import org.tbyrne.composeLibrary.ui.AbstractMouseActsTraits;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeAssets.actInfo.MouseActInfo;
	
	public class Away3dMouseActsTrait extends AbstractMouseActsTraits 
	{
		
		public static const DEFAULT_DRAG_THRESHOLD:uint = 5;
		public static const DEFAULT_CLICK_SPEED:Number = 0.25;
		
		
		
		
		public function get dragTreshold():uint{
			return _dragTreshold;
		}
		public function set dragTreshold(value:uint):void{
			//if(_dragTreshold!=value){
			_dragTreshold = value;
			//}
		}
		
		public function get clickSpeed():Number{
			return _clickSpeed;
		}
		public function set clickSpeed(value:Number):void{
			//if(_clickSpeed!=value){
			_clickSpeed = value;
			_clickSpeedMS = value*1000
			//}
		}
		
		private var _clickSpeed:Number;
		private var _clickSpeedMS:int;
		private var _dragTreshold:uint;
		//private var _away3dObjectTrait:IInteractiveObjectTrait;
		//private var _interactiveObject:InteractiveObject;
		private var _away3dObjectTrait:IChild3dTrait;
		private var _object3d:ObjectContainer3D;
		
		private var _clickBegan:int;
		private var _isDragging:Boolean;
		private var _dragX:int;
		private var _dragY:int;
		private var _scene:Scene3D;
		
		
		public function Away3dMouseActsTrait(){
			super();
			
			dragTreshold = DEFAULT_DRAG_THRESHOLD;
			clickSpeed = DEFAULT_CLICK_SPEED;
			
			addConcern(new TraitConcern(true,false,IChild3dTrait));
		}
		
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			if(_away3dObjectTrait)return;
			
			_away3dObjectTrait = trait as IChild3dTrait;
			//_away3dObjectTrait.interactiveObjectChanged.addHandler(onInteractiveObjectChanged);
			setObjectContainer3d(_away3dObjectTrait.object3d);
		}
		
		private function setObjectContainer3d(object3d:ObjectContainer3D):void
		{
			if(_object3d!=object3d){
				if(_object3d){
					_object3d.removeEventListener(MouseEvent3D.MOUSE_OVER, onMouseOver);
					_object3d.removeEventListener(MouseEvent3D.MOUSE_OUT, onMouseOut);
					_object3d.removeEventListener(MouseEvent3D.MOUSE_MOVE, onMouseMove);
					
					_object3d.removeEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
				}
				
				_object3d = object3d;
				
				if(_object3d){
					_object3d.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOver);
					_object3d.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOut);
					_object3d.addEventListener(MouseEvent3D.MOUSE_MOVE, onMouseMove);
					
					_object3d.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
				}
			}
		}
		
		
		/*private function onInteractiveObjectChanged(from:IAway3dObjectTrait):void{
			setInteractiveObject(from.object3d);
		}*/
		
		
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
			if(trait != _away3dObjectTrait){
				return;
			}
			if(_mouseIsDown.booleanValue){
				
				_mouseIsDown.booleanValue = false;
				
				_scene.removeEventListener(MouseEvent3D.MOUSE_MOVE, onDownMove);
				_scene.removeEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
				_scene = null;
				
				if(_isDragging){
					_isDragging = false;
					if(_mouseDragFinish)_mouseDragFinish.perform(this);
				}
			}
			_mouseIsOver.booleanValue = false;
			
			setObjectContainer3d(null);
			
			//_away3dObjectTrait.interactiveObjectChanged.removeHandler(onInteractiveObjectChanged);
			_away3dObjectTrait = null;
		}
		
		protected function onMouseOver(event:MouseEvent3D):void{
			_mouseIsOver.booleanValue = true;
		}
		
		protected function onMouseOut(event:MouseEvent3D):void{
			_mouseIsOver.booleanValue = false;
		}
		
		protected function onMouseMove(event:MouseEvent3D):void{
			if(_mouseMoved)_mouseMoved.perform(this,createActInfo(event));
		}
		
		private function createActInfo(event:MouseEvent3D):IMouseActInfo{
			var ret:MouseActInfo = new MouseActInfo(null, event.altKey, event.ctrlKey, event.shiftKey);
			return ret;
		}
		
		protected function onMouseDown(event:MouseEvent3D):void{
			_mouseIsDown.booleanValue = true;
			
			_scene = _object3d.scene;
			_scene.addEventListener(MouseEvent3D.MOUSE_MOVE, onDownMove);
			_scene.addEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
			
			_dragX = event.screenX;
			_dragY = event.screenY;
			
			_clickBegan = getTimer();
		}
		
		protected function onDownMove(event:MouseEvent3D):void{
			var xDist:Number = event.screenX-_dragX;
			var yDist:Number = event.screenY-_dragY;
			if(!_isDragging){
				var dist:Number = Math.sqrt((xDist*xDist)+(yDist*yDist));
				if(dist>_dragTreshold){
					// start dragging
					_isDragging = true;
					if(_mouseDragStart)_mouseDragStart.perform(this);
				}
			}
			if(_isDragging){
				if(_mouseDrag)_mouseDrag.perform(this,xDist,yDist);
				
				_dragX = event.screenX;
				_dragY = event.screenY;
			}
			
		}
		
		protected function onMouseUp(event:MouseEvent3D):void{
			_mouseIsDown.booleanValue = false;
			
			_scene.removeEventListener(MouseEvent3D.MOUSE_MOVE, onDownMove);
			_scene.removeEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
			_scene = null;
			
			if(_isDragging){
				_isDragging = false;
				if(_mouseDragFinish)_mouseDragFinish.perform(this);
			}else if(_mouseIsOver.booleanValue){
				var timeDiff:int = getTimer()-_clickBegan;
				if(timeDiff<_clickSpeedMS){
					if(_mouseClick)_mouseClick.perform(this);
				}else{
					if(_mouseLongClick)_mouseLongClick.perform(this);
				}
			}
		}
		
	}
}